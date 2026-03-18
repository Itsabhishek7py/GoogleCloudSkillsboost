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
echo -e "${PURPLE}=================================================================${NC}"
echo -e "${GREEN}🚀 WELCOME TO GKE MICROSERVICES DEMO TUTORIAL${NC}"
echo -e "${PURPLE}=================================================================${NC}"
echo -e "${YELLOW}📺 Presented by: Dr. Abhishek${NC}"
echo -e "${YELLOW}🔥 Don't forget to LIKE, SHARE & SUBSCRIBE!${NC}"
echo -e "${PURPLE}=================================================================${NC}\n"

# Prompt user for zone input
echo -e "${BLUE}Please enter the GCP zone you want to use (e.g., us-central1-a, us-west1-b, europe-west1-c):${NC}"
read -p "Zone: " ZONE
export ZONE=$ZONE
echo -e "${GREEN}✓ Zone set to: $ZONE${NC}\n"

# Export region derived from zone
export REGION=${ZONE%-*}
echo -e "${GREEN}✓ Region automatically set to: $REGION${NC}\n"

PROJECT_ID=$(gcloud config get-value project)

echo -e "${CYAN}📊 Project Information:${NC}"
echo -e "${GREEN}PROJECT_ID=${PROJECT_ID}${NC}"
echo -e "${GREEN}ZONE=${ZONE}${NC}"
echo -e "${GREEN}REGION=${REGION}${NC}"

USER=$(gcloud config get-value account 2> /dev/null)
echo -e "${GREEN}USER=${USER}${NC}\n"

echo -e "${YELLOW}⚙️ Enabling Cloud AI Companion API...${NC}"
gcloud services enable cloudaicompanion.googleapis.com --project ${PROJECT_ID}
echo -e "${GREEN}✓ Cloud AI Companion API enabled${NC}\n"

echo -e "${YELLOW}🔐 Setting up Cloud AI Companion IAM permissions...${NC}"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member user:${USER} --role=roles/cloudaicompanion.user
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member user:${USER} --role=roles/serviceusage.serviceUsageViewer
echo -e "${GREEN}✓ Cloud AI Companion IAM permissions configured${NC}\n"

echo -e "${YELLOW}⚙️ Enabling Kubernetes Engine API...${NC}"
gcloud services enable container.googleapis.com --project ${PROJECT_ID}
echo -e "${GREEN}✓ Kubernetes Engine API enabled${NC}\n"

echo -e "${YELLOW}🔐 Setting up Kubernetes Engine Admin permissions...${NC}"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member user:${USER} --role=roles/container.admin
echo -e "${GREEN}✓ Kubernetes Engine Admin permissions configured${NC}\n"

echo -e "${YELLOW}☸️ Creating GKE cluster 'test' in $ZONE...${NC}"
gcloud container clusters create test \
    --project=$PROJECT_ID \
    --zone=$ZONE \
    --num-nodes=3 \
    --machine-type=e2-standard-4
echo -e "${GREEN}✓ GKE cluster created successfully${NC}\n"

echo -e "${YELLOW}📦 Cloning microservices demo repository...${NC}"
git clone --depth=1 https://github.com/GoogleCloudPlatform/microservices-demo
echo -e "${GREEN}✓ Repository cloned${NC}\n"

echo -e "${YELLOW}🚀 Deploying microservices to GKE cluster...${NC}"
cd ~/microservices-demo
kubectl apply -f ./release/kubernetes-manifests.yaml
echo -e "${GREEN}✓ Microservices deployment initiated${NC}\n"

echo -e "${YELLOW}📊 Checking deployment status...${NC}"
kubectl get deployments
echo -e "${GREEN}✓ Deployments listed${NC}\n"

echo -e "${YELLOW}⏳ Waiting 30 seconds for services to initialize...${NC}"
sleep 30

echo -e "${CYAN}🌐 Frontend Service URL:${NC}"
FRONTEND_IP=$(kubectl get service frontend-external -o=jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
if [ -n "$FRONTEND_IP" ]; then
    echo -e "${GREEN}http://${FRONTEND_IP}${NC}"
else
    echo -e "${YELLOW}Waiting for external IP to be assigned...${NC}"
    echo -e "${YELLOW}Run this command later to get the URL:${NC}"
    echo -e "${BLUE}kubectl get service frontend-external${NC}"
fi
echo ""

echo -e "${YELLOW}🏗️ Creating Cloud Build worker pool...${NC}"
gcloud builds worker-pools create pool-test \
  --project=$PROJECT_ID \
  --region=$REGION \
  --no-public-egress
echo -e "${GREEN}✓ Cloud Build worker pool created${NC}\n"

echo -e "${YELLOW}📦 Creating Artifact Registry repository...${NC}"
gcloud artifacts repositories create my-repo \
  --repository-format=docker \
  --location=$REGION \
  --description="My private Docker repository"
echo -e "${GREEN}✓ Artifact Registry repository created${NC}\n"

echo -e "${PURPLE}=================================================================${NC}"
echo -e "${GREEN}🎉 DEPLOYMENT COMPLETE! 🎉${NC}"
echo -e "${PURPLE}=================================================================${NC}"
echo -e "${YELLOW}📋 Summary of resources created:${NC}"
echo -e "${GREEN}  ✅ GKE Cluster: test (Zone: $ZONE)${NC}"
echo -e "${GREEN}  ✅ Microservices: Online Boutique app${NC}"
echo -e "${GREEN}  ✅ Cloud Build Worker Pool: pool-test${NC}"
echo -e "${GREEN}  ✅ Artifact Registry: my-repo (Region: $REGION)${NC}"

echo -e "\n${CYAN}📺 Thank you for watching Dr. Abhishek's tutorial!${NC}"
echo -e "${GREEN}👍 If you found this helpful, please:${NC}"
echo -e "${YELLOW}   👍 Like this video${NC}"
echo -e "${YELLOW}   💬 Share with your friends${NC}"
echo -e "${YELLOW}   🔔 Subscribe to the channel${NC}"
echo -e "${YELLOW}   📲 Hit the bell icon for updates${NC}"
echo -e "\n${PURPLE}=================================================================${NC}"
echo -e "${BLUE}📺 YouTube Channel:${NC}"
echo -e "${RED}https://www.youtube.com/@drabhishek.5460/videos${NC}"
echo -e "${PURPLE}=================================================================${NC}\n"

echo -e "${CYAN}💡 Useful Commands:${NC}"
echo -e "${BLUE}  # Get all pods:${NC} kubectl get pods"
echo -e "${BLUE}  # Get all services:${NC} kubectl get services"
echo -e "${BLUE}  # Check frontend URL:${NC} kubectl get service frontend-external"
echo -e "${BLUE}  # Delete cluster when done:${NC} gcloud container clusters delete test --zone=$ZONE --quiet"
