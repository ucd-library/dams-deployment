#! /bin/bash

ENVIRONMENT=$1

ALLOWED_ENVIRONMENTS=("dev" "prod")

if [[ ! " ${ALLOWED_ENVIRONMENTS[@]} " =~ " ${ENVIRONMENT} " ]]; then
  echo "Error: Invalid environment. Allowed environments are: ${ALLOWED_ENVIRONMENTS[@]}"
  echo "Usage: $0 <environment>"
  exit 1
fi

cork-kube restart $ENVIRONMENT \
  -p dams \
  -g fin