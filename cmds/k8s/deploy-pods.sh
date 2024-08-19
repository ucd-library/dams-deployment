#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/../..

YAML_DIR=$(realpath "$ROOT_DIR/../../kustomize")
GEN_DIR_NAME=_gen-local-dev

ENV=$1
if [[ -z "$ENV" ]]; then
  echo "No environment provided, exiting"
  exit -1;
fi

# volumes
kubectl apply -k ./kustomize/nfs-server

if [[ $ENV != "local-dev" ]]; then
  kubectl apply -k ./kustomize/gcs-fuse/base
  kubectl apply -k ./kustomize/ocfl-volume/overlays/$ENV

else 

  export REPO_DIR=$(realpath "$ROOT_DIR/../..")
  export BRANCH_TAG_NAME
  export LOCAL_DEV

  mkdir -p $REPO_DIR/ocfl-volume

  cork-template \
    -c ./config.sh \
    -t $YAML_DIR/ocfl-volume/overlays/local-dev \
    -o $YAML_DIR/ocfl-volume/overlays/$GEN_DIR_NAME

  kubectl apply -k ./kustomize/ocfl-volume/overlays/$GEN_DIR_NAME
fi

# core services
kubectl apply -k ./kustomize/elastic-search/base
kubectl apply -k ./kustomize/postgres/base
kubectl apply -k ./kustomize/fcrepo/base
kubectl apply -k ./kustomize/fcrepo-ro/base
kubectl apply -k ./kustomize/rabbitmq/base
kubectl apply -k ./kustomize/redis/base
kubectl apply -k ./kustomize/pg-rest/base

# fin services
kubectl apply -k ./kustomize/fin/gateway/overlays/$ENV
kubectl apply -k ./kustomize/fin/dbsync/overlays/$ENV
kubectl apply -k ./kustomize/fin/uber/overlays/$ENV
kubectl apply -k ./kustomize/fin/workflow/overlays/$ENV
kubectl apply -k ./kustomize/fin/gcs/overlays/$ENV
kubectl apply -k ./kustomize/iiif/base
kubectl apply -k ./kustomize/ucd-lib-client/base