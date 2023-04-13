#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR
source ../config.sh

docker push $UCD_DAMS_INIT_IMAGE_NAME:$APP_TAG
docker tag $UCD_DAMS_INIT_IMAGE_NAME:$APP_TAG $UCD_DAMS_INIT_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG
docker tag $UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG $UCD_DAMS_SERVER_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $IMAGE_UTILS_IMAGE_NAME:$APP_TAG
docker tag $IMAGE_UTILS_IMAGE_NAME:$APP_TAG $IMAGE_UTILS_IMAGE_NAME:$DOCKER_CACHE_TAG

for image in "${ALL_DOCKER_BUILD_IMAGES[@]}"; do
  docker push $image:$DOCKER_CACHE_TAG || true
done
