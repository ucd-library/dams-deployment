#! /bin/bash

set -e

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..

gcloud config set project ucdlib-dams

ENVIRONMENT=$1
VERSION=$2
if [[ -z "$ENVIRONMENT" || -z "$VERSION" ]]; then
  echo "Usage: $0 <environment> <version>"
  exit 1
fi

IMAGE="us-west1-docker.pkg.dev/ucdlib-dams/pub/dams-image-utils:$VERSION"

ALLOWED_ENVIRONMENTS=("dev" "sandbox" "prod")
if [[ ! " ${ALLOWED_ENVIRONMENTS[@]} " =~ " ${ENVIRONMENT} " ]]; then
  echo "Invalid environment. Allowed values are: ${ALLOWED_ENVIRONMENTS[@]}"
  exit 1
fi

gcloud beta run deploy dams-image-utils-$ENVIRONMENT \
  --image $IMAGE \
  --command "node" \
  --args "index.js" \
  --platform managed \
  --memory=4Gi \
  --region=us-west1