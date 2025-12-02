#!/bin/bash
set -e

# Required parameters
CONTAINER_APP_NAME=$1
RESOURCE_GROUP=$2
IMAGE_REF=$3
CLIENT_ID=$4
TENANT_ID=$5
REGISTRY=$6
REGISTRY_USERNAME=$7
REGISTRY_PASSWORD=$8

# Optional parameters with defaults
MAX_RETRIES=${10:-5}
RETRY_WAIT=${11:-20}

echo "===== STARTING AZURE DEPLOYMENT PROCESS ====="

# Build scale args from env if provided
SCALE_ARGS=()
if [ -n "${MIN_REPLICAS:-}" ]; then
  SCALE_ARGS+=(--min-replicas "$MIN_REPLICAS")
fi
if [ -n "${MAX_REPLICAS:-}" ]; then
  SCALE_ARGS+=(--max-replicas "$MAX_REPLICAS")
fi

# Deploy to Azure Container App
echo "Updating Container App with image: $IMAGE_REF"
REVISION_NAME=$(az containerapp update \
  --name "$CONTAINER_APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --image "$IMAGE_REF" \
  "${SCALE_ARGS[@]}" \
  --query "properties.latestRevisionName" \
  --output tsv)

echo "✅ Deployment triggered - New revision: $REVISION_NAME"

# Get application URL
echo "Getting application URL..."
APP_URL=$(az containerapp show \
  --name "$CONTAINER_APP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "properties.configuration.ingress.fqdn" \
  --output tsv)

echo "✅ Container App URL: https://$APP_URL"

# Health check
echo "Checking application health..."
HEALTH_URL="https://${APP_URL}/actuator/health/startup"
echo "Health URL: ${HEALTH_URL}"

RETRY_COUNT=0
HEALTH_OK=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$HEALTH_OK" != "true" ]; do
  echo "Health check attempt $((RETRY_COUNT+1))/$MAX_RETRIES..."
  
  # Perform health check with timeout to avoid hanging
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "${HEALTH_URL}" || echo "000")
  
  if [ "$RESPONSE" == "200" ]; then
    echo "✅ Application is healthy!"
    HEALTH_OK=true
  else
    echo "❌ Health check failed with status ${RESPONSE}. Retrying in $RETRY_WAIT seconds..."
    sleep $RETRY_WAIT
    RETRY_COUNT=$((RETRY_COUNT+1))
  fi
done

if [ "$HEALTH_OK" != "true" ]; then
  echo "❌ Health check failed after $MAX_RETRIES attempts"
  exit 1
fi

echo "===== DEPLOYMENT SUCCESSFUL ====="
echo "Application is deployed at: https://$APP_URL"
exit 0