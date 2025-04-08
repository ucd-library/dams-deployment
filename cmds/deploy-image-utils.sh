#! /bin/bash

set -e

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..

gcloud config set project ucdlib-dams

ENVIRONMENT=$1
IMAGE=$2
if [[ -z "$ENVIRONMENT" || -z "$IMAGE" ]]; then
  echo "Usage: $0 <environment> <image>"
  exit 1
fi

ALLOWED_ENVIRONMENTS=("dev" "sandbox" "prod")
if [[ ! " ${ALLOWED_ENVIRONMENTS[@]} " =~ " ${ENVIRONMENT} " ]]; then
  echo "Invalid environment. Allowed values are: ${ALLOWED_ENVIRONMENTS[@]}"
  exit 1
fi

gcloud beta run deploy dams-image-utils-$ENVIRONMENT \
  --image $IMAGE \
  --platform managed \
  --memory=4Gi \
  --region=us-west1