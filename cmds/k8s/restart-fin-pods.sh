#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

ENV=$1
if [[ -z "$ENV" ]]; then
  echo "No environment provided, exiting"
  exit -1;
fi

../setup-gcloud-kubectl.sh $ENV

# fin services
kubectl rollout restart deployment/gateway
kubectl rollout restart deployment/dbsync
kubectl rollout restart deployment/uber
kubectl rollout restart deployment/workflow
kubectl rollout restart deployment/gcs
kubectl rollout restart deployment/iiif
kubectl rollout restart deployment/ucd-lib-client