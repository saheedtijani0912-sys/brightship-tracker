#!/bin/bash

set -e

# BrightShip production deployment
# Usage: ./deploy.sh <git-sha>

SERVER="51.96.83.141"
PEM="$HOME/.ssh/brightship-prod.pem"

if [ -z "$1" ]; then
  echo "Usage: ./deploy.sh <git-sha>"
  exit 1
fi

IMAGE_TAG="$1"

echo "Deploying BrightShip image: $IMAGE_TAG"
echo "Production server: $SERVER"
echo ""

ssh -i "$PEM" ubuntu@"$SERVER" << EOF
set -e

echo "Pulling production secrets from AWS Secrets Manager..."

SECRET_JSON=\$(aws secretsmanager get-secret-value \
  --secret-id brightship/production/database \
  --query SecretString \
  --output text)

export IMAGE_TAG="$IMAGE_TAG"
export DB_HOST=\$(echo "\$SECRET_JSON" | jq -r '.DB_HOST')
export DB_NAME=\$(echo "\$SECRET_JSON" | jq -r '.DB_NAME')
export DB_USER=\$(echo "\$SECRET_JSON" | jq -r '.DB_USER')
export DB_PASSWORD=\$(echo "\$SECRET_JSON" | jq -r '.DB_PASSWORD')

echo "Pulling image..."
docker pull ghcr.io/saheedtijani0912-sys/brightship-tracker:\$IMAGE_TAG

cd /home/ubuntu/brightship

echo "Starting production container..."
docker compose \
  -f docker-compose.production.yml \
  up -d

echo ""
echo "Production containers:"
docker ps

echo ""
echo "Production deployment complete."
EOF