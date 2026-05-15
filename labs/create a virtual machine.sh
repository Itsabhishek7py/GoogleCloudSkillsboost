#!/bin/bash

# Set colors for output
BG_RED='\033[41m'
BOLD='\033[1m'
RESET='\033[0m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'

# Get project information
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")

# Dr. Abhishek intro
echo -e "${GREEN}${BOLD} Welcome to  Dr. Abhishek Cloud${RESET}"
echo -e "${BLUE}Like, Share, and Subscribe for more cloud content!${RESET}\n"

# Task 1: Create first instance with NGINX
echo "Creating gcelab instance with NGINX..."
gcloud compute instances create gcelab \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata=enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --service-account=$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append \
    --tags=http-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=gcelab,image=projects/debian-cloud/global/images/debian-11-bullseye-v20241009,mode=rw,size=10,type=pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any \
    --metadata=startup-script='#! /bin/bash
    sudo apt-get update
    sudo apt-get install -y nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx'

# Task 2: Create second instance
echo "Creating gcelab2 instance..."
gcloud compute instances create gcelab2 \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --machine-type=e2-medium

# Configure firewall
echo "Configuring firewall rules..."
gcloud compute firewall-rules create allow-http \
    --network=default \
    --allow=tcp:80 \
    --target-tags=http-server

# Verification
echo -e "\n${GREEN}Verification:${RESET}"
gcloud compute instances list --filter="name:(gcelab gcelab2)"

echo -e "\n${BG_RED}${BOLD}Congratulations For Completing The Lab!${RESET}"
echo -e "${BLUE}Special thanks to Dr. Abhishek!${RESET}"
echo -e "${BOLD}Don't forget to Like, Share, and Subscribe https://www.youtube.com/@drabhishek.5460!${RESET}"
