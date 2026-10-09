
#!/usr/bin/env bash
set -Eeuo pipefail

CONTAINER_NAME="python-devops-app"
BASE_URL="http://127.0.0.1:5000"

# Verify that the container exists and is running.
if ! docker container inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
    echo "FAIL: Container does not exist."
    exit 1
fi

if [[ "$(docker container inspect -f '{{.State.Running}}' "$CONTAINER_NAME")" != "true" ]]; then
    echo "FAIL: Container is not running."
    exit 1
fi

# Test the home endpoint.
if curl --fail --silent --show-error --max-time 5 \
    "$BASE_URL/" -o /tmp/devops-home-response.txt; then
    echo "PASS: Home endpoint responds."
    cat /tmp/devops-home-response.txt
else
    echo "FAIL: Home endpoint is not responding."
    exit 1
fi

# Test the health endpoint.
if curl --fail --silent --show-error --max-time 5 \
    "$BASE_URL/health"; then
    echo
    echo "PASS: Health endpoint responds."
else
    echo "FAIL: Health endpoint is not responding."
    exit 1
fi

echo "SUCCESS: Container and both endpoints are responding."
