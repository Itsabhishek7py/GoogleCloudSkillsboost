#!/bin/bash

# Define color variables
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

echo
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}         INITIATING EXECUTION...        ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo

# Get project, region, and zone details
echo "${CYAN_TEXT}${BOLD_TEXT}Fetching the current project ID and setting the compute region...${RESET_FORMAT}"
export PROJECT_ID=$(gcloud config get-value project)
export REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
gcloud config set compute/region $REGION
export ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
echo -e "${YELLOW_TEXT}Google Cloud project: ${CYAN_TEXT}$PROJECT_ID${NO_COLOR}"
echo -e "${YELLOW_TEXT}Using region: ${CYAN_TEXT}$REGION${NO_COLOR}"
echo -e "${YELLOW_TEXT}Using zone: ${CYAN_TEXT}$ZONE${NO_COLOR}\n"

gsutil cp gs://spls/gsp499/user-authentication-with-iap.zip .
unzip user-authentication-with-iap.zip
cd user-authentication-with-iap

echo
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}         Task 1. Deploy the application and protect it with IAP        ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================================================${RESET_FORMAT}"
echo

cd 1-HelloWorld
sed -i 's/python37/python313/g' app.yaml
cat main.py
echo
gcloud app create --region=$REGION
gcloud app deploy --quiet
gcloud app browse

# Enable required APIs
gcloud services enable \
  iap.googleapis.com \
  appengine.googleapis.com \
  cloudresourcemanager.googleapis.com \
  --quiet

# export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
# echo -e "${YELLOW_TEXT}Google Cloud project number: ${CYAN_TEXT}$PROJECT_NUMBER${NO_COLOR}"
export USER_EMAIL=$(gcloud config get-value account)
echo -e "${YELLOW_TEXT}User email: ${CYAN_TEXT}$USER_EMAIL${NO_COLOR}"
  
gcloud alpha iap oauth-brands create \
  --application_title="IAP Example" \
  --support_email="$USER_EMAIL" \
  --project=$PROJECT_ID

# Disable App Engine Flex API (required by the lab)
gcloud services disable appengineflex.googleapis.com --quiet

# Enable IAP programmatically (App Engine backend)
gcloud iap web enable \
  --resource-type=app-engine \
  --project=$PROJECT_ID
  
# Grant IAP access to a user (Cloud console “Add Principal”)
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="user:$USER_EMAIL" \
  --role="roles/iap.httpsResourceAccessor"
  
echo
echo "${BLUE_TEXT}${BOLD_TEXT}================================================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}         Task 2. Access user identity information               ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}================================================================${RESET_FORMAT}"
echo

cd ~/user-authentication-with-iap/2-HelloUser
sed -i 's/python37/python313/g' app.yaml
gcloud app deploy --quiet 
gcloud app browse

echo
echo "${BLUE_TEXT}${BOLD_TEXT}================================================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}         Task 3. Use Cryptographic Verification                 ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}================================================================${RESET_FORMAT}"
echo

cd ~/user-authentication-with-iap/3-HelloVerifiedUser
sed -i 's/python37/python313/g' app.yaml
gcloud app deploy --quiet
gcloud app browse
