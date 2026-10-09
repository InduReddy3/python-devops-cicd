
#!/usr/bin/env bash
set -Eeuo pipefail

# Find the project root, regardless of the current directory.
PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="python-devops-cicd:v1"
CONTAINER_NAME="python-devops-app"
HOST_PORT=5000

cd "$PROJECT_ROOT"

# Check that Docker is available.
if ! command -v docker >/dev/null 2>&1; then
    echo "ERROR: Docker is not installed or not in PATH."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker is not running or access is denied."
    exit 1
fi

# Build the image from the project Dockerfile.
echo "Building Docker image..."
docker build -t "$IMAGE_NAME" .

# Remove an older container with the same name.
if docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    echo "Removing existing container..."
    docker rm -f "$CONTAINER_NAME"
fi

# Start the application on localhost port 5000.
echo "Starting application..."
docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    -p "127.0.0.1:${HOST_PORT}:5000" \
    "$IMAGE_NAME"

# Wait for the health endpoint to respond.
for attempt in {1..20}; do
    if curl --fail --silent \
        "http://127.0.0.1:${HOST_PORT}/health" >/dev/null; then
        echo "SUCCESS: Application is healthy."
        echo "Home:   http://127.0.0.1:${HOST_PORT}/"
        echo "Health: http://127.0.0.1:${HOST_PORT}/health"
        exit 0
    fi

    if ! docker container inspect -f '{{.State.Running}}' \
        "$CONTAINER_NAME" 2>/dev/null | grep -qx true; then
        echo "ERROR: Container stopped unexpectedly."
        docker logs "$CONTAINER_NAME" || true
        exit 1
    fi

    echo "Waiting for application... ($attempt/20)"
    sleep 2
done

echo "ERROR: Application did not become healthy in time."
docker logs "$CONTAINER_NAME" || true
exit 1
