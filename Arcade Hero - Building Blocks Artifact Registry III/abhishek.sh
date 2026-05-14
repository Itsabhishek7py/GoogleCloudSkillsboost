#!/bin/bash

# Define color variables
BLUE=$'\033[0;34m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
RED=$'\033[0;31m'
NC=$'\033[0m' # No Color
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

clear

# Welcome Banner
echo "${BLUE}${BOLD}"
echo "╔════════════════════════════════════════════════╗"
echo "║         WELCOME TO DR ABHISHEK TUTORIALS       ║"
echo "╚════════════════════════════════════════════════╝"
echo "${NC}"

echo ""
echo ""

# STEP 1: Set region
echo "${YELLOW}${BOLD}Step 1: Set your preferred region (e.g., us-central1)${NC}"
while true; do
  read -p "Export REGION: " REGION
  if [ -z "$REGION" ]; then
    echo "${RED}Error: Region cannot be empty. Please try again.${NC}"
  else
    break
  fi
done

# Step 1.2: Set variables
REPO_NAME="container-registry"
FORMAT="DOCKER"
POLICY_NAME="Grandfather"
KEEP_COUNT=3

echo ""
echo "${GREEN}${BOLD}Configuration Summary:${NC}"
echo "  Repository Name: ${REPO_NAME}"
echo "  Format: ${FORMAT}"
echo "  Location: ${REGION}"
echo "  Cleanup Policy: ${POLICY_NAME}"
echo "  Versions to Keep: ${KEEP_COUNT}"
echo ""

# Step 2: Create the Artifact Registry repository
echo "${YELLOW}${BOLD}Step 2: Creating Artifact Registry repository...${NC}"
if gcloud artifacts repositories create $REPO_NAME \
  --repository-format=$FORMAT \
  --location=$REGION \
  --description="Docker repo for container images"; then
  echo "${GREEN}Successfully created repository '${REPO_NAME}' in ${REGION}${NC}"
else
  echo "${RED}Failed to create repository. Please check your permissions and try again.${NC}"
  exit 1
fi

# Step 3: Create cleanup policy (commented out as it's not currently working)
echo ""
echo "${YELLOW}${BOLD}Step 3: Cleanup Policy Setup (currently commented out)${NC}"
echo "Note: The cleanup policy creation is currently commented out in the script"
echo "as the gcloud artifacts policies create command may not be available in all versions."
echo ""
echo "The intended policy would:"
echo "  - Keep the latest ${KEEP_COUNT} versions"
echo "  - Delete older versions automatically"
echo "  - Be named '${POLICY_NAME}'"

# Uncomment this section when the API becomes available
# if gcloud artifacts policies create $POLICY_NAME \
#   --repository=$REPO_NAME \
#   --location=$REGION \
#   --package-type=$FORMAT \
#   --keep-count=$KEEP_COUNT \
#   --action=DELETE; then
#   echo "${GREEN}Successfully created cleanup policy '${POLICY_NAME}'${NC}"
# else
#   echo "${RED}Failed to create cleanup policy.${NC}"
# fi

echo ""
echo "${GREEN}${BOLD}Setup completed successfully!${NC}"
echo ""
echo "${BLUE}${BOLD}For more cloud tutorials:${NC}"
echo "${BLUE}Subscribe to Dr. Abhishek's YouTube Channel:"
echo "https://www.youtube.com/@drabhishek.5460${NC}"
echo ""
