#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

export LOCAL_DEV=true
./build-local-dev.sh

cd $ROOT_DIR/../dams-local-dev
docker compose watch