### AXU NFT

### Gen plutus script

Test net

```
# to get the utxo
export TESTNETMAGIC=1097911063

cardano-cli query utxo \
    --address `cat payment2.addr` --testnet-magic $TESTNETMAGIC

export tx_out_ref="4aec09a13bf01b94c3cb653527a61d912b29a2d15aa3c6b3f83eb6ee3f3d6be8#1"
export token_name="AhaXUNFT2022"
cabal run axu-nft -- $token_name $tx_out_ref
# check ./script/nft-mint-policy.plutus for the plutus script
```

### Minting
```
cd ./script
./mint.sh $utxo $wallet_addr_file $signing_key_file $nft_token_name
```

Then you can check on test net https://testnet.cardanoscan.io/transaction/4aec09a13bf01b94c3cb653527a61d912b29a2d15aa3c6b3f83eb6ee3f3d6be8?tab=contracts

### Connect to wallet

Link to sample of connectiong with wallet (nami in this case)

https://github.com/ahaxu/minting-nft-sample

### Market place

- Todo
    - Create sale
    - Update price
    - Cancel/close sale
    - Buy
