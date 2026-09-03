#! /bin/bash
#
# One-time setup after `docker compose up -d` on a fresh volume set: initializes
# CaskFS's Postgres schema and grants the dev.js scoped ACL role/permission that
# services/client/config.js's cask.user (CASK_USER=dams-dev-service) needs to
# read/write under /gold/digital-dev. Safe to re-run - every step is idempotent
# except the seed file write, which no-ops if it already exists.
#
# See docs/PORT-PLAN.md (dams repo) Phase 1 for why CaskFS's ACL is
# username-keyed rather than Keycloak-role-keyed, and
# cmds/provision-cask-dev-access.sh for the equivalent runbook against real
# argonath-prod (not run automatically, unlike this script).
#
set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$ROOT_DIR"

CASK_CONTAINER="local-dev-cask-1"
CASK_ROLE="dev-digital"
CASK_USER="dams-dev-service"
CASK_PATH="/gold/digital-dev"

echo "Initializing CaskFS Postgres schema (no-op if already initialized)..."
docker exec "$CASK_CONTAINER" cask init-pg || true

echo "Provisioning $CASK_USER -> $CASK_ROLE -> write on $CASK_PATH..."
docker exec -e CASKFS_ACL_ENABLED=false "$CASK_CONTAINER" cask acl role-add "$CASK_ROLE"
docker exec -e CASKFS_ACL_ENABLED=false "$CASK_CONTAINER" cask acl user-add "$CASK_USER"
docker exec -e CASKFS_ACL_ENABLED=false "$CASK_CONTAINER" cask acl user-role-set "$CASK_USER" "$CASK_ROLE"

# permission-set requires the directory to already exist in CaskFS's tree.
docker exec "$CASK_CONTAINER" sh -c "test -e /tmp/.dev-seed || echo 'local dev seed file' > /tmp/.dev-seed"
docker exec -e CASKFS_ACL_ENABLED=false "$CASK_CONTAINER" cask write "$CASK_PATH/seed.txt" -d /tmp/.dev-seed -r || true
docker exec -e CASKFS_ACL_ENABLED=false "$CASK_CONTAINER" cask acl permission-set "$CASK_PATH" "$CASK_ROLE" write -t role

echo ""
echo "Done. Verify from the client container:"
echo "  docker exec local-dev-client-1 node -e \""
echo "    fetch('http://cask:3001/cask/api/fs$CASK_PATH/seed.txt?metadata=true', {"
echo "      headers: { 'x-user': JSON.stringify({username: process.env.CASK_USER}) }"
echo "    }).then(r => r.text()).then(console.log)\""
