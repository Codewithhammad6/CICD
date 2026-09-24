#!/bin/bash
set -e

DOCKER_TAG=$1

if [ -z "$DOCKER_TAG" ]; then
    echo "❌ Error: Docker tag provide nahi kiya gaya!"
    exit 1
fi


echo "🔄 Building & Updating Backend"


NODE_IP="3.137.319.159"

if [ -z "$NODE_IP" ]; then
    echo "❌ No worker node public IP found"
    exit 1
fi

FRONTEND_URL="http://${NODE_IP}:30080"

echo "🌐 Worker Public IP: $NODE_IP"
echo "⚙️ FRONTEND_URL: $FRONTEND_URL"
echo "🏷️ Backend Docker Tag: $DOCKER_TAG"

# Root workspace par move karo taaki paths hamesha theek milen
cd "$(dirname "$0")/.."

IMAGE="hammadch123/project-backend:${DOCKER_TAG}"

echo "🔨 Building Backend Image..."
docker build -t "$IMAGE" ./backend

echo "☁️ Pushing Backend Image..."
docker push "$IMAGE"

echo "🚀 Upgrading Helm Release..."
helm upgrade dev-app-backend ./k8s/backend \
  -n dev \
  --set-string env.frontendUrl="$FRONTEND_URL" \
  --set image.tag="${DOCKER_TAG}"

kubectl rollout status deployment/dev-app-backend -n dev

echo "============================================"
echo "✅ Backend Built, Pushed & Updated successfully!"
echo "============================================"
