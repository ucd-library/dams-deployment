#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR/..
source config.sh

UCD_DAMS_REPO_BRANCH=$(git -C $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME rev-parse --abbrev-ref HEAD)
UCD_DAMS_REPO_TAG=$(git -C $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME tag --points-at HEAD)
UCD_DAMS_REPO_SHA=$(git -C $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME log -1 --pretty=%h)

DOCKER="docker"
DOCKER_BUILD="$DOCKER buildx build --output=type=docker --cache-to=type=inline,mode=max "
if [[ $LOCAL_DEV != 'true' ]]; then
  DOCKER_BUILD="$DOCKER_BUILD --pull "
fi
DOCKER_PUSH="$DOCKER push "

echo -e "Starting docker build\n"

echo "DAMS Repository:"
echo "Branch: $UCD_DAMS_REPO_BRANCH"
echo "Tag: $UCD_DAMS_REPO_TAG"
echo -e "SHA: $UCD_DAMS_REPO_SHA\n"

echo "DAMS Deployment Repository:"
echo "Branch: $UCD_DAMS_DEPLOYMENT_BRANCH"
echo "Tag: $UCD_DAMS_DEPLOYMENT_TAG"
echo -e "SHA: $UCD_DAMS_DEPLOYMENT_SHA\n"

echo "Using base Fin images:"
echo    "Fin - Init              : $INIT_IMAGE_NAME:$FIN_TAG"
echo    "Fin - Fcrepo            : $FCREPO_IMAGE_NAME:$FIN_TAG"
echo    "Fin - Base Service      : $SERVER_IMAGE_NAME:$FIN_TAG"
echo -e "\nBuilding images:"
echo    "UCD DAMS - Init         : $UCD_DAMS_INIT_IMAGE_NAME:$APP_TAG and :$DOCKER_CACHE_TAG"
echo    "UCD DAMS - IIP Server   : $IIIF_IMAGE_NAME:$APP_TAG and :$DOCKER_CACHE_TAG"
echo    "UCD DAMS - Base Service : $UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG and :$DOCKER_CACHE_TAG"
echo -e "UCD DAMS - Image Utils  : $IMAGE_UTILS_IMAGE_NAME:$APP_TAG and :$DOCKER_CACHE_TAG\n"

# UCD DAMS - Init Service
$DOCKER_BUILD \
  -t $UCD_DAMS_INIT_IMAGE_NAME:$APP_TAG \
  -t $UCD_DAMS_INIT_IMAGE_NAME:$DOCKER_CACHE_TAG \
  --build-arg FIN_INIT=$INIT_IMAGE_NAME:$FIN_TAG \
  --cache-from $UCD_DAMS_INIT_IMAGE_NAME:$DOCKER_CACHE_TAG \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/init
if [[ $LOCAL_DEV != 'true' ]]; then
  $DOCKER_PUSH $UCD_DAMS_INIT_IMAGE_NAME:$APP_TAG
  $DOCKER_PUSH $UCD_DAMS_INIT_IMAGE_NAME:$DOCKER_CACHE_TAG
fi

# UCD DAMS - Main service image
$DOCKER_BUILD \
  --build-arg APP_VERSION=$APP_VERSION \
  --build-arg BUILD_NUM=${BUILD_NUM} \
  --build-arg UCD_DAMS_REPO_BRANCH=${UCD_DAMS_REPO_BRANCH} \
  --build-arg UCD_DAMS_REPO_TAG=${UCD_DAMS_REPO_TAG} \
  --build-arg UCD_DAMS_REPO_SHA=${UCD_DAMS_REPO_SHA} \
  --build-arg UCD_DAMS_DEPLOYMENT_SHA=${UCD_DAMS_DEPLOYMENT_SHA} \
  --build-arg UCD_DAMS_DEPLOYMENT_BRANCH=${UCD_DAMS_DEPLOYMENT_BRANCH} \
  --build-arg UCD_DAMS_DEPLOYMENT_TAG=${UCD_DAMS_DEPLOYMENT_TAG} \
  --build-arg FIN_SERVER_IMAGE=${SERVER_IMAGE_NAME}:${FIN_TAG} \
  -t $UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG \
  -t $UCD_DAMS_SERVER_IMAGE_NAME:$DOCKER_CACHE_TAG \
  --cache-from $UCD_DAMS_SERVER_IMAGE_NAME:$DOCKER_CACHE_TAG \
  -f $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/fin/Dockerfile \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME
if [[ $LOCAL_DEV != 'true' ]]; then
  $DOCKER_PUSH $UCD_DAMS_SERVER_IMAGE_NAME:$APP_TAG
  $DOCKER_PUSH $UCD_DAMS_SERVER_IMAGE_NAME:$DOCKER_CACHE_TAG
fi

# DAMS - Image Utils Service
$DOCKER_BUILD \
  --build-arg FIN_SERVER_IMAGE=${SERVER_IMAGE_NAME}:${FIN_TAG} \
  -t $IMAGE_UTILS_IMAGE_NAME:$APP_TAG \
  -t $IMAGE_UTILS_IMAGE_NAME:$DOCKER_CACHE_TAG \
  --cache-from $IMAGE_UTILS_IMAGE_NAME:$DOCKER_CACHE_TAG \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/image-utils
if [[ $LOCAL_DEV != 'true' ]]; then
  $DOCKER_PUSH $IMAGE_UTILS_IMAGE_NAME:$APP_TAG
  $DOCKER_PUSH $IMAGE_UTILS_IMAGE_NAME:$DOCKER_CACHE_TAG
fi

# DAMS - IIP Server
$DOCKER_BUILD \
  -t $IIIF_IMAGE_NAME:$APP_TAG \
  -t $IIIF_IMAGE_NAME:$DOCKER_CACHE_TAG \
  --cache-from $IIIF_IMAGE_NAME:$DOCKER_CACHE_TAG \
  $REPOSITORY_DIR/$UCD_DAMS_REPO_NAME/services/iipimage
if [[ $LOCAL_DEV != 'true' ]]; then
  $DOCKER_PUSH $IIIF_IMAGE_NAME:$APP_TAG
  $DOCKER_PUSH $IIIF_IMAGE_NAME:$DOCKER_CACHE_TAG
fi
