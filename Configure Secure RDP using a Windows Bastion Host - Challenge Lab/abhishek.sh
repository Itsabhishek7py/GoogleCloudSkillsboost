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
echo "${CYAN}${BOLD}Step 1: Set the zone for your resources${RESET}"
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

# Create network and subnets
echo "${BLUE}${BOLD}Creating secure network and subnet...${RESET}"
gcloud compute networks create securenetwork --subnet-mode custom
gcloud compute networks subnets create securenetwork-subnet \
  --network=securenetwork \
  --region $REGION \
  --range=192.168.16.0/20

# Create firewall rule
echo
echo "${BLUE}${BOLD}Creating firewall rule for RDP access...${RESET}"
gcloud compute firewall-rules create rdp-ingress-fw-rule \
  --allow=tcp:3389 \
  --source-ranges 0.0.0.0/0 \
  --target-tags allow-rdp-traffic \
  --network securenetwork

# Create VM instances
echo
echo "${BLUE}${BOLD}Creating bastion host VM...${RESET}"
gcloud compute instances create vm-bastionhost \
  --zone=$ZONE \
  --machine-type=e2-medium \
  --network-interface=subnet=securenetwork-subnet \
  --network-interface=subnet=default,no-address \
  --tags=allow-rdp-traffic \
  --image=projects/windows-cloud/global/images/windows-server-2016-dc-v20220513

echo
echo "${BLUE}${BOLD}Creating secure host VM...${RESET}"
gcloud compute instances create vm-securehost \
  --zone=$ZONE \
  --machine-type=e2-medium \
  --network-interface=subnet=securenetwork-subnet,no-address \
  --network-interface=subnet=default,no-address \
  --tags=allow-rdp-traffic \
  --image=projects/windows-cloud/global/images/windows-server-2016-dc-v20220513

# Wait for VMs to initialize
echo
echo "${YELLOW}${BOLD}Waiting 5 minutes for VMs to initialize...${RESET}"
for i in {300..1}; do
  echo -ne "${YELLOW}${BOLD}Time remaining: ${i}s \r${RESET}"
  sleep 1
done
echo

# Reset Windows passwords
echo
echo "${CYAN}${BOLD}Resetting ${RED}${BOLD}password ${WHITE}${BOLD}for ${GREEN}${BOLD}vm-bastionhost${RESET}"
gcloud compute reset-windows-password vm-bastionhost \
  --user app_admin \
  --zone $ZONE \
  --quiet

echo
echo "${CYAN}${BOLD}Resetting ${RED}${BOLD}password ${WHITE}${BOLD}for ${BLUE}${BOLD}vm-securehost${RESET}"
gcloud compute reset-windows-password vm-securehost \
  --user app_admin \
  --zone $ZONE \
  --quiet

# Completion message
echo
echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"
echo
echo "${MAGENTA}${BOLD}If you found this helpful, subscribe to my channel:${RESET}"
echo "${BLUE}${BOLD}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
