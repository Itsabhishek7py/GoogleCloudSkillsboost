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
echo -e "\n${BLUE}${BOLD}"
echo "╔════════════════════════════════════════════════╗"
echo "║       ARTIFACT REGISTRY LAB          ║"
echo "║           by Dr. Abhishek                      ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}${RESET}"

# Get region input with validation
while true; do
    echo -e "${YELLOW}${BOLD}Step 1: Enter your GCP region (e.g., us-central1)${NC}${RESET}"
    read -p "Region: " REGION
    
    if [ -z "$REGION" ]; then
        echo -e "${RED}Error: Region cannot be empty. Please try again.${NC}"
    elif ! [[ $REGION =~ ^[a-z]+-[a-z]+[0-9]+$ ]]; then
        echo -e "${RED}Error: Invalid region format. Example: us-central1${NC}"
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
echo -e "  ${BLUE}• Retention Policy:${NC} Keep latest ${KEEP_COUNT} versions"

# Create Artifact Registry repository
echo -e "\n${YELLOW}${BOLD}Step 2: Creating Artifact Registry repository...${NC}${RESET}"
if gcloud artifacts repositories create $REPO_NAME \
    --repository-format=$FORMAT \
    --location=$REGION \
    --description="Docker repository for container images" 2>&1 | tee /tmp/artifact_registry.log; then
    echo -e "\n${GREEN}✓ Successfully created repository '${REPO_NAME}' in ${REGION}${NC}"
else
    echo -e "\n${RED}✗ Failed to create repository. Error details:${NC}"
    cat /tmp/artifact_registry.log
    echo -e "\n${YELLOW}Possible solutions:"
    echo -e "1. Verify your project has Artifact Registry API enabled"
    echo -e "2. Check your gcloud authentication (gcloud auth login)"
    echo -e "3. Ensure you have sufficient permissions${NC}"
    rm /tmp/artifact_registry.log
    exit 1
fi
rm /tmp/artifact_registry.log

# Cleanup policy information
echo -e "\n${YELLOW}${BOLD}Step 3: Retention Policy Information${NC}${RESET}"
echo -e "To implement version retention, you can:"
echo -e "1. Use this gcloud command (when available):"
echo -e "   gcloud artifacts policies create ${POLICY_NAME} \\"
echo -e "     --repository=${REPO_NAME} \\"
echo -e "     --location=${REGION} \\"
echo -e "     --keep-count=${KEEP_COUNT}"
echo -e "\n2. Alternative methods:"
echo -e "   • Cloud Scheduler with cleanup scripts"
echo -e "   • Cloud Functions with artifact management"
echo -e "   • CI/CD pipeline version control"

# Completion message
echo -e "\n${GREEN}${BOLD}Setup completed successfully!${NC}${RESET}"
echo -e "\n${BLUE}Next steps:${NC}"
echo -e "1. Configure Docker authentication:"
echo -e "   gcloud auth configure-docker ${REGION}-docker.pkg.dev"
echo -e "2. Push your first image:"
echo -e "   docker pull nginx:latest"
echo -e "   docker tag nginx ${REGION}-docker.pkg.dev/\$(gcloud config get-value project)/${REPO_NAME}/nginx:latest"
echo -e "   docker push ${REGION}-docker.pkg.dev/\$(gcloud config get-value project)/${REPO_NAME}/nginx:latest"
echo -e "\n${BLUE}For more tutorials:${NC}"
echo -e "Visit: https://www.youtube.com/@drabhishek.5460"
