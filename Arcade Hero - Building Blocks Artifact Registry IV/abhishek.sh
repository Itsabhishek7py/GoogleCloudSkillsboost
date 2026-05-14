#!/bin/bash

# Define colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Display header
echo -e "${BLUE}${BOLD}"
echo "╔════════════════════════════════════════════════╗"
echo "║       Arcade Hero: Building Blocks Artifact Registry IV         ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}${RESET}"

# Get region input with validation
while true; do
    echo -e "${YELLOW}${BOLD}Step 1: Enter your preferred GCP region (e.g., us-central1)${NC}${RESET}"
    read -p "Export REGION: " REGION
    
    if [ -z "$REGION" ]; then
        echo -e "${RED}Error: Region cannot be empty. Please try again.${NC}"
    else
        break
    fi
done

# Set configuration variables
REPO_NAME="container-registry"
FORMAT="DOCKER"
POLICY_NAME="Grandfather"
KEEP_COUNT=3

# Display configuration summary
echo -e "\n${GREEN}${BOLD}Configuration Summary:${NC}${RESET}"
echo -e "  ${BLUE}• Repository Name:${NC} ${REPO_NAME}"
echo -e "  ${BLUE}• Format:${NC} ${FORMAT}"
echo -e "  ${BLUE}• Location:${NC} ${REGION}"
echo -e "  ${BLUE}• Cleanup Policy:${NC} ${POLICY_NAME} (keep latest ${KEEP_COUNT} versions)"

# Create Artifact Registry repository
echo -e "\n${YELLOW}${BOLD}Step 2: Creating Artifact Registry repository...${NC}${RESET}"
if gcloud artifacts repositories create $REPO_NAME \
    --repository-format=$FORMAT \
    --location=$REGION \
    --description="Docker repository for container images"; then
    echo -e "${GREEN}✓ Successfully created repository '${REPO_NAME}' in ${REGION}${NC}"
else
    echo -e "${RED}✗ Failed to create repository. Please check your permissions and try again.${NC}"
    exit 1
fi

# Cleanup policy (commented out with explanation)
echo -e "\n${YELLOW}${BOLD}Step 3: Cleanup Policy Information${NC}${RESET}"
echo -e "The cleanup policy feature is currently not available in the standard gcloud CLI."
echo -e "To implement a similar policy, you would need to:"
echo -e "  1. Use Cloud Scheduler to run periodic cleanup jobs"
echo -e "  2. Create a Cloud Function with cleanup logic"
echo -e "  3. Implement version retention in your CI/CD pipeline"

# Uncomment when available
# echo -e "\nCreating cleanup policy..."
# gcloud artifacts policies create $POLICY_NAME \
#   --repository=$REPO_NAME \
#   --location=$REGION \
#   --package-type=$FORMAT \
#   --keep-count=$KEEP_COUNT \
#   --action=DELETE

# Completion message
echo -e "\n${GREEN}${BOLD}Setup completed successfully!${NC}${RESET}"
echo -e "\n${BLUE}Next steps:${NC}"
echo -e "  • Configure Docker to use this registry"
echo -e "  • Push your container images"
echo -e "  • Set up appropriate IAM permissions"
echo -e "\n${BLUE}For more tutorials, visit:${NC}"
echo -e "https://www.youtube.com/@drabhishek.5460"
