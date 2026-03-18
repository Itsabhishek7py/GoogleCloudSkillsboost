#!/bin/bash

# Color codes for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Welcome message
echo -e "${PURPLE}==================================================${NC}"
echo -e "${GREEN}🚀 WELCOME TO GKE GEMINI DEMO TUTORIAL${NC}"
echo -e "${PURPLE}==================================================${NC}"
echo -e "${YELLOW}📺 Presented by: Dr. Abhishek${NC}"
echo -e "${YELLOW}🔥 Don't forget to LIKE, SHARE & SUBSCRIBE!${NC}"
echo -e "${PURPLE}==================================================${NC}\n"

# Prompt user for region input
echo -e "${BLUE}Please enter the GCP region you want to use (e.g., us-central1, us-west1, europe-west1):${NC}"
read -p "Region: " REGION
export REGION=$REGION
echo -e "${GREEN}✓ Region set to: $REGION${NC}\n"

PROJECT_ID=$(gcloud config get-value project)

echo -e "${CYAN}📊 Project Information:${NC}"
echo -e "${GREEN}PROJECT_ID=${PROJECT_ID}${NC}"
echo -e "${GREEN}REGION=${REGION}${NC}"

USER=$(gcloud config get-value account 2> /dev/null)
echo -e "${GREEN}USER=${USER}${NC}\n"

echo -e "${YELLOW}⚙️ Enabling required APIs...${NC}"
gcloud services enable cloudaicompanion.googleapis.com --project ${PROJECT_ID}
echo -e "${GREEN}✓ APIs enabled successfully${NC}\n"

echo -e "${YELLOW}🔐 Setting up IAM permissions...${NC}"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member user:${USER} --role=roles/cloudaicompanion.user
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member user:${USER} --role=roles/serviceusage.serviceUsageViewer
echo -e "${GREEN}✓ IAM permissions configured${NC}\n"

echo -e "${YELLOW}☸️ Creating GKE Auto-pilot cluster in $REGION...${NC}"
gcloud container clusters create-auto gemini-demo --region $REGION
echo -e "${GREEN}✓ GKE cluster created successfully${NC}\n"

echo -e "${YELLOW}📦 Deploying hello-server application...${NC}"
kubectl create deployment hello-server --image=us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0
echo -e "${GREEN}✓ Application deployed${NC}\n"

echo -e "${YELLOW}🌐 Exposing deployment as LoadBalancer...${NC}"
kubectl expose deployment hello-server --type LoadBalancer --port 80 --target-port 8080
echo -e "${GREEN}✓ Service exposed${NC}\n"

echo -e "${PURPLE}==================================================${NC}"
echo -e "${GREEN}🎉 DEPLOYMENT COMPLETE! 🎉${NC}"
echo -e "${PURPLE}==================================================${NC}"
echo -e "${YELLOW}📝 Getting service details...${NC}"
kubectl get service hello-server

echo -e "\n${CYAN}📺 Thank you for watching Dr. Abhishek's tutorial!${NC}"
echo -e "${GREEN}👍 If you found this helpful, please:${NC}"
echo -e "${YELLOW}   👍 Like this video${NC}"
echo -e "${YELLOW}   💬 Share with your friends${NC}"
echo -e "${YELLOW}   🔔 Subscribe to the channel${NC}"
echo -e "${YELLOW}   📲 Hit the bell icon for updates${NC}"
echo -e "\n${PURPLE}==================================================${NC}"
echo -e "${BLUE}📺 YouTube Channel:${NC}"
echo -e "${RED}https://www.youtube.com/@drabhishek.5460/videos${NC}"
echo -e "${PURPLE}==================================================${NC}\n"

echo -e "${CYAN}💡 Pro Tip: Wait 2-3 minutes for the LoadBalancer to get an external IP${NC}"
echo -e "${CYAN}   Then access your app using the EXTERNAL-IP shown above${NC}"
