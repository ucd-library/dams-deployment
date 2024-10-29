#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..
source config/load.sh $1

# Wipe the current repository dir
if [ -d $REPOSITORY_DIR ] ; then
  rm -rf $REPOSITORY_DIR
fi
mkdir -p $REPOSITORY_DIR

echo "Cloning $UCD_DAMS_REPO_URL.git @ $DAMS_REPO_TAG"

# Dams
$GIT_CLONE $UCD_DAMS_REPO_URL.git \
  --branch $DAMS_REPO_TAG \
  --depth 1 \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME