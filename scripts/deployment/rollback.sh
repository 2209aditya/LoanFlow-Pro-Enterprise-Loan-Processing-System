#!/bin/bash

echo "⚠️ Rolling back deployment..."

RELEASE="loanflow"
NAMESPACE="default"

helm rollback $RELEASE

if [ $? -ne 0 ]; then
  echo "❌ Rollback failed!"
  exit 1
fi

echo "✅ Rollback successful"