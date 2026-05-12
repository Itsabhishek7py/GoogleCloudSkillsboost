#!/bin/bash
## Created by nov05, 2026-05-11  

# cat >> ~/.bashrc <<'EOF'
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
# echo "🔹  Bukect: $BUCKET"
# EOF
# source ~/.bashrc

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
## https://docs.cloud.google.com/sdk/gcloud/reference/dataplex/assets/create
## https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dataplex_asset
gcloud dataplex assets create customer-details-dataset \
  --project=$PROJECT_ID \
  --location=$REGION \
  --lake=orders-lake \
  --zone=customer-curated-zone \
  --display-name="Customer Details Dataset" \
  --resource-type=BIGQUERY_DATASET \
  --resource-name="projects/$PROJECT_ID/datasets/customers"
  
: <<'COMMENT'
  If the asset is created with wrong configuration, the lab check will say:
  "Knowledge Catalog task is in running state; please wait until the creation completes."
  --resource-name="//bigquery.googleapis.com/projects/$PROJECT_ID/datasets/customers" ❌
  --resource-name="/projects/$PROJECT_ID/datasets/customers" ❌ 
COMMENT

## Verify
echo -e "\n👉  Data lake list:"
gcloud dataplex lakes list --location=$REGION

echo -e "\n👉  Data zone list:"
gcloud dataplex zones list \
  --lake=orders-lake \
  --location=$REGION

echo -e "\n👉  Data asset list:"
gcloud dataplex assets list \
  --lake=orders-lake \
  --zone=customer-curated-zone \
  --location=$REGION


cat << 'EOF'

========================================================
Task 2. Create an aspect type
========================================================
https://docs.cloud.google.com/dataplex/docs/enrich-entries-metadata#gcloud

EOF
cat > aspect-type.json <<EOF
{
  "name": "protected_data_template",
  "type": "record",
  "recordFields": [
    {
      "name": "protected_data_flag",
      "type": "enum",
      "index": 1,
      "annotations": {
        "displayName": "Protected Data Flag"
      },
      "constraints": {
        "required": true
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
    }
  ]
}
EOF

## Create aspect type
gcloud dataplex aspect-types create protected-data-aspect \
  --location=$REGION \
  --display-name="Protected Data Aspect" \
  --metadata-template-file-name=aspect-type.json
  
## Verify
echo -e "\n👉  Check entry list:"
gcloud dataplex entries list \
  --location=$REGION \
  --entry-group=@dataplex
export ASPECT_ENTRY_ID="protected-data-aspect_aspectType"

echo -e "\n👉  Check entry $ASPECT_ENTRY_ID:"
gcloud dataplex entries describe $ASPECT_ENTRY_ID \
  --location=$REGION \
  --entry-group=@dataplex

## Update aspect
# gcloud dataplex catalog entries update $ASPECT_ENTRY_ID \
#   --project=$PROJECT_ID \
#   --location=$REGION \
#   --aspect-keys="protected-data-aspect" \
#   --aspect-data-file=aspect-type.json
    
cat << 'EOF'

========================================================
Task 3. Add an aspect to assets
========================================================
https://docs.cloud.google.com/dataplex/docs/enrich-entries-metadata#gcloud
https://docs.cloud.google.com/sdk/gcloud/reference/dataplex/entries/update

EOF
cat > aspect-patch.json <<EOF
{
  "resource": "projects/'"$PROJECT_NUMBER"'/locations/'"$REGION"'/aspectTypes/protected_data_aspect@customer_details": {
    "data": {
      "protected_data_flag": "Yes"
    }
  }
}
EOF

# export TABLE_NAME="//bigquery.googleapis.com/projects/$PROJECT_ID/datasets/customers/tables/customer_details"
# export TABLE_NAME="projects/$PROJECT_ID/locations/$REGION/entryGroups/@bigquery/entries/customer_details"
# export TABLE_NAME="projects/$PROJECT_ID/datasets/customers/tables/customer_details"
gcloud dataplex entries update $ASPECT_ENTRY_ID \
    --project=$PROJECT_ID \
    --location=$REGION \
    --entry-group=@dataplex \ 
    --update-aspects=aspect-patch.json
  
cat << 'EOF'

========================================================
Task 4. Search for assets using aspects
========================================================

EOF
curl -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  "https://dataplex.googleapis.com/v1/projects/$PROJECT_ID/locations/$REGION/entries:search" \
  -d '{
    "query": "customer_details",
    "scope": {
      "aspectTypes": [
        "projects/'"$PROJECT_NUMBER"'/locations/'"$REGION"'/aspectTypes/protected_data_aspect"
      ]
    }
  }'


curl -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  "https://dataplex.googleapis.com/v1/projects/$PROJECT_ID/locations/$REGION:searchEntries" \
  -d '{
    "query": "customer_details"
  }'
