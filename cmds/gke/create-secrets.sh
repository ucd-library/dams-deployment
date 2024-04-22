#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $ROOT_DIR

SECRET_DIR=$ROOT_DIR/secrets
if [[ ! -d $SECRET_DIR ]]; then
  mkdir $SECRET_DIR
fi

source ../../config.sh
./setup-kubectl.sh

gcloud secrets versions access latest --secret=production-service-account > $SECRET_DIR/service-account.json
gcloud secrets versions access latest --secret=production-env > $SECRET_DIR/env
# gcloud secrets versions access latest --secret=ssl-dams-cert > $SECRET_DIR/ssl-dams.crt
# gcloud secrets versions access latest --secret=ssl-dams-key > $SECRET_DIR/ssl-dams.key

kubectl delete secret env || true
kubectl create secret generic env \
  --from-env-file=$SECRET_DIR/env

kubectl delete secret service-account || true
kubectl create secret generic service-account \
 --from-file=service-account.json=$SECRET_DIR/service-account.json || true

# kubectl delete secret dams-ssl || true
# kubectl create secret generic dams-ssl \
#  --from-file=ssl-dams.crt=$SECRET_DIR/ssl-dams.crt \
#  --from-file=ssl-dams.key=$SECRET_DIR/ssl-dams.key || true