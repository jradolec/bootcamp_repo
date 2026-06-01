#!/usr/bin/env sh
set -eu

IMAGE="${IMAGE:-secure-squid-chainguard:latest}"
CONTAINER_NAME="${CONTAINER_NAME:-secure-squid-smoke-test}"
HOST_PORT="${HOST_PORT:-3128}"
TEST_URL="${TEST_URL:-http://example.com/}"

cleanup() {
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

cleanup

docker run -d --name "$CONTAINER_NAME" -p "${HOST_PORT}:3128" "$IMAGE" >/dev/null

# Wait for Squid to accept proxy requests.
attempt=1
while [ "$attempt" -le 30 ]; do
  if curl -fsS -x "http://127.0.0.1:${HOST_PORT}" --max-time 5 "$TEST_URL" >/dev/null 2>&1; then
    echo "Smoke test passed: proxy handled ${TEST_URL} via ${IMAGE}."
    exit 0
  fi
  attempt=$((attempt + 1))
  sleep 1
done

echo "Smoke test failed: proxy did not handle ${TEST_URL} within timeout." >&2
docker logs "$CONTAINER_NAME" >&2 || true
exit 1
