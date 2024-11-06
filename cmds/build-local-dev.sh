#! /bin/bash

set -e

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..

export LOCAL_DEV=true
source ./config/load.sh $1

cd $ROOT_DIR/..
# Store fin branch override form local fs
source ../fin/devops/config.sh
export FIN_VERSION_OVERRIDE=$FIN_BRANCH_NAME

source $ROOT_DIR/../config/load.sh $1

# build local fin
$REPOSITORY_DIR/$FIN_SERVER_REPO_NAME/devops/build-context.sh

cd $ROOT_DIR/..
echo "building images"
./cmds/build.sh $1