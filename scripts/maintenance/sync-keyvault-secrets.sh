#!/bin/bash

SRC_KV=$1
DEST_KV=$2

echo "🔄 Syncing secrets from $SRC_KV → $DEST_KV"

for secret in $(az keyvault secret list --vault-name $SRC_KV --query "[].name" -o tsv); do
  value=$(az keyvault secret show --vault-name $SRC_KV --name $secret --query value -o tsv)

  az keyvault secret set \
    --vault-name $DEST_KV \
    --name $secret \
    --value "$value"

  echo "✔ Synced: $secret"
done

echo "✅ Key Vault sync complete"