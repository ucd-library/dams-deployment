#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/../..

YAML_DIR=$(realpath "$ROOT_DIR/../../kustomize")

ENV=$1
if [[ -z "$ENV" ]]; then
  echo "No environment provided, exiting"
  exit -1;
fi

./cmds/setup-gcloud-kubectl.sh $ENV

function deploy() {
  SERVICE_NAME=$1

  cork-kube apply \
    --overlay $ENV \
    $YAML_DIR/$SERVICE_NAME
}


# volumes
deploy gcs-fuse
deploy ocfl-volume

# core services
deploy nfs-server
deploy elastic-search
deploy postgres
deploy fcrepo
deploy fcrepo-ro
deploy rabbitmq
deploy redis
deploy pg-rest

# fin services
deploy fin/gateway
deploy fin/dbsync
deploy fin/uber
deploy fin/workflow
deploy fin/gcs

# DAMS services
deploy iiif
deploy ucd-lib-client