#!/bin/bash

# Enhanced Color Definitions
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BOLD=$(tput bold)
DIM=$(tput dim)
RESET=$(tput sgr0)

clear

# Display Header
echo
echo "${CYAN}${BOLD}============================================${RESET}"
echo "${CYAN}${BOLD}   DR. ABHISHEK'S APP ENGINE DEPLOYMENT LAB ${RESET}"
echo "${CYAN}${BOLD}============================================${RESET}"
echo "${BLUE}YouTube Channel: https://www.youtube.com/@drabhishek.5460${RESET}"
echo "${CYAN}Video Tutorials: https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo

# Region Configuration
echo "${BLUE}${BOLD}Step 1: Configuring Deployment Region${RESET}"
echo "${WHITE}Checking your project's default region...${RESET}"
echo

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

if [ -z "$REGION" ]; then
  echo "${YELLOW}⚠️  No default region detected${RESET}"
  echo "${CYAN}Please enter your preferred App Engine region (e.g., us-central):${RESET}"
  read -p "${WHITE}Region: ${RESET}" REGION
  export REGION
fi

echo "${GREEN}✓ Deployment region set to: ${REGION}${RESET}"
echo

# Authentication Check
echo "${BLUE}${BOLD}Step 2: Verifying Authentication${RESET}"
echo "${WHITE}Checking your active credentials...${RESET}"
echo

gcloud auth list
echo "${GREEN}✓ Authentication verified${RESET}"
echo

# Project Setup
echo "${BLUE}${BOLD}Step 3: Configuring Project Settings${RESET}"
echo "${WHITE}Setting up your Google Cloud project...${RESET}"
echo

export PROJECT_ID=$(gcloud config get-value project)
echo "${GREEN}✓ Project ID: ${PROJECT_ID}${RESET}"
echo

# Enable App Engine API
echo "${BLUE}${BOLD}Step 4: Enabling App Engine API${RESET}"
echo "${WHITE}Activating required services...${RESET}"
echo

gcloud services enable appengine.googleapis.com
echo "${GREEN}✓ App Engine API enabled${RESET}"
echo

# Download Sample Code
echo "${BLUE}${BOLD}Step 5: Downloading Sample Application${RESET}"
echo "${WHITE}Cloning the Python sample code repository...${RESET}"
echo

git clone https://github.com/GoogleCloudPlatform/python-docs-samples
echo "${GREEN}✓ Sample code downloaded${RESET}"
echo

# Navigate to App Directory
echo "${BLUE}${BOLD}Step 6: Preparing Application Files${RESET}"
echo "${WHITE}Setting up the Hello World application...${RESET}"
echo

cd ~/python-docs-samples/appengine/standard_python3/hello_world
export PROJECT_ID=${PROJECT_ID}
echo "${GREEN}✓ Application directory ready${RESET}"
echo

# Initialize App Engine
echo "${BLUE}${BOLD}Step 7: Initializing App Engine${RESET}"
echo "${YELLOW}This will create your App Engine application...${RESET}"
echo

gcloud app create --project $PROJECT_ID --region=$REGION
echo "${GREEN}✓ App Engine initialized${RESET}"
echo

# Deploy Application
echo "${BLUE}${BOLD}Step 8: Deploying to App Engine${RESET}"
echo "${YELLOW}This may take several minutes...${RESET}"
echo

echo "Y" | gcloud app deploy app.yaml --project $PROJECT_ID
echo "${GREEN}✓ Application deployed successfully${RESET}"
echo

# Create Version
echo "${BLUE}${BOLD}Step 9: Creating Application Version${RESET}"
echo

echo "Y" | gcloud app deploy -v v1
echo "${GREEN}✓ Version v1 created${RESET}"
echo

# Completion Message
echo "${MAGENTA}${BOLD}============================================${RESET}"
echo "${MAGENTA}${BOLD}   APP ENGINE DEPLOYMENT LAB COMPLETED!    ${RESET}"
echo "${MAGENTA}${BOLD}============================================${RESET}"
echo
echo "${GREEN}${BOLD}Congratulations on completing the lab!${RESET}"
echo
echo "${BLUE}${BOLD}For more cloud tutorials:${RESET}"
echo "${CYAN}Subscribe to Dr. Abhishek's YouTube Channel:${RESET}"
echo "${YELLOW}https://www.youtube.com/@drabhishek.5460${RESET}"
echo "${CYAN}Video Tutorials:${RESET}"
echo "${YELLOW}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
