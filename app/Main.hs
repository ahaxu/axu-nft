import Cardano.Api                         hiding (TxId)
import Data.String                         (IsString (..))
import Ledger
import Ledger.Bytes                        (getLedgerBytes)
import Prelude
import System.Environment                  (getArgs)

import AxuNFT.MintingScript

main :: IO ()
main = do
    args <- getArgs
    let 
        tn              = fromString $ head args
        utxo            = parseUTxO $ last args
        nftPolicyFile   = "script/nft-mint-policy.plutus"

    nftPolicyResult <- writeFileTextEnvelope nftPolicyFile Nothing $ apiNFTMintScript tn utxo
    case nftPolicyResult of
        Left err -> print $ displayError err
        Right () -> putStrLn $ "wrote NFT policy to file " ++ nftPolicyFile

parseUTxO :: String -> TxOutRef
parseUTxO s =
  let
    (x, y) = span (/= '#') s
  in
    TxOutRef (TxId $ getLedgerBytes $ fromString x) $ read $ tail y

