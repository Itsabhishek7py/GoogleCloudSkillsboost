#!/bin/bash
## Created by nov05, 2026-05-12

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

echo
read -p "👉  Enter username 2: " USERNAME2
export USER2=$USER2  

# cat >> ~/.bashrc <<'EOF'
## Get project id, project number, region, zone
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID \
  --format='value(projectNumber)')
export REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export BUCKET="$PROJECT_ID-bucket"
gcloud config set compute/region $REGION
echo
echo "🔹  Project ID: $PROJECT_ID"
echo "🔹  Project number: $PROJECT_NUMBER"
echo "🔹  Region: $REGION"
echo "🔹  Zone: $ZONE"
echo "🔹  User: $USER"
echo "🔹  Username 2: $USERNAME2"
echo "🔹  Bukect: $BUCKET"
echo
# EOF
# source ~/.bashrc



cat << 'EOF'

========================================================
Task 1. Create a lake, zone, and asset in Knowledge Catalog
========================================================

EOF
gcloud services enable dataplex.googleapis.com

## Create the Lake
gcloud dataplex lakes create customer-info-lake \
  --project=$PROJECT_ID \
  --location=$REGION \
  --display-name="Customer Info Lake"

## Create the Zone (Curated Zone)
gcloud dataplex zones create customer-raw-zone \
  --project=$PROJECT_ID \
  --location=$REGION \
  --lake=customer-info-lake \
  --type=RAW \
  --display-name="Customer Raw Zone" \
  --resource-location-type=SINGLE_REGION

## Attach BigQuery Dataset as an Asset
## https://docs.cloud.google.com/sdk/gcloud/reference/dataplex/assets/create
## https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dataplex_asset
gcloud dataplex assets create customer-online-sessions-bucket \
  --project=$PROJECT_ID \
  --location=$REGION \
  --lake=customer-info-lake \
  --zone=customer-raw-zone \
  --display-name="Customer Online Sessions" \
  --resource-type=STORAGE_BUCKET \
  --resource-name=gs://"$BUCKET"

  
cat << 'EOF'

========================================================
Task 2. Assign Dataplex Data Reader role to another user
========================================================

EOF
gcloud dataplex assets add-iam-policy-binding customer-online-sessions-bucket \
    --location=REGION \
    --lake=customer-info-lake \
    --zone=customer-raw-zone \
    --member="user:$USERNAME2" \
    --role="roles/dataplex.dataReader"
echo "✅ Role assigned" 

cat << 'EOF'

========================================================
Task 3. Test access to Knowledge Catalog resources as a Dataplex Data Reader
========================================================

EOF
cat << EOF
👉  Log in a new tab as $USERNAME2. Run the following commands. 
    You will receive an error, and no files are uploaded to the bucket.

export BUCKET="$PROJECT_ID-bucket"
curl -O https://storage.googleapis.com/spls/gsp1157/test.csv
gcloud storage cp test.csv gs://$BUCKET/

EOF

answer=""
echo -e "\nReady to proceed?"
while true; do
  printf " (y/n): "
  read answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    break
  fi
  ## move cursor up one line and clear it
  echo -ne "\033[1A\033[2K"
done
    
cat << 'EOF'

========================================================
Task 4. Assign Dataplex Writer role to another user
========================================================

EOF
gcloud dataplex assets add-iam-policy-binding customer-online-sessions-bucket \
    --location=REGION \
    --lake=customer-info-lake \
    --zone=customer-raw-zone \
    --member="user:$USERNAME2" \
    --role="roles/dataplex.dataWriter"
echo "✅ Role assigned"

cat << 'EOF'

========================================================
Task 5. Upload new file to Cloud Storage bucket as a Dataplex Data Writer
========================================================

EOF
cat << EOF
👉  Log in a new tab as $USER2. Run the following commands. 
    User 2 can successfully upload a new file to the Cloud Storage bucket as a Dataplex Data Writer.

export BUCKET="$PROJECT_ID-bucket"
curl -O https://storage.googleapis.com/spls/gsp1157/test.csv
gcloud storage cp test.csv gs://$BUCKET/

EOF

answer=""
echo -e "\nReady to proceed?"
while true; do
  printf " (y/n): "
  read answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    break
  fi
  ## move cursor up one line and clear it
  echo -ne "\033[1A\033[2K"
done

echo -e "\n👉  All done"
