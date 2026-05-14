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

clear


echo "${BLUE}${BOLD}====================================================================${RESET}"
echo "${BLUE}${BOLD}                  Dr. Abhishek Cloud Tutorials                     ${RESET}"
echo "${BLUE}${BOLD}====================================================================${RESET}"
echo
echo "${GREEN}${BOLD}Starting IAP Configuration Lab${RESET}"
echo

# Step 1: Fetch the default region for resources
echo "${CYAN}${BOLD}➤ Getting Project Configuration${RESET}"
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export PROJECT_ID=$(gcloud config get-value project)

echo "${GREEN}✓ Project: $PROJECT_ID | Region: $REGION${RESET}"

# Step 2: Enable the IAP (Identity-Aware Proxy) service
echo "${CYAN}${BOLD}➤ Enabling IAP Service${RESET}"
gcloud services enable iap.googleapis.com
echo "${GREEN}✓ IAP service enabled${RESET}"

# Step 3: Clone the Python sample application repository
echo "${CYAN}${BOLD}➤ Cloning Sample Application${RESET}"
git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
echo "${GREEN}✓ Repository cloned${RESET}"

# Step 4: Navigate to the hello_world directory
echo "${CYAN}${BOLD}➤ Configuring Application${RESET}"
cd python-docs-samples/appengine/standard_python3/hello_world/

# Step 5: Create an App Engine application
echo "${CYAN}${BOLD}➤ Creating App Engine Application${RESET}"
gcloud app create --project=$PROJECT_ID --region=$REGION
echo "${GREEN}✓ App Engine application created${RESET}"

# Step 6: Deploy the application
echo "${CYAN}${BOLD}➤ Deploying Application${RESET}"
gcloud app deploy --quiet
echo "${GREEN}✓ Application deployed${RESET}"

# Step 7: Configure the authentication domain
echo "${CYAN}${BOLD}➤ Configuring Authentication${RESET}"
export AUTH_DOMAIN=$PROJECT_ID.uc.r.appspot.com
EMAIL=$(gcloud config get-value core/account)

cat > details.json << EOF
{
  "App name": "iap-lab",
  "Authorized domains": "$AUTH_DOMAIN",
  "Developer contact email": "$EMAIL"
}
EOF

echo "${GREEN}✓ Authentication details saved${RESET}"
echo "${YELLOW}Details:${RESET}"
cat details.json

# Step 8: Provide configuration links
echo "${CYAN}${BOLD}➤ Manual Configuration Required${RESET}"
echo "${YELLOW}Please complete these manual steps:${RESET}"
echo
echo "1. Configure OAuth consent screen:"
echo "${BLUE}https://console.cloud.google.com/apis/credentials/consent?project=$PROJECT_ID${RESET}"
echo
echo "2. Configure IAP settings:"
echo "${BLUE}https://console.cloud.google.com/security/iap?tab=applications&project=$PROJECT_ID${RESET}"
echo

# Completion Message
echo "${BLUE}${BOLD}====================================================================${RESET}"
echo "${BLUE}${BOLD}               LAB COMPLETED SUCCESSFULLY                          ${RESET}"
echo "${BLUE}${BOLD}====================================================================${RESET}"
echo
echo "${GREEN}${BOLD}Thank you for using Dr. Abhishek Cloud Tutorials!${RESET}"
echo
echo "${YELLOW}For more cloud tutorials and labs, visit:${RESET}"
echo "${CYAN}https://www.youtube.com/@drabhishek.5460${RESET}"
echo

# Cleanup
cd
rm -rf python-docs-samples details.json
