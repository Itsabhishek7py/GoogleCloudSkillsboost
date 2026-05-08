#!/bin/bash

# Color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner function
function banner() {
    echo -e "${YELLOW}"
    echo "╔══════════════════════════════════════════════════╗"
    echo "║     WELCOME TO DR ABHISHEK CLOUD TUTORIALS    ║"
    echo "║                 DO LIKE THE VIDEO                  ║"
    echo "╚══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${CYAN}Subscribe to Dr. Abhishek's YouTube Channel:${NC}"
    echo -e "${GREEN}https://www.youtube.com/@drabhishek.5460/videos${NC}"
    echo -e "${YELLOW}──────────────────────────────────────────────${NC}"
}

# Display banner
banner

# User input section with colors
echo -e "${MAGENTA}Please enter the following configuration details:${NC}"
echo ""

read -p "$(echo -e "${BLUE}ENTER VPC_NAME: ${NC}")" VPC_NAME
echo ""

read -p "$(echo -e "${BLUE}ENTER SUBNET_A: ${NC}")" SUBNET_A
echo ""

read -p "$(echo -e "${BLUE}ENTER SUBNET_B: ${NC}")" SUBNET_B
echo ""

read -p "$(echo -e "${BLUE}ENTER FIREWALL_1: ${NC}")" FIREWALL_1
echo ""

read -p "$(echo -e "${BLUE}ENTER FIREWALL_2: ${NC}")" FIREWALL_2
echo ""

read -p "$(echo -e "${BLUE}ENTER FIREWALL_3: ${NC}")" FIREWALL_3
echo ""

read -p "$(echo -e "${BLUE}ENTER ZONE_1 (e.g., us-central1-a): ${NC}")" ZONE_1
echo ""

read -p "$(echo -e "${BLUE}ENTER ZONE_2 (e.g., us-east1-b): ${NC}")" ZONE_2
echo ""

# Export derived variables
export REGION_1=${ZONE_1%-*}
export REGION_2=${ZONE_2%-*}
export VM_1=us-test-01
export VM_2=us-test-02

# Summary of configuration
echo -e "${GREEN}╔════════════════════════════════════════════╗"
echo -e "║           CONFIGURATION SUMMARY            ║"
echo -e "╠════════════════════════════════════════════╣"
echo -e "║ ${CYAN}VPC Name:${NC} $VPC_NAME"
echo -e "║ ${CYAN}Subnet A:${NC} $SUBNET_A (Region: $REGION_1)"
echo -e "║ ${CYAN}Subnet B:${NC} $SUBNET_B (Region: $REGION_2)"
echo -e "║ ${CYAN}Firewall Rules:${NC} $FIREWALL_1, $FIREWALL_2, $FIREWALL_3"
echo -e "║ ${CYAN}Zones:${NC} $ZONE_1, $ZONE_2"
echo -e "║ ${CYAN}VM Names:${NC} $VM_1, $VM_2"
echo -e "╚════════════════════════════════════════════╝${NC}"
echo ""

# Confirmation prompt
read -p "$(echo -e "${YELLOW}Proceed with setup? (y/n): ${NC}")" confirm
if [[ $confirm != [yY] ]]; then
    echo -e "${RED}Setup aborted by user.${NC}"
    exit 1
fi

echo -e "${GREEN}Starting Google Cloud VPC setup...${NC}"
echo ""

# Create VPC
echo -e "${BLUE}Creating VPC: $VPC_NAME${NC}"
gcloud compute networks create $VPC_NAME \
    --project=$DEVSHELL_PROJECT_ID \
    --subnet-mode=custom \
    --mtu=1460 \
    --bgp-routing-mode=regional && \
echo -e "${GREEN}✓ VPC created successfully${NC}" || \
echo -e "${RED}✗ Failed to create VPC${NC}"
echo ""

# Create Subnet A
echo -e "${BLUE}Creating Subnet $SUBNET_A in $REGION_1${NC}"
gcloud compute networks subnets create $SUBNET_A \
    --project=$DEVSHELL_PROJECT_ID \
    --region=$REGION_1 \
    --network=$VPC_NAME \
    --range=10.10.10.0/24 \
    --stack-type=IPV4_ONLY && \
echo -e "${GREEN}✓ Subnet A created successfully${NC}" || \
echo -e "${RED}✗ Failed to create Subnet A${NC}"
echo ""

# Create Subnet B
echo -e "${BLUE}Creating Subnet $SUBNET_B in $REGION_2${NC}"
gcloud compute networks subnets create $SUBNET_B \
    --project=$DEVSHELL_PROJECT_ID \
    --region=$REGION_2 \
    --network=$VPC_NAME \
    --range=10.10.20.0/24 \
    --stack-type=IPV4_ONLY && \
echo -e "${GREEN}✓ Subnet B created successfully${NC}" || \
echo -e "${RED}✗ Failed to create Subnet B${NC}"
echo ""

# Create Firewall Rules
echo -e "${BLUE}Creating Firewall Rule $FIREWALL_1 (SSH)${NC}"
gcloud compute firewall-rules create $FIREWALL_1 \
    --project=$DEVSHELL_PROJECT_ID \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=all && \
echo -e "${GREEN}✓ Firewall Rule 1 created successfully${NC}" || \
echo -e "${RED}✗ Failed to create Firewall Rule 1${NC}"
echo ""

echo -e "${BLUE}Creating Firewall Rule $FIREWALL_2 (RDP)${NC}"
gcloud compute firewall-rules create $FIREWALL_2 \
    --project=$DEVSHELL_PROJECT_ID \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --priority=65535 \
    --action=ALLOW \
    --rules=tcp:3389 \
    --source-ranges=0.0.0.0/24 \
    --target-tags=all && \
echo -e "${GREEN}✓ Firewall Rule 2 created successfully${NC}" || \
echo -e "${RED}✗ Failed to create Firewall Rule 2${NC}"
echo ""

echo -e "${BLUE}Creating Firewall Rule $FIREWALL_3 (ICMP)${NC}"
gcloud compute firewall-rules create $FIREWALL_3 \
    --project=$DEVSHELL_PROJECT_ID \
    --network=$VPC_NAME \
    --direction=INGRESS \
    --priority=1000 \
    --action=ALLOW \
    --rules=icmp \
    --source-ranges=0.0.0.0/24 \
    --target-tags=all && \
echo -e "${GREEN}✓ Firewall Rule 3 created successfully${NC}" || \
echo -e "${RED}✗ Failed to create Firewall Rule 3${NC}"
echo ""

# Create VMs
echo -e "${BLUE}Creating VM $VM_1 in $ZONE_1${NC}"
gcloud compute instances create $VM_1 \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE_1 \
    --subnet=$SUBNET_A \
    --machine-type=e2-standard-2 \
    --tags=allow-icmp && \
echo -e "${GREEN}✓ VM 1 created successfully${NC}" || \
echo -e "${RED}✗ Failed to create VM 1${NC}"
echo ""

echo -e "${BLUE}Creating VM $VM_2 in $ZONE_2${NC}"
gcloud compute instances create $VM_2 \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE_2 \
    --subnet=$SUBNET_B \
    --machine-type=e2-standard-2 \
    --tags=allow-icmp && \
echo -e "${GREEN}✓ VM 2 created successfully${NC}" || \
echo -e "${RED}✗ Failed to create VM 2${NC}"
echo ""

# Wait for VMs to be ready
echo -e "${YELLOW}Waiting 20 seconds for VMs to initialize...${NC}"
sleep 20
echo ""

# Test connectivity
echo -e "${BLUE}Testing connectivity between VMs...${NC}"
export EXTERNAL_IP_2=$(gcloud compute instances describe $VM_2 \
    --zone=$ZONE_2 \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo -e "${CYAN}Testing ping from $VM_1 to $VM_2...${NC}"
gcloud compute ssh $VM_1 --zone=$ZONE_1 --project=$DEVSHELL_PROJECT_ID --quiet --command="ping -c 3 $EXTERNAL_IP_2 && ping -c 3 $VM_2.$ZONE_2" && \
echo -e "${GREEN}✓ Connectivity test successful${NC}" || \
echo -e "${RED}✗ Connectivity test failed${NC}"
echo ""

# Completion message
echo -e "${GREEN}╔════════════════════════════════════════════╗"
echo -e "║          LAB COMPLETED SUCCESSFULLY       ║"
echo -e "╚════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Thank you!"
echo -e "For more tutorials, subscribe to Dr. Abhishek's YouTube Channel:"
echo -e "${GREEN}https://www.youtube.com/@drabhishek.5460/videos${NC}"
echo -e "${YELLOW}Happy Cloud Computing!${NC}"
