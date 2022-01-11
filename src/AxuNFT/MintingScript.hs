{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module AxuNFT.MintingScript
  ( apiNFTMintScript
  ) where

import           Cardano.Api.Shelley      (PlutusScript (..), PlutusScriptV1)
import           Codec.Serialise
import qualified Data.ByteString.Lazy     as LB
import qualified Data.ByteString.Short    as SBS
import           Ledger                   hiding (singleton)
import qualified Ledger.Typed.Scripts     as Scripts
import           Ledger.Value             as Value
import qualified PlutusTx
import           PlutusTx.Builtins        (modInteger)
import           PlutusTx.Prelude         hiding (Semigroup (..), unless)
import qualified Plutus.V1.Ledger.Scripts as Plutus
import           Prelude                  (Show)

{- HLINT ignore "Avoid lambda" -}

{-# INLINABLE mkNFTPolicy #-}
mkNFTPolicy :: TokenName -> TxOutRef -> BuiltinData -> ScriptContext -> Bool
mkNFTPolicy tn utxo _ ctx = traceIfFalse "UTxO not consumed"   hasUTxO           &&
                            traceIfFalse "wrong amount/token name minted" checkMintedAmount
  where
    info :: TxInfo
    info = scriptContextTxInfo ctx

    hasUTxO :: Bool
    hasUTxO = any (\i -> txInInfoOutRef i == utxo) $ txInfoInputs info

    checkMintedAmount :: Bool
    checkMintedAmount = case flattenValue (txInfoMint info) of
        [(_, tn', amt)] -> tn' == tn && amt == 1
        _               -> False

-- cabal run axu-nft -- $token_name $tx_out_ref
nftPolicy :: TokenName -> TxOutRef -> Scripts.MintingPolicy
nftPolicy tn utxo = mkMintingPolicyScript $
    $$(PlutusTx.compile [|| \tn' utxo' -> Scripts.wrapMintingPolicy $ mkNFTPolicy tn' utxo' ||])
    `PlutusTx.applyCode`
     PlutusTx.liftCode tn
    `PlutusTx.applyCode`
     PlutusTx.liftCode utxo

nftPlutusScript :: TokenName -> TxOutRef -> Script
nftPlutusScript tn utxo = unMintingPolicyScript $ nftPolicy tn utxo

nftValidator :: TokenName -> TxOutRef -> Validator
nftValidator tn utxo = Validator $ nftPlutusScript tn utxo

nftScriptAsCbor :: TokenName -> TxOutRef -> LB.ByteString
nftScriptAsCbor tn utxo = serialise $ nftValidator tn utxo

apiNFTMintScript :: TokenName -> TxOutRef -> PlutusScript PlutusScriptV1
apiNFTMintScript tn utxo = PlutusScriptSerialised $ SBS.toShort $ LB.toStrict $ nftScriptAsCbor tn utxo

