#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

ENV=$1
if [[ -z "$ENV" ]]; then
  echo "No environment provided, exiting"
  exit -1;
fi

./setup-kubectl.sh

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
kubectl apply -k ./kustomize/fin/fin-cache/overlays/$ENV
kubectl apply -k ./kustomize/fin/uber/overlays/$ENV
kubectl apply -k ./kustomize/fin/workflow/overlays/$ENV
kubectl apply -k ./kustomize/fin/gcs/overlays/$ENV
kubectl apply -k ./kustomize/iiif/base
kubectl apply -k ./kustomize/ucd-lib-client/base