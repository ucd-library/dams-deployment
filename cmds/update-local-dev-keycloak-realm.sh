#! /bin/bash

set -e
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# grab the latest realm config
cd $ROOT_DIR/../keycloak
gcloud secrets versions access latest \
  --secret=dams-local-dev-keycloak-realm --format json | \
  jq -r .payload.data | \
  base64 --decode > dams-local-dev-keycloak-realm.zip
unzip dams-local-dev-keycloak-realm.zip
rm dams-local-dev-keycloak-realm.zip