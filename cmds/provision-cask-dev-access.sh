#! /bin/bash
#
# Provisions dams's interim dev/test access to argonath-prod's live CaskFS
# instance (docs/PORT-PLAN.md Phase 1). NOT run automatically by anything -
# this is a runbook, meant to be read and run by hand by whoever has kubectl
# access to the argonath-prod cluster, after reviewing what it does.
#
# Background: argonath-deployment has no dev/sandbox namespace (confirmed
# empty - only a "prod" environment exists in its .cork-kube-config), so the
# interim plan is dams's dev environment calling argonath-prod's real cask
# service directly, scoped to the gold/digital-dev path already named for
# this purpose in argonath's docs/cask-conventions.md.
#
# CaskFS's ACL is USERNAME-keyed, not Keycloak-role-keyed: the "roles" field
# parsed out of the x-user header by CaskFS's own header-auth middleware is
# never read anywhere in CaskFS's permission checks (verified by reading
# src/lib/middleware/header-auth.js + a repo-wide grep for req.user.roles).
# All real permission resolution happens against CaskFS's own Postgres
# (a role/permission system fully internal to CaskFS), keyed by whatever
# username string arrives in x-user. Practically, this means:
#   - The security boundary is "who can reach cask's port with a trusted
#     x-user header" (auth-gateway, or a NetworkPolicy), NOT a Keycloak role
#     name. This script does not attempt to solve that boundary - it only
#     provisions the CaskFS-side role/grant for a fixed identity
#     (CASK_USER below), matching services/client/config.js's `cask.user`
#     and dams-deployment's dev ConfigMap (CASK_USER: dams-dev-service).
#   - Whatever forwards requests to cask (auth-gateway today, or dams's own
#     server if it calls cask directly - see PORT-PLAN.md Phase 5's open
#     question) must be trusted to always send this exact username for
#     dev traffic, and never let a caller choose an arbitrary one.
#
# This exact sequence was verified end-to-end against a local docker-compose
# CaskFS+Postgres instance (ACL + header-auth both enabled) on 2026-09-02:
# a GET to /cask/api/fs/gold/digital-dev/<file>?metadata=true with
# `x-user: {"username":"dams-dev-service"}` returned 200 + real metadata/
# bytes; the same call against a path outside the grant, or with no x-user
# header at all, returned 403. Default is deny.
#
# Usage: read this file, adjust CASK_USER/CASK_ROLE/CASK_PATH if needed,
# then run it against argonath-prod:
#   ./provision-cask-dev-access.sh
#
set -e

NAMESPACE="argonath-prod"
DEPLOYMENT="cask"
CASK_ROLE="dev-digital"
CASK_USER="dams-dev-service"
CASK_PATH="/gold/digital-dev"

echo "Target cluster/context: $(kubectl config current-context)"
echo "This will run 'cask acl' commands inside deployment/$DEPLOYMENT in namespace $NAMESPACE."
read -p "Continue? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborted."
  exit 1
fi

KEXEC="kubectl -n $NAMESPACE exec deploy/$DEPLOYMENT -- cask acl"

# ensureRole/ensureUser are idempotent - safe to re-run.
$KEXEC role-add "$CASK_ROLE"
$KEXEC user-add "$CASK_USER"
$KEXEC user-role-set "$CASK_USER" "$CASK_ROLE"

# setDirectoryPermission requires the directory to already exist in CaskFS's
# tree (see src/lib/acl.js ensureRootDirectoryAcl) - if gold/digital-dev has
# never been written to, this will fail with "Directory ... does not exist".
# In that case, have whoever owns argonath-side ingestion write a real file
# there first (or `cask write /gold/digital-dev/.keep -d /dev/null`), then
# re-run just the permission-set line below.
$KEXEC permission-set "$CASK_PATH" "$CASK_ROLE" write -t role

echo ""
echo "Current ACL for $CASK_PATH:"
$KEXEC get "$CASK_PATH"

echo ""
echo "Verify with a real request once dams's dev deployment is pointed at"
echo "CASK_URL=http://cask.$NAMESPACE.svc.cluster.local:3001, CASK_USER=$CASK_USER:"
echo "  curl -H 'x-user: {\"username\":\"$CASK_USER\"}' \\"
echo "    \"http://cask.$NAMESPACE.svc.cluster.local:3001/cask/api/fs$CASK_PATH/<file>?metadata=true\""
