#! /bin/bash

set -e

REMOTE_EXEC="ssh -i /root/.ssh/gcb ci-bot@sandbox.dams.library.ucdavis.edu"
REMOTE_DIR="/opt/dams-${BRANCH_NAME}"

count=$($REMOTE_EXEC "ls $REMOTE_DIR" | wc -l)
if [ $count == 0 ]; then
  echo "No deployment found, ignoring"
  exit
fi

$REMOTE_EXEC "cd $REMOTE_DIR; git reset HEAD --hard; git pull"
$REMOTE_EXEC "cd $REMOTE_DIR; docker compose pull"
$REMOTE_EXEC "cd $REMOTE_DIR; docker compose down"
$REMOTE_EXEC "cd $REMOTE_DIR; ./cmds/start.sh"