#!/bin/bash
## Created by nov05, 2026-05-09

set -e

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

# Instruction for entering the region
# read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the region:${RESET_FORMAT} " REGION
# export REGION=$REGION

# ====== CONFIG ======
# REGION="us-central1"   # <-- change this to your lab region if different
REPO_NAME="example-docker-repo"
IMAGE_NAME="sample-image"
TAG="tag1"

# ====== GET PROJECT ID ======
export PROJECT_ID=$(gcloud config get-value project)
echo "Project: $PROJECT_ID"

# ====== CREATE REPOSITORY ======
echo "👉 Creating Artifact Registry repo..."
gcloud artifacts repositories create $REPO_NAME \
  --repository-format=docker \
  --location=$REGION \
  --description="Docker repository" \
  --project=$PROJECT_ID || true

# ====== VERIFY REPO ======
gcloud artifacts repositories list --project=$PROJECT_ID

# ====== CONFIGURE DOCKER AUTH ======
echo "👉 Configuring Docker authentication..."
gcloud auth configure-docker ${REGION}-docker.pkg.dev -q

# ====== PULL SAMPLE IMAGE ======
echo "👉 Pulling sample image..."
docker pull us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0

# ====== TAG IMAGE ======
LOCAL_IMAGE="us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0"
DEST_IMAGE="${REGION}-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:$TAG"

echo "👉 Tagging image..."
docker tag $LOCAL_IMAGE $DEST_IMAGE

# ====== PUSH IMAGE ======
echo "👉 Pushing image to Artifact Registry..."
docker push $DEST_IMAGE

# ====== PULL IMAGE BACK ======
echo "👉 Pulling image back from Artifact Registry..."
docker pull $DEST_IMAGE

echo "✅ ALL DONE"
