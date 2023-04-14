#! /bin/bash

set -e

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..
source config.sh

gcloud config set project $GC_PROJECT_ID

gcloud beta run deploy $IMAGE_UTILS_CLOUD_RUN_SERVICE_NAME \
  --image $IMAGE_UTILS_IMAGE_NAME:$UCD_DAMS_DEPLOYMENT_BRANCH \
  --platform managed \
  --memory=4Gi \
  --region=us-central1

# gcloud beta run deploy dams-image-utils-sandbox \
#   --image gcr.io/ucdlib-pubreg/dams-image-utils:sandbox \
#   --platform managed \
#   --memory=4Gi \
#   --region=us-central1

  