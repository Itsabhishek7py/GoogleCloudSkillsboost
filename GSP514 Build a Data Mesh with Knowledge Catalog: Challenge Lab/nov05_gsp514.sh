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
echo
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
export BUCKET="$PROJECT_ID-customer-online-sessions"
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

## Create a Lake
gcloud dataplex lakes create sales-lake \
  --project=$PROJECT_ID \
  --location=$REGION \
  --display-name="Sales Lake"

## Create a raw zone 
gcloud dataplex zones create raw-customer-zone \
  --project=$PROJECT_ID \
  --location=$REGION \
  --lake=sales-lake \
  --type=RAW \
  --display-name="Raw Customer Zone" \
  --resource-location-type=SINGLE_REGION

## Create a curated zone 
gcloud dataplex zones create curated-customer-zone \
  --project=$PROJECT_ID \
  --location=$REGION \
  --lake=sales-lake \
  --type=CURATED \
  --display-name="Curated Customer Zone" \
  --resource-location-type=SINGLE_REGION
  
## Attach a bucket to a zone as asset
## https://docs.cloud.google.com/sdk/gcloud/reference/dataplex/assets/create
## https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dataplex_asset
gcloud dataplex assets create customer-engagements \
  --project=$PROJECT_ID \
  --location=$REGION \
  --lake=sales-lake \
  --zone=raw-customer-zone \
  --display-name="Customer Engagements" \
  --resource-type=STORAGE_BUCKET \
  --resource-name="projects/$PROJECT_ID/buckets/$BUCKET"

## Attach a BigQuery dataset to a zone as an Asset
gcloud dataplex assets create customer-orders \
  --project=$PROJECT_ID \
  --location=$REGION \
  --lake=orders-lake \
  --zone=curated-customer-zone \
  --display-name="Customer Orders" \
  --resource-type=BIGQUERY_DATASET \
  --resource-name="projects/$PROJECT_ID/datasets/customers"

## Verify
# echo -e "\n👉  Data lake list:"
# gcloud dataplex lakes list \
#   --location=$REGION
# echo -e "\n👉  Data zone list:"
# gcloud dataplex zones list \
#   --lake=sales-lake \
#   --location=$REGION
# echo -e "\n👉  Data asset list (row-customer-zone):"
# gcloud dataplex assets list \
#   --lake=sales-lake \
#   --zone=row-customer-zone \
#   --location=$REGION
# echo -e "\n👉  Data asset list (curated-customer-zone):"
# gcloud dataplex assets list \
#   --lake=sales-lake \
#   --zone=curated-customer-zone \
#   --location=$REGION

cat << 'EOF'

========================================================
Task 2. Create an aspect type and add an aspect to a zone
========================================================
https://docs.cloud.google.com/dataplex/docs/enrich-entries-metadata#gcloud

EOF
cat > aspect-type.json <<EOF
{
  "name": "protected_customer_data_template",
  "type": "record",
  "recordFields": [
    {
      "name": "raw_data_flag",
      "type": "enum",
      "index": 1,
      "annotations": {
        "displayName": "Raw Data Flag"
      },
      # "constraints": {
      #   "required": true
      # },
      "enumValues": [
        {
          "name": "Yes",
          "index": 1
        },
        {
          "name": "No",
          "index": 2
        }
      ]
    },
    {
      "name": "protected_contact_information_flag",
      "type": "enum",
      "index": 1,
      "annotations": {
        "displayName": "Protected Contact Information Flag"
      },
      "enumValues": [
        {
          "name": "Yes",
          "index": 1
        },
        {
          "name": "No",
          "index": 2
        }
      ]
    },
  ]
}
EOF

## Create aspect type
gcloud dataplex aspect-types create protected-customer-data-aspect \
  --location=$REGION \
  --display-name="Protected Customer Data Aspect" \
  --metadata-template-file-name=aspect-type.json
  
## Verify
echo -e "\n👉  Check entry list:"
gcloud dataplex entries list \
  --location=$REGION \
  --entry-group=@dataplex
export ASPECT_ENTRY_ID="protected-customer-data-aspect_aspectType"

echo -e "\n👉  Check entry $ASPECT_ENTRY_ID:"
gcloud dataplex entries describe $ASPECT_ENTRY_ID \
  --location=$REGION \
  --entry-group=@dataplex

cat > aspect-patch.json <<EOF
{
  "$PROJECT_ID.$REGION.protected-customer-data-aspect": {
    "data": {
      "raw_data_flag": "Yes",
      "protected_contact_information_flag": "Yes",
    },
  },
}
EOF
echo -e "👉  Check aspect-patch.json:"
cat aspect-patch.json

gcloud dataplex entries update \
  "bigquery.googleapis.com/projects/$PROJECT_ID/datasets/customers/tables/customer_details" \
  --location="$REGION" \
  --entry-group="@bigquery" \
  --update-aspects=aspect-patch.json
  
cat << 'EOF'

========================================================
Task 3. Assign a Knowledge Catalog IAM role to another user
========================================================

EOF
cat << 'EOF'

========================================================
Task 4. Create and upload a data quality specification file to Cloud Storage
========================================================

EOF
cat << 'EOF'

========================================================
Task 5. Define and run an auto data quality job in Knowledge Catalog
========================================================

EOF
echo -e "\n✅  All done\n"
