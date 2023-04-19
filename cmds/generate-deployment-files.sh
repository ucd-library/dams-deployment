#! /bin/bash

set -e

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/../templates

# Store fin branch override form local fs
cd ../repositories/fin/devops
source ./config.sh 
export FIN_VERSION_OVERRIDE=$FIN_BRANCH_NAME

cd $ROOT_DIR/../templates
source ../config.sh

cork-template \
  -c ../config.sh \
  -t prod.yaml \
  -o ../docker-compose.yaml

LOCAL_DEV=true cork-template \
  -c ../config.sh \
  -t local-dev.yaml \
  -o ../dams-local-dev/docker-compose.yaml