#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..
source config.sh

# Wipe the current repository dir
if [ -d $REPOSITORY_DIR ] ; then
  rm -rf $REPOSITORY_DIR
fi
mkdir -p $REPOSITORY_DIR

# Fin Server
$GIT_CLONE $FIN_SERVER_REPO_URL.git \
  --branch $FIN_SERVER_REPO_TAG \
  --depth 1 \
  $REPOSITORY_DIR/$FIN_SERVER_REPO_NAME