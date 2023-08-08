#! /bin/bash

###
# download the local dev env from the secret manager
###

set -e
CMDS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $CMDS_DIR/..

if [ ! -d "./dams-local-dev" ]; then
  mkdir ./dams-local-dev
fi

gcloud secrets versions access latest --secret=dams-v2-local-dev-env > ./dams-local-dev/.env
