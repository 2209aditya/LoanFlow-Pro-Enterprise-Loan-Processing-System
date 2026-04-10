#!/bin/bash

echo "Checking application health..."

STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://app/health)

if [ "$STATUS" -ne 200 ]; then
  echo "Health check failed!"
  exit 1
fi

echo "Application healthy"