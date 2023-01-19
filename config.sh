#! /bin/bash

######### MAIN CONFIG ##########
# Setup your application deployment here
################################

# Grab build number is mounted in CI system
if [[ -f /config/.buildenv ]]; then
  source /config/.buildenv
else
  BUILD_NUM=-1
fi

# Main version number we are tagging the app with. Always update
# this when you cut a new version of the app!
APP_TAG=v2.0.0-alpha
APP_VERSION=${APP_TAG}.${BUILD_NUM}

FIN_REPO_TAG=sandbox
DAMS_REPO_TAG=sandbox

#### End main config ####


# Repositories
GITHUB_ORG_URL=https://github.com/UCDavisLibrary

## Core Server
FIN_SERVER_REPO_NAME=fin
FIN_SERVER_REPO_URL=$GITHUB_ORG_URL/$FIN_SERVER_REPO_NAME

UCD_DAMS_REPO_NAME=dams
UCD_DAMS_REPO_URL=https://github.com/ucd-library/$UCD_DAMS_REPO_NAME

##
# Registery
##

if [[ -z $A6T_REG_HOST ]]; then
  A6T_REG_HOST=gcr.io/ucdlib-pubreg

  # set local-dev tags used by 
  # local development docker-compose file
  if [[ $LOCAL_DEV == 'true' ]]; then
    A6T_REG_HOST=localhost/local-dev
  fi
fi

DOCKER_CACHE_TAG=latest

# Docker Images
FCREPO_IMAGE_NAME=$A6T_REG_HOST/fin-fcrepo
POSTGRES_IMAGE_NAME=$A6T_REG_HOST/fin-postgres
SERVER_IMAGE_NAME=$A6T_REG_HOST/fin-service
UCD_DAMS_SERVER_IMAGE_NAME=$A6T_REG_HOST/ucd-lib-dams-service
LORIS_IMAGE_NAME=$A6T_REG_HOST/fin-loris
ELASTIC_SEARCH_IMAGE_NAME=$A6T_REG_HOST/fin-elastic-search
TESSERACT_IMAGE_NAME=$A6T_REG_HOST/fin-tesseract
INIT_IMAGE_NAME=$A6T_REG_HOST/fin-init
UCD_DAMS_INIT_IMAGE_NAME=$A6T_REG_HOST/ucd-lib-dams-init
KEYCLOAK_IMAGE_NAME=$A6T_REG_HOST/ucd-lib-dams-keycloak-dev

ALL_DOCKER_BUILD_IMAGES=( \
 $FCREPO_IMAGE_NAME $POSTGRES_IMAGE_NAME $ELASTIC_SEARCH_IMAGE_NAME \
 $SERVER_IMAGE_NAME $LORIS_IMAGE_NAME $TESSERACT_IMAGE_NAME \
 $INIT_IMAGE_NAME 
)

# Git
GIT=git
GIT_CLONE="$GIT clone"

ALL_GIT_REPOSITORIES=( \
 $FIN_SERVER_REPO_NAME $UCD_DAMS_REPO_NAME
)

# directory we are going to cache our various git repos at different tags
# if using pull.sh or the directory we will look for repositories (can by symlinks)
# if local development
REPOSITORY_DIR=repositories