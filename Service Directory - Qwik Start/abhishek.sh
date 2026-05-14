
#!/bin/bash

# Enhanced Color Definitions
YELLOW=$(tput setaf 3)
MAGENTA=$(tput setaf 5)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
BLUE=$(tput setaf 4)
WHITE=$(tput setaf 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

clear

# Display Header
echo "${CYAN}${BOLD}============================================${RESET}"
echo "${CYAN}${BOLD}   DR. ABHISHEK'S SERVICE DIRECTORY LAB     ${RESET}"
echo "${CYAN}${BOLD}============================================${RESET}"
echo "${BLUE}YouTube Channel: https://www.youtube.com/@drabhishek.5460${RESET}"
echo "${MAGENTA}Video Tutorials: https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo

# Get Location Input
echo "${YELLOW}${BOLD}Step 1: Please enter your preferred location (e.g., us-central1):${RESET}"
read -p "Location: " LOCATION

# Validate input
if [ -z "$LOCATION" ]; then
  echo "${RED}${BOLD}Error: Location cannot be empty.${RESET}"
  echo "${YELLOW}Common valid locations include: us-central1, us-east1, europe-west1${RESET}"
  exit 1
fi

echo "${GREEN}✓ Location set to: ${LOCATION}${RESET}"
echo

# Enable Service Directory API
echo "${GREEN}${BOLD}Step 2: Enabling Service Directory API${RESET}"
if ! gcloud services enable servicedirectory.googleapis.com; then
  echo "${RED}✗ Failed to enable Service Directory API${RESET}"
  exit 1
fi
echo "${GREEN}✓ Service Directory API enabled${RESET}"
echo

# Wait for API propagation
echo "${YELLOW}${BOLD}Waiting 15 seconds for API to fully enable...${RESET}"
for i in {1..15}; do
  echo -n "."
  sleep 1
done
echo -e "\n${GREEN}✓ API ready${RESET}"
echo

# Create Service Directory Namespace
echo "${GREEN}${BOLD}Step 3: Creating Service Directory Namespace${RESET}"
if ! gcloud service-directory namespaces create example-namespace \
  --location $LOCATION; then
  echo "${RED}✗ Failed to create namespace${RESET}"
  exit 1
fi
echo "${GREEN}✓ Namespace created${RESET}"
echo

# Create Service Directory Service
echo "${GREEN}${BOLD}Step 4: Creating Service Directory Service${RESET}"
if ! gcloud service-directory services create example-service \
  --namespace example-namespace \
  --location $LOCATION; then
  echo "${RED}✗ Failed to create service${RESET}"
  exit 1
fi
echo "${GREEN}✓ Service created${RESET}"
echo

# Create Service Directory Endpoint
echo "${GREEN}${BOLD}Step 5: Creating Service Directory Endpoint${RESET}"
if ! gcloud service-directory endpoints create example-endpoint \
  --address 0.0.0.0 \
  --port 80 \
  --service example-service \
  --namespace example-namespace \
  --location $LOCATION; then
  echo "${RED}✗ Failed to create endpoint${RESET}"
  exit 1
fi
echo "${GREEN}✓ Endpoint created${RESET}"
echo

# Create DNS Managed Zone
echo "${GREEN}${BOLD}Step 6: Creating DNS Managed Zone${RESET}"
if ! gcloud dns managed-zones create example-zone-name \
  --dns-name myzone.example.com \
  --description "drabhishek" \
  --visibility private \
  --networks "https://www.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/global/networks/default" \
  --service-directory-namespace "https://servicedirectory.googleapis.com/v1/projects/$DEVSHELL_PROJECT_ID/locations/$LOCATION/namespaces/example-namespace"; then
  echo "${RED}✗ Failed to create DNS managed zone${RESET}"
  exit 1
fi
echo "${GREEN}✓ DNS managed zone created${RESET}"
echo

# Cleanup temporary files
SCRIPT_NAME="abhishek.sh"
if [ -f "$SCRIPT_NAME" ]; then
  echo "${YELLOW}Cleaning up temporary files...${RESET}"
  rm -- "$SCRIPT_NAME"
fi

# Completion Message
echo "${MAGENTA}${BOLD}============================================${RESET}"
echo "${MAGENTA}${BOLD}   SERVICE DIRECTORY LAB COMPLETED!        ${RESET}"
echo "${MAGENTA}${BOLD}============================================${RESET}"
echo
echo "${GREEN}${BOLD}Congratulations on completing the lab!${RESET}"
echo
echo "${CYAN}${BOLD}For more cloud tutorials:${RESET}"
echo "${BLUE}Subscribe to Dr. Abhishek's YouTube Channel:${RESET}"
echo "${WHITE}https://www.youtube.com/@drabhishek.5460${RESET}"
echo "${BLUE}Video Tutorials:${RESET}"
echo "${WHITE}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
