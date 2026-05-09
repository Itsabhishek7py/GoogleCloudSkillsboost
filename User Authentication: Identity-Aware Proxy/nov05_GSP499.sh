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

###########################################################
# Task 1. Deploy the application and protect it with IAP
###########################################################

echo
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}         Task 1. Deploy the application and protect it with IAP        ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================================================${RESET_FORMAT}"
echo

cd 1-HelloWorld
sed -i 's/python37/python313/g' app.yaml
cat main.py
gcloud app create --region=$REGION
gcloud app deploy --quiet
gcloud app browse
