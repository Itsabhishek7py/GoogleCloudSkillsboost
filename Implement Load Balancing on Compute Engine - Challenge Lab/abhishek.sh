#!/bin/bash

# Enhanced Color Definitions
BLACK=$'\033[0;90m'
RED=$'\033[0;91m'
GREEN=$'\033[0;92m'
YELLOW=$'\033[0;93m'
BLUE=$'\033[0;94m'
MAGENTA=$'\033[0;95m'
CYAN=$'\033[0;96m'
WHITE=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET=$'\033[0m'
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'

# Header Section
echo "${CYAN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${CYAN}${BOLD}         WELCOME TO DR ABHISHEK CLOUD TUTORIAL         ${RESET}"
echo "${CYAN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${MAGENTA}${BOLD}          Expert Tutorial by Dr. Abhishek              ${RESET}"
echo "${YELLOW}For more GCP tutorials, visit: ${UNDERLINE}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
echo "${BLUE}${BOLD}⚡ Initializing GCP Infrastructure Setup...${RESET}"
echo

# User Input Section
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ INPUT PARAMETERS ▬▬▬▬▬▬▬▬▬${RESET}"
read -p "${YELLOW}${BOLD}Enter INSTANCE_NAME: ${RESET}" INSTANCE_NAME
read -p "${YELLOW}${BOLD}Enter FIREWALL_RULE: ${RESET}" FIREWALL_RULE
export INSTANCE_NAME FIREWALL_RULE
echo
echo "${CYAN}Configuration Parameters:${RESET}"
echo "${WHITE}Instance Name: ${BOLD}$INSTANCE_NAME${RESET}"
echo "${WHITE}Firewall Rule: ${BOLD}$FIREWALL_RULE${RESET}"
echo

# Authentication Check
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ AUTHENTICATION CHECK ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Checking authenticated accounts...${RESET}"
gcloud auth list
echo "${GREEN}✅ Authentication check complete!${RESET}"
echo

# Environment Configuration
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ ENVIRONMENT SETUP ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Setting up default zone, region, and project...${RESET}"
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export PORT=8082
export REGION="${ZONE%-*}"
gcloud config set project $DEVSHELL_PROJECT_ID
gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION
echo "${GREEN}✅ Environment configured!${RESET}"
echo

# Network Setup
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ NETWORK CONFIGURATION ▬▬▬▬▬▬▬▬▬${RESET}"

echo "${YELLOW}Creating VPC network...${RESET}"
gcloud compute networks create nucleus-vpc --subnet-mode=auto
echo "${GREEN}✅ VPC network created!${RESET}"
echo

# Instance Creation
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ INSTANCE SETUP ▬▬▬▬▬▬▬▬▬${RESET}"

echo "${YELLOW}Creating compute instance...${RESET}"
gcloud compute instances create $INSTANCE_NAME \
  --network nucleus-vpc \
  --zone $ZONE \
  --machine-type e2-micro \
  --image-family debian-12 \
  --image-project debian-cloud
echo "${GREEN}✅ Compute instance created!${RESET}"
echo

echo "${YELLOW}Creating startup script...${RESET}"
cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF
echo "${GREEN}✅ Startup script created!${RESET}"
echo

# Load Balancer Setup
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ LOAD BALANCER CONFIGURATION ▬▬▬▬▬▬▬▬▬${RESET}"

echo "${YELLOW}Creating instance template...${RESET}"
gcloud compute instance-templates create web-server-template \
  --region=$ZONE \
  --machine-type e2-medium \
  --metadata-from-file startup-script=startup.sh \
  --network nucleus-vpc
echo "${GREEN}✅ Instance template created!${RESET}"

echo "${YELLOW}Creating target pool...${RESET}"
gcloud compute target-pools create nginx-pool --region=$REGION
echo "${GREEN}✅ Target pool created!${RESET}"

echo "${YELLOW}Creating managed instance group...${RESET}"
gcloud compute instance-groups managed create web-server-group \
  --region=$REGION \
  --base-instance-name web-server \
  --size 2 \
  --template web-server-template
echo "${GREEN}✅ Managed instance group created!${RESET}"
echo

# Firewall Configuration
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ FIREWALL SETUP ▬▬▬▬▬▬▬▬▬${RESET}"

echo "${YELLOW}Creating firewall rule...${RESET}"
gcloud compute firewall-rules create $FIREWALL_RULE \
  --network nucleus-vpc \
  --allow tcp:80
echo "${GREEN}✅ Firewall rule created!${RESET}"
echo

# Health Check Setup
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ HEALTH CHECK CONFIGURATION ▬▬▬▬▬▬▬▬▬${RESET}"

echo "${YELLOW}Creating HTTP health check...${RESET}"
gcloud compute http-health-checks create http-basic-check
echo "${GREEN}✅ HTTP health check created!${RESET}"

echo "${YELLOW}Setting named ports...${RESET}"
gcloud compute instance-groups managed set-named-ports web-server-group \
  --region=$REGION \
  --named-ports http:80
echo "${GREEN}✅ Named ports configured!${RESET}"
echo

# Backend Service Setup
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ BACKEND SERVICE SETUP ▬▬▬▬▬▬▬▬▬${RESET}"

echo "${YELLOW}Creating backend service...${RESET}"
gcloud compute backend-services create web-server-backend \
  --protocol HTTP \
  --http-health-checks http-basic-check \
  --global
echo "${GREEN}✅ Backend service created!${RESET}"

echo "${YELLOW}Adding backend to service...${RESET}"
gcloud compute backend-services add-backend web-server-backend \
  --instance-group web-server-group \
  --instance-group-region $REGION \
  --global
echo "${GREEN}✅ Backend added to service!${RESET}"
echo

# Load Balancer Finalization
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ LOAD BALANCER FINALIZATION ▬▬▬▬▬▬▬▬▬${RESET}"

echo "${YELLOW}Creating URL map...${RESET}"
gcloud compute url-maps create web-server-map \
  --default-service web-server-backend
echo "${GREEN}✅ URL map created!${RESET}"

echo "${YELLOW}Creating target HTTP proxy...${RESET}"
gcloud compute target-http-proxies create http-lb-proxy \
  --url-map web-server-map
echo "${GREEN}✅ Target HTTP proxy created!${RESET}"

echo "${YELLOW}Creating forwarding rules...${RESET}"
gcloud compute forwarding-rules create http-content-rule \
  --global \
  --target-http-proxy http-lb-proxy \
  --ports 80
gcloud compute forwarding-rules create $FIREWALL_RULE \
  --global \
  --target-http-proxy http-lb-proxy \
  --ports 80
echo "${GREEN}✅ Forwarding rules created!${RESET}"

echo "${YELLOW}Listing all forwarding rules...${RESET}"
gcloud compute forwarding-rules list
echo "${GREEN}✅ Forwarding rules listed!${RESET}"
echo

# Completion Message
echo "${GREEN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${GREEN}${BOLD}          SETUP COMPLETED SUCCESSFULLY!                  ${RESET}"
echo "${GREEN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${RED}${BOLD}🙏 Special thanks to Dr. Abhishek for this tutorial!${RESET}"
echo "${YELLOW}${BOLD}📺 Subscribe for more GCP content:${RESET}"
echo "${BLUE}${UNDERLINE}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
echo "${MAGENTA}${BOLD}🚀 Lab is done now!${RESET}"
