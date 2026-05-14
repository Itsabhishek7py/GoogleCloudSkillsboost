#!/bin/bash
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

# Spinner function
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

clear
echo "${BG_MAGENTA}${BOLD}Welcome to Dr Abhishek Cloud Tutorials${RESET}"
echo "${CYAN}Subscribe to the channel: https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo

# Check if zone is already set
if [ -z "$ZONE" ]; then
  echo "${YELLOW}${BOLD}No default zone configured.${RESET}"
  echo "${BLUE}Available zones:${RESET}"
  gcloud compute zones list --format="value(name)" | sort
  echo
  read -p "${CYAN}${BOLD}Enter your zone (e.g., us-central1-a): ${RESET}" ZONE
  export ZONE
  echo "${GREEN}${BOLD}Zone set to: $ZONE${RESET}"
else
  echo "${GREEN}${BOLD}Using pre-configured zone: $ZONE${RESET}"
  echo "${YELLOW}To change zone, run: export ZONE=your-new-zone${RESET}"
fi
echo

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"
echo

# Step 1: Download files
echo "${BLUE}${BOLD}Step 1: Downloading application files...${RESET}"
gsutil cp gs://$DEVSHELL_PROJECT_ID/echo-web-v2.tar.gz . & spinner
echo "${GREEN}Download complete!${RESET}"
echo

# Step 2: Extract files
echo "${BLUE}${BOLD}Step 2: Extracting application files...${RESET}"
tar -xzvf echo-web-v2.tar.gz & spinner
echo "${GREEN}Extraction complete!${RESET}"
echo

# Step 3: Build container
echo "${BLUE}${BOLD}Step 3: Building container image...${RESET}"
gcloud builds submit --tag gcr.io/$DEVSHELL_PROJECT_ID/echo-app:v2 . & spinner
echo "${GREEN}Build complete!${RESET}"
echo

# Step 4: Get cluster credentials
echo "${BLUE}${BOLD}Step 4: Connecting to GKE cluster...${RESET}"
gcloud container clusters get-credentials echo-cluster --zone=$ZONE & spinner
echo "${GREEN}Cluster connection established!${RESET}"
echo

# Step 5: Create deployment
echo "${BLUE}${BOLD}Step 5: Creating deployment...${RESET}"
kubectl create deployment echo-web --image=gcr.io/qwiklabs-resources/echo-app:v2 & spinner
echo "${GREEN}Deployment created!${RESET}"
echo

# Step 6: Expose service
echo "${BLUE}${BOLD}Step 6: Exposing service...${RESET}"
kubectl expose deployment echo-web --type=LoadBalancer --port 80 --target-port 8000 & spinner
echo "${GREEN}Service exposed!${RESET}"
echo

# Step 7: Scale deployment
echo "${BLUE}${BOLD}Step 7: Scaling deployment...${RESET}"
kubectl scale deploy echo-web --replicas=2 & spinner
echo "${GREEN}Deployment scaled to 2 replicas!${RESET}"
echo

# Get service URL
echo "${BLUE}${BOLD}Getting service URL...${RESET}"
SERVICE_IP=$(kubectl get service echo-web -o jsonpath='{.status.loadBalancer.ingress[0].ip}' --watch=false)
while [ -z "$SERVICE_IP" ]; do
  echo "${YELLOW}Waiting for external IP...${RESET}"
  sleep 5
  SERVICE_IP=$(kubectl get service echo-web -o jsonpath='{.status.loadBalancer.ingress[0].ip}' --watch=false)
done
echo "${GREEN}Your application is now available at: http://$SERVICE_IP${RESET}"
echo

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"
echo
echo "${MAGENTA}${BOLD}Don't forget to subscribe to Dr Abhishek's channel:${RESET}"
echo "${BLUE}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo
