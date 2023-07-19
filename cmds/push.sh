#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR
source ../config.sh

docker push $UCD_DAMS_INIT_IMAGE_NAME:$APP_TAG

docker push $UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG

docker push $DAMS_FCREPO_IMAGE_NAME:$APP_TAG

docker push $IMAGE_UTILS_IMAGE_NAME:$APP_TAG

docker push $IIIF_IMAGE_NAME:$APP_TAG

for image in "${ALL_DOCKER_BUILD_IMAGES[@]}"; do
  docker push $image:$DOCKER_CACHE_TAG || true
done
