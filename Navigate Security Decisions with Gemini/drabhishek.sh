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
echo -e "${GREEN}🚀 WELCOME TO GKE MICROSERVICES DEPLOYMENT TUTORIAL${NC}"
echo -e "${PURPLE}=================================================================${NC}"
echo -e "${YELLOW}📺 Presented by: Dr. Abhishek${NC}"
echo -e "${YELLOW}🔥 Don't forget to LIKE, SHARE & SUBSCRIBE!${NC}"
echo -e "${PURPLE}=================================================================${NC}\n"

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

echo -e "${YELLOW}⚙️ Enabling Cloud AI Companion API...${NC}"
gcloud services enable cloudaicompanion.googleapis.com --project ${PROJECT_ID}
echo -e "${GREEN}✓ Cloud AI Companion API enabled${NC}\n"

echo -e "${YELLOW}🔐 Setting up Cloud AI Companion IAM permissions...${NC}"
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member user:${USER} --role=roles/cloudaicompanion.user
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member user:${USER} --role=roles/serviceusage.serviceUsageViewer
echo -e "${GREEN}✓ Cloud AI Companion IAM permissions configured${NC}\n"

echo -e "${YELLOW}☸️ Creating GKE cluster 'test' in $REGION with 1 node...${NC}"
gcloud container clusters create test --region=$REGION --num-nodes=1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ GKE cluster created successfully${NC}\n"
else
    echo -e "${RED}❌ Failed to create GKE cluster${NC}\n"
    exit 1
fi

echo -e "${YELLOW}📦 Cloning microservices demo repository...${NC}"
git clone https://github.com/GoogleCloudPlatform/microservices-demo && cd microservices-demo
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Repository cloned successfully${NC}\n"
else
    echo -e "${RED}❌ Failed to clone repository${NC}\n"
    exit 1
fi

echo -e "${YELLOW}🚀 Deploying microservices to GKE cluster...${NC}"
kubectl apply -f ./release/kubernetes-manifests.yaml
echo -e "${GREEN}✓ Microservices deployment initiated${NC}\n"

echo -e "${YELLOW}⏳ Waiting for services to initialize (this may take 2-3 minutes)...${NC}"
sleep 60

echo -e "${CYAN}🌐 Frontend Service External IP:${NC}"
FRONTEND_IP=$(kubectl get service frontend-external -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
if [ -n "$FRONTEND_IP" ]; then
    echo -e "${GREEN}http://${FRONTEND_IP}${NC}"
    echo -e "${GREEN}✓ You can access the Online Boutique app at the URL above${NC}"
else
    echo -e "${YELLOW}External IP not yet assigned. Getting service details...${NC}"
    kubectl get service frontend-external | awk '{print "  " $0}'
    echo -e "\n${YELLOW}Run this command later to get the IP:${NC}"
    echo -e "${BLUE}kubectl get service frontend-external | awk '{print \$4}'${NC}"
fi
echo ""

echo -e "${YELLOW}🔒 Updating cluster to enable master authorized networks...${NC}"
gcloud container clusters update test --region "$REGION" --enable-master-authorized-networks
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Master authorized networks enabled${NC}\n"
else
    echo -e "${RED}❌ Failed to update cluster${NC}\n"
fi

echo -e "${PURPLE}=================================================================${NC}"
echo -e "${GREEN}🎉 DEPLOYMENT COMPLETE! 🎉${NC}"
echo -e "${PURPLE}=================================================================${NC}"
echo -e "${YELLOW}📋 Summary of resources created:${NC}"
echo -e "${GREEN}  ✅ GKE Cluster: test (Region: $REGION, Nodes: 1)${NC}"
echo -e "${GREEN}  ✅ Microservices: Online Boutique app deployed${NC}"
echo -e "${GREEN}  ✅ Master Authorized Networks: Enabled${NC}"

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
echo -e "${BLUE}  # Monitor deployment:${NC} kubectl get deployments -w"
echo -e "${BLUE}  # Check frontend URL:${NC} kubectl get service frontend-external"
echo -e "${BLUE}  # Delete cluster when done:${NC} gcloud container clusters delete test --region=$REGION --quiet"
echo -e "${BLUE}  # View cluster logs:${NC} kubectl logs -l app=frontend"
