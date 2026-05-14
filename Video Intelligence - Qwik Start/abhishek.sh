#!/bin/bash

# Color setup using tput for better compatibility
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BG_BLACK=$(tput setab 0)
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)
BG_MAGENTA=$(tput setab 5)
BG_CYAN=$(tput setab 6)
BG_WHITE=$(tput setab 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

# Clear screen
clear

# Banner function
function show_banner() {
    echo "${BLUE}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"
    echo "${BLUE}${BOLD}║   WELCOME TO  MY CHANNEL DO LIKE THE VIDEO     ║${RESET}"
    echo "${BLUE}${BOLD}║            &  SUBSCRIBE THE CHANNEL                  ║${RESET}"
    echo "${BLUE}${BOLD}╚══════════════════════════════════════════════════╝${RESET}"
    echo
    echo "${GREEN}For more cloud tutorials, subscribe to:${RESET}"
    echo "${CYAN}${BOLD}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
    echo "${YELLOW}──────────────────────────────────────────────${RESET}"
    echo
}

show_banner

# Start execution message
echo "${YELLOW}${BOLD}Starting ${GREEN}${BOLD}Video Intelligence API Execution${RESET}"
echo

# Service account creation
echo "${MAGENTA}${BOLD}Creating service account...${RESET}"
gcloud iam service-accounts create quickstart && \
echo "${GREEN}✓ Service account created successfully${RESET}" || \
echo "${RED}✗ Failed to create service account${RESET}"
echo

# Service account key creation
echo "${MAGENTA}${BOLD}Creating service account key...${RESET}"
gcloud iam service-accounts keys create key.json \
    --iam-account quickstart@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com && \
echo "${GREEN}✓ Service account key created successfully${RESET}" || \
echo "${RED}✗ Failed to create service account key${RESET}"
echo

# Activate service account
echo "${MAGENTA}${BOLD}Activating service account...${RESET}"
gcloud auth activate-service-account --key-file key.json && \
echo "${GREEN}✓ Service account activated successfully${RESET}" || \
echo "${RED}✗ Failed to activate service account${RESET}"
echo

# Print access token
echo "${MAGENTA}${BOLD}Generating access token...${RESET}"
ACCESS_TOKEN=$(gcloud auth print-access-token)
echo "${CYAN}Access Token: ${WHITE}${ACCESS_TOKEN:0:20}...${RESET}"
echo

# Create request JSON
echo "${MAGENTA}${BOLD}Creating annotation request...${RESET}"
cat > request.json <<EOF
{
   "inputUri":"gs://spls/gsp154/video/train.mp4",
   "features": [
       "LABEL_DETECTION"
   ]
}
EOF
echo "${GREEN}✓ Request file created successfully${RESET}"
echo

# Run annotation request
echo "${MAGENTA}${BOLD}Sending video annotation request...${RESET}"
response=$(curl -s -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    'https://videointelligence.googleapis.com/v1/videos:annotate' \
    -d @request.json)

if [ $? -eq 0 ]; then
    echo "${GREEN}✓ Annotation request submitted successfully${RESET}"
else
    echo "${RED}✗ Failed to submit annotation request${RESET}"
    exit 1
fi
echo

# Extract operation details
echo "${MAGENTA}${BOLD}Processing operation details...${RESET}"
project_id=$(echo $response | jq -r '.name' | cut -d'/' -f2)
location=$(echo $response | cut -d'/' -f4)
operation_name=$(echo $response | cut -d'/' -f6)

echo "${CYAN}Project ID: ${WHITE}$project_id${RESET}"
echo "${CYAN}Location: ${WHITE}$location${RESET}"
echo "${CYAN}Operation Name: ${WHITE}$operation_name${RESET}"
echo

# Check operation status
echo "${MAGENTA}${BOLD}Checking operation status...${RESET}"
curl -s -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    "https://videointelligence.googleapis.com/v1/projects/$project_id/locations/$location/operations/$operation_name"

if [ $? -eq 0 ]; then
    echo "${GREEN}✓ Operation status retrieved successfully${RESET}"
else
    echo "${RED}✗ Failed to retrieve operation status${RESET}"
fi
echo

# Completion message
echo "${GREEN}${BOLD}╔════════════════════════════════════════════╗${RESET}"
echo "${GREEN}${BOLD}║          LAB COMPLETED SUCCESSFULLY        ║${RESET}"
echo "${GREEN}${BOLD}╚════════════════════════════════════════════╝${RESET}"
echo
echo "${WHITE}${BOLD}Congratulations on completing the lab!${RESET}"
echo
echo "${YELLOW}For more cloud tutorials and labs, subscribe to:${RESET}"
echo "${CYAN}${BOLD}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo
echo "${BLUE}Happy learning with Google Cloud!${RESET}"
