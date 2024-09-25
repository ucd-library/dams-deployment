#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
REPO_DIR=$(realpath $ROOT_DIR/../..)
cd $REPO_DIR

export LOCAL_DEV=true
source ./config.sh

YAML_DIR=$REPO_DIR/kustomize
ENV=${1:-sandbox}

# Store fin branch override form local fs
source ../fin/devops/config.sh
export FIN_VERSION_OVERRIDE=$FIN_BRANCH_NAME

echo "Deploying $ENV pods to local dev environment"

function debugOpts() {
  if [[ ! -z "$DEBUG" ]]; then
    echo "--dry-run"
    return
  fi
  echo ""
}

function stdOpts() {
  IMAGE=$1
  if [[ ! -z "$IMAGE" ]]; then
    IMAGE="--edit \"spec.template.spec.containers[*].image=$IMAGE\""
  fi
  echo "$IMAGE --local-dev --overlay local-dev,sandbox $(debugOpts)"
}

function deployFin() {
  SERVICE_NAME=$1
  cork-kube apply \
    --source-mount $YAML_DIR/src-mounts/base-service.json \
    $(stdOpts $UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG) \
    $(echo $2) \
    -- $YAML_DIR/fin/$SERVICE_NAME

}

# create ocfl-volume
cork-kube apply \
  --edit "spec.hostPath.path=$REPO_DIR/ocfl-volume" \
  --overlay local-dev \
  $(debugOpts) \
  $YAML_DIR/ocfl-volume

cork-kube apply \
  --edit "spec.hostPath.path=$REPO_DIR/gcs-fuse-volume" \
  --overlay local-dev \
  $(debugOpts) \
  $YAML_DIR/gcs-fuse

# fcrepo
cork-kube apply \
  --overlay $ENV \
  $(stdOpts $FCREPO_IMAGE_NAME:$FIN_TAG) \
  $YAML_DIR/fcrepo


# deploy core pods
# elastic-search
cork-kube apply \
  $(stdOpts $ELASTIC_SEARCH_IMAGE_NAME:$FIN_TAG) \
  $YAML_DIR/elastic-search

# pg-rest
cork-kube apply \
  $(stdOpts $PGREST_IMAGE_NAME:$FIN_TAG) \
  $YAML_DIR/pg-rest

# postgres
cork-kube apply \
  $(stdOpts $POSTGRES_IMAGE_NAME:$FIN_TAG) \
  $YAML_DIR/postgres

# rabbitmq
cork-kube apply \
  $(stdOpts $RABBITMQ_IMAGE_NAME:$FIN_TAG) \
  $YAML_DIR/rabbitmq

# redis
cork-kube apply \
  $(debugOpts) \
  $YAML_DIR/redis

# deploy fin pods
deployFin gateway "--source-mount $YAML_DIR/src-mounts/client.json"
deployFin dbsync
deployFin uber "\
  --edit \"spec.template.spec.containers[*].env[?(@.name=='K8S_COLLECTION_IMPORT_IMAGE')].value=$UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG\" \
  --edit \"spec.template.spec.containers[*].env[?(@.name=='K8S_COLLECTION_IMPORT_LOCAL_DEV_HOST_PATH')].value=$REPO_DIR/collection-import\" \
  --source-mount $YAML_DIR/src-mounts/collection-import.json "
deployFin workflow
deployFin gcs


# DAMS client
cork-kube apply \
  $(stdOpts $UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG) \
  --source-mount $YAML_DIR/src-mounts/client.json \
  -- $YAML_DIR/ucd-lib-client

# DAMS iiif
cork-kube apply \
  $(stdOpts $IIIF_IMAGE_NAME:$APP_TAG) \
  -- $YAML_DIR/iiif

# init job
cork-kube apply \
  --source-mount $YAML_DIR/src-mounts/base-service.json \
  $(stdOpts $UCD_DAMS_INIT_IMAGE_NAME:$APP_TAG) \
  $YAML_DIR/fin/init

echo "Done deploying $ENV pods to local dev environment"