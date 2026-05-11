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

while true; do
  STATUS=$(gcloud compute instances describe gcelab \
    --zone "$ZONE" \
    --format='get(status)')
  echo "VM gcelab Current status: $STATUS"
  if [ "$STATUS" = "RUNNING" ]; then
    echo "VM gcelab is running!"
    break
  fi
  sleep 5
done

gcloud compute ssh \
  --zone "$ZONE" "gcelab" \
  --project "$PROJECT_ID" \
  --quiet \
  --command "sudo apt-get update && sudo apt-get install -y nginx && ps auwx | grep nginx"

gcloud compute instances create gcelab2 \
  --project="$PROJECT_ID" \
  --zone=$ZONE \
  --machine-type e2-medium

EXTERNAL_IP=$(gcloud compute instances describe gcelab \
  --zone "$ZONE" \
  --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo
echo "============================================"
echo "Task 2. Install an NGINX web server"
echo "  Check http://$EXTERNAL_IP"
echo "  A default web page should open that says: Welcome to nginx!"
echo "============================================"
