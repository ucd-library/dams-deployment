#! /bin/bash

REMOTE_EXEC="ssh -i /ci-bot/.ssh/gcb ci-bot@sandbox.dams.library.ucdavis.edu"
REMOTE_DIR="/opt/dams-${BRANCH_NAME}"

count=$($REMOTE_EXEC "ls $REMOTE_DIR" | wc -l)
if [ $count == 0 ]; then
  echo "No deployment found, ignoring"
  exit
fi

$REMOTE_EXEC "cd $REMOTE_DIR; git reset HEAD --hard; git pull"
$REMOTE_EXEC "cd $REMOTE_DIR; docker-compose pull"
$REMOTE_EXEC "cd $REMOTE_DIR; docker-compose down; docker-compose up -d"