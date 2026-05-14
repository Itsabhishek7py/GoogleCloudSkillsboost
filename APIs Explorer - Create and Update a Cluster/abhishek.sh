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
echo "${CYAN}${BOLD}   DR. ABHISHEK'S DATAPROC DEPLOYMENT LAB   ${RESET}"
echo "${CYAN}${BOLD}============================================${RESET}"
echo "${BLUE}YouTube Channel: https://www.youtube.com/@drabhishek.5460${RESET}"
echo "${CYAN}Video Tutorials: https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo

# Zone Configuration
echo "${BLUE}${BOLD}Step 1: Configuring Compute Zone${RESET}"
echo "${WHITE}Retrieving your default compute zone from project metadata...${RESET}"
echo

export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

if [ -z "$ZONE" ]; then
  echo "${YELLOW}⚠️  No default zone detected in your project configuration!${RESET}"
  echo "${CYAN}Please specify a zone for your Dataproc cluster:${RESET}"
  read -p "${CYAN}Zone: ${RESET}" ZONE
  export ZONE
fi

echo "${GREEN}✓ Zone configured: ${ZONE}${RESET}"
echo

# Region Configuration
echo "${BLUE}${BOLD}Step 2: Configuring Compute Region${RESET}"
echo "${WHITE}Determining your project's default region...${RESET}"
echo

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

if [ -z "$REGION" ]; then
  export REGION=$(echo $ZONE | sed 's/-[a-z]$//')
  echo "${GREEN}Region derived from zone: $REGION${RESET}"
fi

echo "${GREEN}✓ Region configured: ${REGION}${RESET}"
echo

# Enable Dataproc API
echo "${BLUE}${BOLD}Step 3: Enabling Dataproc API${RESET}"
echo "${WHITE}Activating Google Cloud Dataproc service for your project...${RESET}"
echo

gcloud services enable dataproc.googleapis.com

echo
echo "${GREEN}✓ Dataproc API successfully enabled!${RESET}"
echo

# Create Dataproc Cluster
echo "${BLUE}${BOLD}Step 4: Creating Dataproc Cluster${RESET}"
echo "${YELLOW}This process may take several minutes to complete.${RESET}"
echo

gcloud dataproc clusters create my-cluster \
    --region=$REGION \
    --zone=$ZONE \
    --image-version=2.0-debian10 \
    --optional-components=JUPYTER \
    --project=$DEVSHELL_PROJECT_ID

echo
echo "${GREEN}✓ Cluster 'my-cluster' created successfully!${RESET}"
echo

# Submit Spark Job
echo "${BLUE}${BOLD}Step 5: Submitting Spark Job${RESET}"
echo

gcloud dataproc jobs submit spark \
    --cluster=my-cluster \
    --region=$REGION \
    --jars=file:///usr/lib/spark/examples/jars/spark-examples.jar \
    --class=org.apache.spark.examples.SparkPi \
    --project=$DEVSHELL_PROJECT_ID \
    -- \
    1000

echo
echo "${GREEN}✓ Spark job completed successfully!${RESET}"
echo

# Scale Cluster Workers
echo "${BLUE}${BOLD}Step 6: Scaling Cluster Workers${RESET}"
echo

gcloud dataproc clusters update my-cluster \
    --region=$REGION \
    --num-workers=3 \
    --project=$DEVSHELL_PROJECT_ID

echo
echo "${GREEN}✓ Cluster successfully scaled to 3 workers!${RESET}"
echo

# Completion Message
echo "${MAGENTA}${BOLD}============================================${RESET}"
echo "${MAGENTA}${BOLD}   DATAPROC LAB COMPLETED SUCCESSFULLY!    ${RESET}"
echo "${MAGENTA}${BOLD}============================================${RESET}"
echo
echo "${GREEN}${BOLD}Congratulations on completing the lab!${RESET}"
echo
echo "${BLUE}${BOLD}For more cloud tutorials:${RESET}"
echo "${CYAN}Subscribe to Dr. Abhishek's YouTube Channel:${RESET}"
echo "${YELLOW}https://www.youtube.com/@drabhishek.5460${RESET}"
echo "${CYAN}Video Tutorials:${RESET}"
echo "${YELLOW}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
