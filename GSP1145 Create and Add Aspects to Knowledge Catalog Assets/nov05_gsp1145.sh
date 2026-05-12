#!/bin/bash
## Created by nov05, 2026-05-11  

## Get project id, project number, region, zone
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID \
  --format='value(projectNumber)')
export REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export BUCKET=$(gcloud config get-value project)-bucket  
gcloud config set compute/region $REGION
echo
echo "🔹  Project ID: $PROJECT_ID"
echo "🔹  Project number: $PROJECT_NUMBER"
echo "🔹  Region: $REGION"
echo "🔹  Zone: $ZONE"
echo "🔹  User: $USER"
echo "🔹  Bukect: $BUCKET"

cat << 'EOF'

========================================================
Task 1. Create a lake, zone, and asset in Knowledge Catalog
========================================================

EOF
gcloud services enable dataplex.googleapis.com

## Create the Lake
gcloud dataplex lakes create orders-lake \
  --project=$PROJECT_ID \
  --location=$REGION \
  --display-name="Orders Lake"

## Create the Zone (Curated Zone)
gcloud dataplex zones create customer-curated-zone \
  --project=$PROJECT_ID \
  --location=$REGION \
  --lake=orders-lake \
  --type=CURATED \
  --display-name="Customer Curated Zone" \
  --resource-location-type=SINGLE_REGION

## Attach BigQuery Dataset as an Asset
gcloud dataplex assets create contact-info \
  --project=$PROJECT_ID \
  --location=$REGION \
  --lake=orders-lake \
  --zone=customer-curated-zonee \
  --display-name="Customer Details Dataset" \
  --resource-type=BIGQUERY_DATASET \
  --resource-name="projects/$PROJECT_ID/datasets/customers"

## Verify
# gcloud dataplex lakes list --location=$REGION
# gcloud dataplex zones list \
#   --lake=orders-lake \
#   --location=$REGION
# gcloud dataplex assets list \
#   --lake=orders-lake \
#   --zone=customer-curated-zone \
#   --location=$REGION


cat << 'EOF'

========================================================
Task 2. Create an aspect type
========================================================

EOF
cat << 'EOF'

========================================================
Task 3. Add an aspect to assets
========================================================

EOF
cat << 'EOF'

========================================================
Task 4. Search for assets using aspects
========================================================

EOF
