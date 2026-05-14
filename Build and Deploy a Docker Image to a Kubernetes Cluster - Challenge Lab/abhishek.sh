#!/bin/bash

# Define color variables
BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

# Welcome message
echo "${BG_MAGENTA}${BOLD}Welcome to Dr. Abhishek's Cloud Tutorials${RESET}"
echo

# Function to validate zone format
validate_zone() {
  local zone=$1
  if [[ "$zone" =~ ^[a-z]+-[a-z]+[0-9]-[a-z]$ ]]; then
    return 0
  else
    return 1
  fi
}

# Prompt user for zone input
echo "${CYAN}${BOLD}Step 1: Set the zone for your GKE cluster${RESET}"
echo "${YELLOW}Please enter your preferred zone (e.g., us-central1-a):${RESET}"
read -p "Zone: " ZONE

# Validate zone input
while ! validate_zone "$ZONE"; do
  echo "${RED}${BOLD}Invalid zone format. Please enter a valid zone (e.g., us-central1-a)${RESET}"
  read -p "Zone: " ZONE
done

export ZONE
REGION="${ZONE%-*}"
export REGION

echo
echo "${GREEN}${BOLD}✅ Using Zone: ${WHITE}${BOLD}$ZONE${RESET}"
echo "${GREEN}${BOLD}✅ Derived Region: ${WHITE}${BOLD}$REGION${RESET}"
echo

# Start execution
echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"
echo

# Create GKE cluster
echo "${BLUE}${BOLD}Creating GKE cluster 'echo-cluster' in zone $ZONE...${RESET}"
gcloud beta container --project "$DEVSHELL_PROJECT_ID" clusters create "echo-cluster" \
--zone "$ZONE" \
--no-enable-basic-auth \
--cluster-version "latest" \
--release-channel "regular" \
--machine-type "e2-standard-2" \
--image-type "COS_CONTAINERD" \
--disk-type "pd-balanced" \
--disk-size "100" \
--metadata disable-legacy-endpoints=true \
--scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
--num-nodes "3" \
--logging=SYSTEM,WORKLOAD \
--monitoring=SYSTEM \
--enable-ip-alias \
--network "projects/$DEVSHELL_PROJECT_ID/global/networks/default" \
--subnetwork "projects/$DEVSHELL_PROJECT_ID/regions/$REGION/subnetworks/default" \
--no-enable-intra-node-visibility \
--default-max-pods-per-node "110" \
--security-posture=standard \
--workload-vulnerability-scanning=disabled \
--no-enable-master-authorized-networks \
--addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver \
--enable-autoupgrade \
--enable-autorepair \
--max-surge-upgrade 1 \
--max-unavailable-upgrade 0 \
--enable-managed-prometheus \
--enable-shielded-nodes \
--node-locations "$ZONE"

echo
echo "${GREEN}${BOLD}✅ GKE cluster created successfully${RESET}"
echo

# Get project ID
export PROJECT_ID=$(gcloud info --format='value(config.project)')
echo "${BLUE}${BOLD}Using Project ID: ${WHITE}${BOLD}$PROJECT_ID${RESET}"

# Download and extract application files
gcloud auth configure-docker
echo
echo "${BLUE}${BOLD}Downloading application files...${RESET}"
gsutil cp gs://${PROJECT_ID}/echo-web.tar.gz .
tar -xvzf echo-web.tar.gz

# Build and push Docker image
echo
echo "${BLUE}${BOLD}Building and pushing Docker image...${RESET}"
cd echo-web
docker build -t echo-app:v1 .
docker tag echo-app:v1 gcr.io/${PROJECT_ID}/echo-app:v1
docker push gcr.io/${PROJECT_ID}/echo-app:v1

# Deploy to GKE
echo
echo "${BLUE}${BOLD}Deploying application to GKE cluster...${RESET}"
gcloud container clusters get-credentials echo-cluster --zone=$ZONE
kubectl create deployment echo-app --image=gcr.io/${PROJECT_ID}/echo-app:v1

# Expose the deployment
echo
echo "${BLUE}${BOLD}Creating service for the deployment...${RESET}"
kubectl expose deployment echo-app --name echo-web \
   --type LoadBalancer --port 80 --target-port 8000

# Get service details
echo
echo "${BLUE}${BOLD}Getting service details...${RESET}"
kubectl get service echo-web

# Completion message
echo
echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"
echo
echo "${MAGENTA}${BOLD}If you found this helpful, subscribe to my channel:${RESET}"
echo "${BLUE}${BOLD}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
