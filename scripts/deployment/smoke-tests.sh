#!/bin/bash

APP_URL=$1

echo "🔍 Running smoke tests on $APP_URL"

STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL/health")

if [ "$STATUS" -ne 200 ]; then
  echo "❌ Smoke test failed!"
  exit 1
fi

echo "✅ Smoke test passed"