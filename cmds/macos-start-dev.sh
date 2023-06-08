
#! /bin/bash

###
# Starts the local development environment
###

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

OPEN_TAB_DIR=$ROOT_DIR/macos-new-tab.sh
DEV_DEPLOY_DIR=$ROOT_DIR/../dams-local-dev

echo "Starting local docker cluster"
$OPEN_TAB_DIR $DEV_DEPLOY_DIR "docker compose up"
sleep 5

echo "Starting ucd-lib-client watch"
$OPEN_TAB_DIR $DEV_DEPLOY_DIR "docker compose exec ucd-lib-client bash -c 'cd ucd-lib-client && npm run watch'"

echo "Starting admin-ui-watch for fin admin"
$OPEN_TAB_DIR $DEV_DEPLOY_DIR "docker compose exec gateway bash -c 'npm run admin-ui-watch'"
