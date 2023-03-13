#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..
source config.sh

echo -e "Starting docker build\n"

echo "Using base Fin images:"
echo "Fin - Init: $INIT_IMAGE_NAME:$FIN_TAG"
echo "Fin - Base Service: $SERVER_IMAGE_NAME:$FIN_TAG"
echo -e "\nBuilding images:"
echo "UCD DAMS - Init: $UCD_DAMS_INIT_IMAGE_NAME:$APP_TAG"
echo "UCD DAMS - Base Service: $LORIS_IMAGE_NAME:$APP_TAG"
echo "UCD DAMS - Loris: $UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG"
echo -e "UCD DAMS - Image Utils: $IMAGE_UTILS_IMAGE_NAME:$APP_TAG\n"

# UCD DAMS - Init Service
docker build \
  -t $UCD_DAMS_INIT_IMAGE_NAME:$APP_TAG \
  --build-arg INIT_BASE=$INIT_IMAGE_NAME:$FIN_TAG \
  --build-arg FIN_SERVER_IMAGE=${SERVER_IMAGE_NAME}:${FIN_TAG} \
  --cache-from $UCD_DAMS_INIT_IMAGE_NAME:$DOCKER_CACHE_TAG \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/init

# UCD DAMS - Main service image
docker build \
  --build-arg UCD_DAMS_SERVER_REPO_TAG=${UCD_DAMS_SERVER_REPO_TAG} \
  --build-arg UCD_DAMS_SERVER_REPO_HASH=${UCD_DAMS_SERVER_REPO_HASH} \
  --build-arg FIN_SERVER_IMAGE=${SERVER_IMAGE_NAME}:${FIN_TAG} \
  -t $UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG \
  --cache-from $UCD_DAMS_SERVER_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -f $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/fin/Dockerfile \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME

# DAMS - Loris Service
docker build \
  --build-arg FIN_REPO_TAG=${FIN_REPO_TAG} \
  --build-arg FIN_SERVER_REPO_HASH=${FIN_SERVER_REPO_HASH} \
  -t $LORIS_IMAGE_NAME:$APP_TAG \
  --cache-from $LORIS_IMAGE_NAME:$DOCKER_CACHE_TAG \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/loris

# DAMS - Image Utils Service
docker build \
  --build-arg FIN_SERVER_IMAGE=${SERVER_IMAGE_NAME}:${FIN_TAG} \
  -t $IMAGE_UTILS_IMAGE_NAME:$APP_TAG \
  --cache-from $IMAGE_UTILS_IMAGE_NAME:$DOCKER_CACHE_TAG \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/image-utils
