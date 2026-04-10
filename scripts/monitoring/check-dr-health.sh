#!/bin/bash

APP_URL=$1

echo "🔍 Checking DR Health: $APP_URL"

API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL/api/health")
DB_STATUS=$(curl -s "$APP_URL/db-check")

if [ "$API_STATUS" -ne 200 ]; then
  echo "❌ API is DOWN"
  exit 1
fi

if [[ "$DB_STATUS" != *"UP"* ]]; then
  echo "❌ DB is DOWN"
  exit 1
fi

echo "✅ DR Environment Healthy"