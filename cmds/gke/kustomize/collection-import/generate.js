const fs = require('fs');
const path = require('path');
const dir = path.join(__dirname, 'overlays');

// collection name to volume size mapping
// get size via: gsutil du -sh gs://dams-collections-binary-backups/[collection-name]/
const COLLECTIONS = require('./collections.json');

let JOB_TEMPLATE = `apiVersion: batch/v1
kind: Job
metadata:
  name: import-{{collection}}
spec:
  template:
    spec:
      containers:
      - name: importer
        env:
          - name: COLLECTION_NAME
            value: {{collection}}
        volumeMounts:
        - name: import-volume
          mountPath: /data
      volumes:
      - name: import-volume
        persistentVolumeClaim:
          claimName: import-{{collection}}-volume-claim`;

let VOLUME_TEMPLATE = `kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: import-{{collection}}-volume-claim
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: standard-rwo
  resources:
    requests:
      storage: {{size}}`;

let KUSTOMIZATION_TEMPLATE = `apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
- volume.yaml
- ../../base

patches:
  - path: job.yaml
    target:
      kind: Job
      name: import
    options:
      allowNameChange: true`;

for( let collection in COLLECTIONS) {
  let args = {collection, size: COLLECTIONS[collection]}

  let job = render(args, JOB_TEMPLATE);
  let volume = render(args, VOLUME_TEMPLATE);
  let kustomization = render(args, KUSTOMIZATION_TEMPLATE);

  if( !fs.existsSync(path.join(dir, collection))) { 
    fs.mkdirSync(path.join(dir, collection)); 
  }

  fs.writeFileSync(path.join(dir, collection, 'job.yaml'), job);
  fs.writeFileSync(path.join(dir, collection, 'volume.yaml'), volume);
  fs.writeFileSync(path.join(dir, collection, 'kustomization.yaml'), kustomization);
}

function render(args, template) {
  for( let key in args) {
    template = template.replace(new RegExp(`{{${key}}}`, 'g'), args[key]);
  }
  return template;
}