# Google Cloud
GC_PROJECT_ID=ucdlib-dams
IMAGE_UTILS_CLOUD_RUN_SERVICE_NAME=dams-image-utils-$UCD_DAMS_DEPLOYMENT_BRANCH


GKE_CLUSTER_NAME=dams-prod
GKE_REGION=us-west1
GKE_CLUSTER_ZONE=${GKE_REGION}-b
GCS_BUCKET=dams-client-media-prod
GC_SA_NAME=dams-production@ucdlib-dams.iam.gserviceaccount.com
GKE_KSA_NAME=dams-production