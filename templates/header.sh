#!/bin/bash
## Created by nov05, 2026-05-11  

# Bright Foreground Colors
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
## Text format
NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

# cat >> ~/.bashrc <<'EOF'
## Get project id, project number, region, zone
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID \
  --format='value(projectNumber)')
export REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
# export BUCKET="$PROJECT_ID-bucket"
gcloud config set compute/region $REGION
echo
echo "🔹  Project ID: $PROJECT_ID"
echo "🔹  Project number: $PROJECT_NUMBER"
echo "🔹  Region: $REGION"
echo "🔹  Zone: $ZONE"
echo "🔹  User: $USER"
# echo "🔹  Bukect: $BUCKET"
echo
# EOF
# source ~/.bashrc

cat << 'EOF'

========================================================
Task 1. Create a lake, zone, and asset in Knowledge Catalog
========================================================

EOF
cat << 'EOF'

echo -e "\n✅  All done\n"
========================================================
Task 2. Query a BigQuery table to review data quality
========================================================

EOF
