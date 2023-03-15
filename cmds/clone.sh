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

# Dams
$GIT_CLONE $UCD_DAMS_REPO_URL.git \
  --branch $DAMS_REPO_TAG \
  --depth 1 \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME