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
echo -e "${GREEN}🚀 WELCOME TO GCP CUSTOM NETWORK CREATION TUTORIAL${NC}"
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

echo -e "${YELLOW}🌐 Creating custom VPC network 'privatenet' in region $REGION...${NC}"
echo -e "${BLUE}This may take a minute or two...${NC}\n"

# Create network and subnets with firewall rules
gcloud compute networks create privatenet --project=$PROJECT_ID --subnet-mode=custom --mtu=1460 --enable-ula-internal-ipv6 --bgp-routing-mode=regional && \
gcloud compute networks subnets create privatenet-subnet-us --project=$PROJECT_ID --range=10.130.0.0/20 --stack-type=IPV4_IPV6 --ipv6-access-type=INTERNAL --network=privatenet --region=$REGION && \
gcloud compute firewall-rules create privatenet-allow-custom --project=$PROJECT_ID --network=projects/$PROJECT_ID/global/networks/privatenet --description="Allows connection from any source to any instance on the network using custom protocols." --direction=INGRESS --priority=65534 --source-ranges=10.130.0.0/20 --action=ALLOW --rules=all && \
gcloud compute firewall-rules create privatenet-allow-icmp --project=$PROJECT_ID --network=projects/$PROJECT_ID/global/networks/privatenet --description="Allows ICMP connections from any source to any instance on the network." --direction=INGRESS --priority=65534 --source-ranges=0.0.0.0/0 --action=ALLOW --rules=icmp && \
gcloud compute firewall-rules create privatenet-allow-rdp --project=$PROJECT_ID --network=projects/$PROJECT_ID/global/networks/privatenet --description="Allows RDP connections from any source to any instance on the network using port 3389." --direction=INGRESS --priority=65534 --source-ranges=0.0.0.0/0 --action=ALLOW --rules=tcp:3389 && \
gcloud compute firewall-rules create privatenet-allow-ssh --project=$PROJECT_ID --network=projects/$PROJECT_ID/global/networks/privatenet --description="Allows TCP connections from any source to any instance on the network using port 22." --direction=INGRESS --priority=65534 --source-ranges=0.0.0.0/0 --action=ALLOW --rules=tcp:22 && \
gcloud compute firewall-rules create privatenet-allow-ipv6-icmp --project=$PROJECT_ID --network=projects/$PROJECT_ID/global/networks/privatenet --description="Allows ICMP connections from any source to any instance on the network." --direction=INGRESS --priority=65534 --source-ranges=::/0 --action=ALLOW --rules=58 && \
gcloud compute firewall-rules create privatenet-allow-ipv6-rdp --project=$PROJECT_ID --network=projects/$PROJECT_ID/global/networks/privatenet --description="Allows RDP connections from any source to any instance on the network using port 3389." --direction=INGRESS --priority=65534 --source-ranges=::/0 --action=ALLOW --rules=tcp:3389 && \
gcloud compute firewall-rules create privatenet-allow-ipv6-ssh --project=$PROJECT_ID --network=projects/$PROJECT_ID/global/networks/privatenet --description="Allows TCP connections from any source to any instance on the network using port 22." --direction=INGRESS --priority=65534 --source-ranges=::/0 --action=ALLOW --rules=tcp:22

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✅ Custom VPC network 'privatenet' created successfully!${NC}"
else
    echo -e "\n${RED}❌ Error creating network. Please check your configuration.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}📋 Network Configuration Summary:${NC}"
echo -e "${GREEN}  ✅ Network Name: privatenet${NC}"
echo -e "${GREEN}  ✅ Subnet: privatenet-subnet-us (Region: $REGION)${NC}"
echo -e "${GREEN}  ✅ IPv4 Range: 10.130.0.0/20${NC}"
echo -e "${GREEN}  ✅ IPv6: Enabled (INTERNAL)${NC}"
echo -e "${GREEN}  ✅ Firewall Rules Created:${NC}"
echo -e "${GREEN}     • privatenet-allow-custom${NC}"
echo -e "${GREEN}     • privatenet-allow-icmp${NC}"
echo -e "${GREEN}     • privatenet-allow-rdp${NC}"
echo -e "${GREEN}     • privatenet-allow-ssh${NC}"
echo -e "${GREEN}     • privatenet-allow-ipv6-icmp${NC}"
echo -e "${GREEN}     • privatenet-allow-ipv6-rdp${NC}"
echo -e "${GREEN}     • privatenet-allow-ipv6-ssh${NC}"

echo -e "\n${PURPLE}=================================================================${NC}"
echo -e "${GREEN}🎉 NETWORK CREATION COMPLETE! 🎉${NC}"
echo -e "${PURPLE}=================================================================${NC}"

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
echo -e "${BLUE}  # List networks:${NC} gcloud compute networks list"
echo -e "${BLUE}  # List subnets:${NC} gcloud compute networks subnets list --region=$REGION"
echo -e "${BLUE}  # List firewall rules:${NC} gcloud compute firewall-rules list --filter=network=privatenet"
echo -e "${BLUE}  # Delete network when done:${NC} gcloud compute networks delete privatenet --quiet"
