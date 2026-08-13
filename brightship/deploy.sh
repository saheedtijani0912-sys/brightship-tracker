#!/bin/bash

set -e

SERVER="51.96.83.141"
PEM="${PEM_PATH:?PEM_PATH is required}"

if [ -z "$1" ]; then
  echo "Usage: ./deploy.sh <git-sha>"
  exit 1
fi

IMAGE_TAG="$1"

echo "Deploying BrightShip version: $IMAGE_TAG"
echo "Production server: $SERVER"
echo ""

ssh -i "$PEM" ubuntu@"$SERVER" << EOF
set -e

echo "Pulling production secrets..."

SECRET_JSON=\$(aws secretsmanager get-secret-value \
  --secret-id brightship/production/database \
  --query SecretString \
  --output text)

export IMAGE_TAG="$IMAGE_TAG"
export DB_HOST=\$(echo "\$SECRET_JSON" | jq -r '.DB_HOST')
export DB_NAME=\$(echo "\$SECRET_JSON" | jq -r '.DB_NAME')
export DB_USER=\$(echo "\$SECRET_JSON" | jq -r '.DB_USER')
export DB_PASSWORD=\$(echo "\$SECRET_JSON" | jq -r '.DB_PASSWORD')

echo "Pulling Docker image..."

docker pull ghcr.io/saheedtijani0912-sys/brightship-tracker:\$IMAGE_TAG

cd /home/ubuntu/brightship

echo "Restarting production..."

docker compose \
  -f docker-compose.production.yml \
  up -d

echo ""
echo "Production containers:"
docker ps

echo ""
echo "Running production smoke test..."

curl -f http://localhost:3001/health

echo ""
echo "Production deploy complete — version \$IMAGE_TAG is live."
EOF