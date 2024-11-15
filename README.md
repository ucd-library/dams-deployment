# dams-deployment
UC Davis Library DAMS Deployment


## Local Development

1. Install dependencies if you haven't already:  
  jq - `brew install jq`  
  cork-template - `npm install @ucd-lib/cork-template -g`
2. Git clone this repository, [fin](https://github.com/ucd-library/fin), and [dams](https://github.com/ucd-library/dams). They should all have the same parent directory.
3. `./cmds/init-local-dev.sh`
4. `./cmds/generate-deployment-files.sh`
5. `./cmds/get-local-dev-env.sh` and `./cmds/get-service-account.sh` - you might have to request access from a digital-ucdavis GC admin.
6. `./cmds/build-local-dev.sh`
7. Make sure `FIN_TAG` and `DAMS_REPO_TAG` are set to what you want - probably 'sandbox'
8. `cd dams-local-dev && docker compose up`
