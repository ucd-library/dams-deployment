#! /bin/bash

DEPTH=$1
if [[ ! -z "$DEPTH" ]]; then
  DEPTH="--depth $DEPTH"
fi
cork-kube build exec \
  -p dams \
  -v sandbox \
  --no-cache-from \
  -o sandbox $DEPTH