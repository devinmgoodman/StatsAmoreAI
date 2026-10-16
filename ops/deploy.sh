#!/usr/bin/env bash
# Deploy the prod stack on the Mac Mini. Run from the repo root (the self-hosted runner does this).
# Needs: IMAGE_TAG. Optional: PROD_ENV_FILE (absolute path, symlinked as .env.prod), HEALTH_URL (public check).
# Never reads or writes the contents of .env.prod.
set -euo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:$PATH"

: "${IMAGE_TAG:?IMAGE_TAG required}"
STATE_DIR="${DEPLOY_STATE_DIR:-$HOME/.statsamore}"
LAST_GOOD_FILE="$STATE_DIR/last_good_tag"
mkdir -p "$STATE_DIR"

if [ -n "${PROD_ENV_FILE:-}" ]; then ln -sfn "$PROD_ENV_FILE" .env.prod; fi
[ -f .env.prod ] || { echo ".env.prod not found (set PROD_ENV_FILE to its absolute path)"; exit 1; }

dc() { docker compose --env-file .env.prod -f compose.yml -f compose.prod.yml "$@"; }

wait_backend_healthy() {
  local s
  for _ in $(seq 1 40); do
    s=$(docker inspect -f '{{.State.Health.Status}}' stats-amore-backend 2>/dev/null || echo none)
    [ "$s" = healthy ] && return 0
    sleep 3
  done
  return 1
}

public_check() {
  [ -z "${HEALTH_URL:-}" ] && return 0
  curl -fsS --max-time 15 --retry 5 --retry-delay 3 --retry-connrefused "$HEALTH_URL" >/dev/null
}

rollback() {
  if [ -f "$LAST_GOOD_FILE" ]; then
    local prev; prev=$(cat "$LAST_GOOD_FILE")
    echo "Rolling back to $prev"
    IMAGE_TAG="$prev" dc up -d --no-build --remove-orphans
  else
    echo "No previous release recorded; nothing to roll back to"
  fi
}

echo "==> Building $IMAGE_TAG"
dc build backend backup
dc pull postgres caddy ddns

# Safety net before any migration: dump now if the backup container is already running.
if [ "$(docker inspect -f '{{.State.Running}}' stats-amore-backup 2>/dev/null || echo false)" = true ]; then
  echo "==> Pre-deploy backup"
  docker exec stats-amore-backup /usr/local/bin/backup.sh
fi

echo "==> Database up + migrations"
dc up -d --wait postgres
dc run --rm --no-deps backend npm run migrate --if-present \
  || { echo "Migration failed; running stack left on the previous release"; exit 1; }

echo "==> Restart"
if ! { dc up -d --no-build --remove-orphans && wait_backend_healthy && public_check; }; then
  echo "Deploy failed; recent backend logs:"
  dc logs --tail=50 backend || true
  rollback
  exit 1
fi

echo "$IMAGE_TAG" > "$LAST_GOOD_FILE"
docker image prune -f --filter "until=168h" >/dev/null || true
echo "==> Deployed $IMAGE_TAG"
