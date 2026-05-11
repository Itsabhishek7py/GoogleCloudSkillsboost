#!/bin/bash
## Changed by nov05, 2026-05-11  

echo
echo "============================================"
echo "           Starting Execution"
echo "============================================"
echo

export ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} \
    --format="value(projectNumber)")

gcloud compute firewall-rules create allow-http \
  --network=default \
  --allow=tcp:80 \
  --target-tags=http-server
  
gcloud compute instances create gcelab \
  --project="$PROJECT_ID" \
  --zone="$ZONE" \
  --machine-type=e2-medium \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --boot-disk-type=pd-balanced \
  --boot-disk-size=10GB \
  --tags=http-server \
  --metadata=enable-oslogin=true

gcloud compute ssh \
  --zone "$ZONE" "gcelab" \
  --project "$PROJECT_ID" \
  --quiet \
  --command "sudo apt-get update && sudo apt-get install -y nginx && ps auwx | grep nginx"

gcloud compute instances create gcelab2 \
  --project="$PROJECT_ID" \
  --zone=$ZONE \
  --machine-type e2-medium
