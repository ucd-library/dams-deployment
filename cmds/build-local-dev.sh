#! /bin/bash

###
# Build images for local development.  They will be tagged with local-dev and are
# meant to be used with ./rp-local-dev/docker-compose.yaml
# Note: these images should never be pushed to docker hub 
###

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..

source config.sh

export LOCAL_DEV=true

# build local fin
$REPOSITORY_DIR/$FIN_SERVER_REPO_NAME/devops/build.sh 

./cmds/build.sh

# now build keycloak
docker build \
  -t $KEYCLOAK_IMAGE_NAME:$APP_VERSION \
  $ROOT_DIR/../keycloak