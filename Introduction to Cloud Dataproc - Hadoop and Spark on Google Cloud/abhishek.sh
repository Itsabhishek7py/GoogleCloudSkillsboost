#!/bin/bash

# ==============================================
#  Dataproc Cluster Deployment 
#  Created by Dr. Abhishek Cloud Tutorials
#  YouTube: https://www.youtube.com/@drabhishek.5460
# ==============================================

# Text styles and colors
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Header
echo
echo "${BLUE}${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo "${BLUE}${BOLD}║   GOOGLE CLOUD DATAPROC DEPLOYMENT      ║${RESET}"
echo "${BLUE}${BOLD}║        by Dr. Abhishek Cloud           ║${RESET}"
echo "${BLUE}${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo

# Function to show spinner
show_spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Get user input
echo "${YELLOW}${BOLD}Please provide the following configuration details:${RESET}"
read -p "${YELLOW}${BOLD}Enter the CLUSTER_NAME: ${RESET}" CLUSTER_NAME
export CLUSTER_NAME

# Initialize environment
echo
echo "${BLUE}${BOLD}🔧 Initializing environment...${RESET}"
gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export PROJECT_ID=$(gcloud config get-value project)
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

echo "${GREEN}✓ Environment configured${RESET}"
echo " Project: ${PROJECT_ID}"
echo " Region:  ${REGION}"
echo " Zone:    ${ZONE}"
echo

# Configure IAM permissions
echo "${BLUE}${BOLD}🔐 Configuring IAM permissions...${RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
    --role="roles/storage.admin" > /dev/null 2>&1 &
show_spinner
echo "${GREEN}✓ Permissions configured${RESET}"

# Cluster deployment function
deploy_cluster() {
    echo
    echo "${BLUE}${BOLD}🚀 Deploying Dataproc cluster '$CLUSTER_NAME'...${RESET}"
    gcloud dataproc clusters create "$CLUSTER_NAME" \
        --region "$REGION" \
        --zone "$ZONE" \
        --master-machine-type n1-standard-2 \
        --worker-machine-type n1-standard-2 \
        --num-workers 2 \
        --worker-boot-disk-size 100 \
        --worker-boot-disk-type pd-standard \
        --no-address > /dev/null 2>&1
}

# Cluster deployment with retry logic
cp_success=false
attempt=1
max_attempts=3

while [ "$cp_success" = false ] && [ "$attempt" -le "$max_attempts" ]; do
    deploy_cluster
    exit_status=$?

    if [ "$exit_status" -eq 0 ]; then
        echo "${GREEN}✓ Cluster deployed successfully${RESET}"
        cp_success=true
    else
        echo "${RED}✗ Cluster creation failed (Attempt $attempt of $max_attempts)${RESET}"
        
        if gcloud dataproc clusters describe "$CLUSTER_NAME" --region "$REGION" &>/dev/null; then
            echo "${YELLOW}Cluster already exists. Deleting...${RESET}"
            gcloud dataproc clusters delete "$CLUSTER_NAME" --region "$REGION" --quiet > /dev/null 2>&1 &
            show_spinner
            echo "${GREEN}✓ Existing cluster deleted${RESET}"
        fi
        
        attempt=$((attempt + 1))
        if [ "$attempt" -le "$max_attempts" ]; then
            echo "${YELLOW}Retrying in 10 seconds...${RESET}"
            sleep 10
        fi
    fi
done

if [ "$cp_success" = false ]; then
    echo "${RED}${BOLD}Failed to deploy cluster after $max_attempts attempts. Exiting.${RESET}"
    exit 1
fi

# Submit Spark job
echo
echo "${BLUE}${BOLD}⚡ Submitting Spark job to cluster...${RESET}"
gcloud dataproc jobs submit spark \
    --project $PROJECT_ID \
    --region $REGION \
    --cluster $CLUSTER_NAME \
    --class org.apache.spark.examples.SparkPi \
    --jars file:///usr/lib/spark/examples/jars/spark-examples.jar \
    -- 1000 > /dev/null 2>&1 &
show_spinner
echo "${GREEN}✓ Spark job submitted${RESET}"

# Final output
echo
echo "${BLUE}${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo "${BLUE}${BOLD}║        DEPLOYMENT COMPLETE!             ║${RESET}"
echo "${BLUE}${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo
echo "${BOLD}Next steps:${RESET}"
echo " • View your Dataproc jobs:"
echo "   ${BLUE}https://console.cloud.google.com/dataproc/jobs?project=${PROJECT_ID}${RESET}"
echo " • Manage your cluster:"
echo "   ${BLUE}https://console.cloud.google.com/dataproc/clusters?project=${PROJECT_ID}${RESET}"
echo
echo "${YELLOW}${BOLD}For more cloud tutorials, subscribe to:${RESET}"
echo "${BLUE}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
