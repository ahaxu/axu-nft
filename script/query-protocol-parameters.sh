#!/bin/bash
cardano-cli query protocol-parameters \
    --testnet-magic $TESTNETMAGIC \
    --out-file "protocol-parameters.json"
