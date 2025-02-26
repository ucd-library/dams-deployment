#! /bin/bash

DEPTH=$1
VERSION=$2
if [[ ! -z "$DEPTH" ]]; then
  DEPTH="--depth $DEPTH"
fi
if [[ -z "$VERSION" ]]; then
  VERSION="sandbox"
fi

docker pull redis:3.2


cork-kube build exec \
  -p dams \
  -v $VERSION \
  --no-cache-from \
  -o sandbox $DEPTH 