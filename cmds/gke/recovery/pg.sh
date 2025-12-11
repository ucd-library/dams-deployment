#!/bin/bash

set -e

PG_VERSION=14
VM_NAME="dams-pg-recovery-vm"
LOCAL_PORT=5433
DATABASE=fcrepo
DUMP_FILE="fcrepo_backup.dump"
ZONE="us-west1-a"

SRC_DISK="pvc-1e0f5133-dc70-4ef9-90d8-40da064bc9f4"
RESTORED_DISK_NAME="pg-recovery-${SRC_DISK}-disk"

LATEST_SNAPSHOT=$(gcloud compute snapshots list --filter="sourceDisk ~ '${SRC_DISK}'" --sort-by="~creationTimestamp" --limit=1 --format="value(name)")

echo "Latest snapshot found: ${LATEST_SNAPSHOT} from source disk ${SRC_DISK}"

echo "All snapshots for source disk ${SRC_DISK}:"
gcloud compute snapshots list --filter="sourceDisk ~ '${SRC_DISK}'" --sort-by="~creationTimestamp" --format="table(name,creationTimestamp)"


echo "Creating a new disk from the latest snapshot..."
gcloud compute disks create ${RESTORED_DISK_NAME} \
  --zone=${ZONE} \
  --source-snapshot=${LATEST_SNAPSHOT} \
  --type=pd-standard \
  | true

echo "Creating and starting PostgreSQL VM instance ${VM_NAME}..."

gcloud compute instances create-with-container ${VM_NAME} \
  --zone=${ZONE} \
  --machine-type=e2-medium \
  --image-family=cos-stable \
  --image-project=cos-cloud \
  --boot-disk-size=20GB \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --tags=postgres \
  --disk=name=${RESTORED_DISK_NAME},device-name=${RESTORED_DISK_NAME},mode=rw,boot=no,auto-delete=no \
  --container-image=postgres:${PG_VERSION} \
  --container-restart-policy=always \
  --container-mount-disk=mount-path=/var/lib/postgresql/data,name=${RESTORED_DISK_NAME},mode=rw \
  --container-env=PGDATA=/var/lib/postgresql/data/pgdata | true

echo "Waiting for PostgreSQL VM to start..."

sleep 20

echo "Setting up SSH tunnel to PostgreSQL on VM ${VM_NAME}..."

gcloud compute ssh ${VM_NAME} \
  --zone=${ZONE} \
  -- -f -N -L ${LOCAL_PORT}:localhost:5432

echo "PostgreSQL is running on localhost:${LOCAL_PORT}"
echo "To stop and delete the PostgreSQL VM instance, run:"
echo "gcloud compute instances delete ${VM_NAME} --zone=${ZONE}"

echo "Dumping the database ${DATABASE} to file ${DUMP_FILE}..."

# dump the tunneled database
pg_dump -Fc -h localhost -p ${LOCAL_PORT} -U postgres -d ${DATABASE} > ${DUMP_FILE}
echo "Database dump saved to ${DUMP_FILE}"

echo "To restore the database from the dump file, use the following commands:"
echo "cork-kube pod port-forward [env] postgres 5434:5434"
echo "pg_restore --clean --if-exists -h localhost -p 5434 -U postgres -d ${DATABASE} ${DUMP_FILE}"

echo ""
echo "You might need to drop the database first if it already exists:"
echo "psql -h localhost -p 5434 -U postgres"
echo "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '${DATABASE}'; DROP DATABASE ${DATABASE}; CREATE DATABASE ${DATABASE};"