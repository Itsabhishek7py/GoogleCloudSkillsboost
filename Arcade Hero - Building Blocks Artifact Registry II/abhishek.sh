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
echo "║          Welcome to dr abhishek cloud tutorials       ║"
echo "╚════════════════════════════════════════════════╝"
echo "${NC}"

echo ""
echo ""

# STEP 1: Set region
while true; do
    read -p "${YELLOW}${BOLD}Enter the REGION (e.g., us-central1): ${NC}" REGION
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

echo "\n${GREEN}=== Configuration Summary ===${NC}"
echo "Region: ${BOLD}$REGION${NORMAL}"
echo "Repository Name: ${BOLD}$REPO_NAME${NORMAL}"
echo "Format: ${BOLD}$FORMAT${NORMAL}"
echo "Cleanup Policy: ${BOLD}$POLICY_NAME (keep last $KEEP_COUNT versions)${NORMAL}"
echo ""

# Step 2: Create the Artifact Registry repository
echo "${YELLOW}Creating Artifact Registry repository...${NC}"
if gcloud artifacts repositories create $REPO_NAME \
  --repository-format=$FORMAT \
  --location=$REGION \
  --description="Docker repo for container images"; then
    echo "${GREEN}Successfully created repository '$REPO_NAME' in region '$REGION'${NC}"
else
    echo "${RED}Failed to create repository. Please check your permissions and try again.${NC}"
    exit 1
fi

# Step 3: Create cleanup policy (commented out as it may require additional permissions)
echo "\n${YELLOW}Note: The cleanup policy creation is commented out in this script.${NC}"
echo "${YELLOW}Uncomment the relevant section in the script if you want to enable it.${NC}"
echo "${YELLOW}This typically requires additional permissions.${NC}"

# Uncomment this section if you have the required permissions
# echo "${YELLOW}Creating cleanup policy...${NC}"
# if gcloud artifacts policies create $POLICY_NAME \
#   --repository=$REPO_NAME \
#   --location=$REGION \
#   --package-type=$FORMAT \
#   --keep-count=$KEEP_COUNT \
#   --action=DELETE; then
#     echo "${GREEN}Successfully created cleanup policy '$POLICY_NAME'${NC}"
# else
#     echo "${RED}Failed to create cleanup policy. You may need additional permissions.${NC}"
# fi

echo "\n${GREEN}${BOLD}Setup completed successfully!${NC}"
echo "${BLUE}You can now use the Artifact Registry repository:"
echo "Name: ${BOLD}$REPO_NAME${NORMAL}"
echo "Region: ${BOLD}$REGION${NORMAL}"
echo "Format: ${BOLD}$FORMAT${NORMAL}${NC}"
echo ""
echo "${BLUE}For more cloud tutorials:${NC}"
echo "${BLUE}Subscribe to Dr. Abhishek's YouTube Channel:"
echo "https://www.youtube.com/@drabhishek.5460${NC}"
echo ""
