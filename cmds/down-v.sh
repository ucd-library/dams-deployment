#! /bin/bash

set -e 
ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $ROOT_DIR/..

read -p "Are you sure you want to bring down the local-dev environment and drop volumes? (y/n): " confirm
if [[ $confirm != [yY] ]]; then
  echo "Operation cancelled."
  exit 1
fi

cork-kube down local-dev -v 

echo "Cleaning up ocfl-volumes dir..."
cd ocfl-volumes && rm -rf ./*