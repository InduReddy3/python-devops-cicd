
#!/usr/bin/env bash
set -Eeuo pipefail

CONTAINER_NAME="python-devops-app"

# Check that Docker is accessible.
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker is not running or access is denied."
    exit 1
fi

# Stop the container if it exists and is running.
if ! docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    echo "Application container does not exist; nothing to stop."
    exit 0
fi

if [[ "$(docker container inspect -f '{{.State.Running}}' "$CONTAINER_NAME")" == "true" ]]; then
    echo "Stopping application..."
    docker stop "$CONTAINER_NAME"
    echo "SUCCESS: Application stopped."
else
    echo "Application is already stopped."
fi
