#!/bin/bash

# arguments:
#   utxo
#   wallet address file
#   signing key file
#   nft token name

#export CARDANO_NODE_SOCKET_PATH=node.socket

bodyFile=axu-tx-body.01
outFile=axu-tx.01
nftPolicyFile="nft-mint-policy.plutus"
nftPolicyId=$(./policyid.sh $nftPolicyFile)
nftTokenName=$4
value="1 $nftPolicyId.$nftTokenName"
walletAddr=$(cat $2)

echo "utxo: $1"
echo "bodyFile: $bodyFile"
echo "outFile: $outFile"
echo "nftPolicyFile: $nftPolicyFile"
echo "nftPolicyId: $nftPolicyId"
echo "value: $value"
echo "walletAddress: $walletAddr"
echo "signing key file: $3"
echo

echo "querying protocol parameters"
./query-protocol-parameters.sh

echo

cat << END > metadata.json
{
  "1": {
    "$nftPolicyId": {
      "$nftTokenName": {
        "description": "$nftTokenName description",
        "name": "$nftTokenName",
        "id": "1",
        "attributes":{"tan cong": 100, "phong thu": 50, "he": "thuy"}
      }
    }
  }
}
END

echo created the below metadata.json : 
echo ------------------------------------------
cat metadata.json
echo ------------------------------------------
echo ; echo;

cardano-cli transaction build \
    --alonzo-era \
    --testnet-magic $TESTNETMAGIC \
    --tx-in $1 \
    --tx-in-collateral $1 \
    --tx-out "$walletAddr + 1413762 lovelace + $value" \
    --mint "$value" \
    --mint-script-file $nftPolicyFile \
    --mint-redeemer-value 1 \
    --change-address $walletAddr \
    --metadata-json-file metadata.json  \
    --protocol-params-file  protocol-parameters.json \
    --out-file $bodyFile

echo "saved transaction to $bodyFile"

cardano-cli transaction sign \
    --tx-body-file $bodyFile \
    --signing-key-file $3 \
    --testnet-magic $TESTNETMAGIC \
    --out-file $outFile

echo "signed transaction and saved as $outFile"

cardano-cli transaction submit \
    --testnet-magic $TESTNETMAGIC \
    --tx-file $outFile

echo "submitted transaction"

echo
