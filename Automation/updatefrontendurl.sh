#!/bin/bash
set -e

DOCKER_TAG=$1

if [ -z "$DOCKER_TAG" ]; then
    echo "❌ Error: Docker tag provide nahi kiya gaya!"
    exit 1
fi

echo "============================================"
echo "🔄 Updating Frontend VITE_BACKEND_URL"
echo "============================================="

NODE_IP="3.137.219.159"

if [ -z "$NODE_IP" ]; then
    echo "❌ No worker node public IP found"
    exit 1
fi

BACKEND_URL="http://${NODE_IP}:31100"

echo "🌐 Worker Public IP: $NODE_IP"
echo "⚙️ VITE_BACKEND_URL: $BACKEND_URL"
echo "🏷️ Frontend Docker Tag: $DOCKER_TAG"

# Root workspace par move karo taaki paths hamesha theek milen
cd "$(dirname "$0")/.."

# Ensure frontend folder exists
mkdir -p ./frontend

cat > ./frontend/.env <<EOF
VITE_BACKEND_URL="${BACKEND_URL}/api"
EOF

IMAGE="hammadch123/project-frontend:${DOCKER_TAG}"

docker build --no-cache -t "$IMAGE" ./frontend
docker push "$IMAGE"

helm upgrade dev-app ./k8s/frontend \
  -n dev \
  --set image.tag="${DOCKER_TAG}"

kubectl rollout status deployment/dev-app-frontend -n dev

echo "============================================"
echo "✅ Frontend updated successfully!"
echo "============================================"
