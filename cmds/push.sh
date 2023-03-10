#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR
source ../config.sh

docker push $FCREPO_IMAGE_NAME:$APP_TAG
docker tag $FCREPO_IMAGE_NAME:$APP_TAG $FCREPO_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $POSTGRES_IMAGE_NAME:$APP_TAG
docker tag $POSTGRES_IMAGE_NAME:$APP_TAG $POSTGRES_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $SERVER_IMAGE_NAME:$APP_TAG
docker tag $SERVER_IMAGE_NAME:$APP_TAG $SERVER_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $ELASTIC_SEARCH_IMAGE_NAME:$APP_TAG
docker tag $ELASTIC_SEARCH_IMAGE_NAME:$APP_TAG $ELASTIC_SEARCH_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $LORIS_IMAGE_NAME:$APP_TAG
docker tag $LORIS_IMAGE_NAME:$APP_TAG $LORIS_IMAGE_NAME:$DOCKER_CACHE_TAG

docker push $TESSERACT_IMAGE_NAME:$APP_TAG
docker tag $TESSERACT_IMAGE_NAME:$APP_TAG $TESSERACT_IMAGE_NAME:$DOCKER_CACHE_TAG

for image in "${ALL_DOCKER_BUILD_IMAGES[@]}"; do
  docker push $image:$DOCKER_CACHE_TAG || true
done
