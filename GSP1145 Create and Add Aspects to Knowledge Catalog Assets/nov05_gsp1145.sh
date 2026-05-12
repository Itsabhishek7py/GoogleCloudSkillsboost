#!/bin/bash
## Created by nov05, 2026-05-11  

cat >> ~/.bashrc <<'EOF'
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
EOF
source ~/.bashrc

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
  --resource-name="//bigquery.googleapis.com/projects/$PROJECT_ID/datasets/customers"

## Verify
echo
echo "👉  Data lake list:"
gcloud dataplex lakes list --location=$REGION

echo
echo "👉  Data zone list:"
gcloud dataplex zones list \
  --lake=orders-lake \
  --location=$REGION

echo
echo "👉  Data asset list:"
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

gcloud dataplex aspect-types create protected-data-aspect \
  --location=$REGION \
  --display-name="Protected Data Aspect" \
  --metadata-template-file-name=aspect-type.json
  
cat << 'EOF'

========================================================
Task 3. Add an aspect to assets
========================================================
https://docs.cloud.google.com/sdk/gcloud/reference/dataplex/entries/update-aspects

EOF
export BQ_RESOURCE="//bigquery.googleapis.com/projects/$PROJECT_ID/datasets/customers/tables/customer_details"
export ENTRY_ID="protected-data-aspect_aspectType"

cat > aspect-patch.json <<EOF
{
  "projects/$PROJECT_NUMBER/locations/$REGION/aspectTypes/protected-data-aspect@zip": {
    "data": { "protected_data_flag": "Yes" }
  },
  "projects/$PROJECT_NUMBER/locations/$REGION/aspectTypes/protected-data-aspect@state": {
    "data": { "protected_data_flag": "Yes" }
  },
  "projects/$PROJECT_NUMBER/locations/$REGION/aspectTypes/protected-data-aspect@last_name": {
    "data": { "protected_data_flag": "Yes" }
  },
  "projects/$PROJECT_NUMBER/locations/$REGION/aspectTypes/protected-data-aspect@country": {
    "data": { "protected_data_flag": "Yes" }
  },
  "projects/$PROJECT_NUMBER/locations/$REGION/aspectTypes/protected-data-aspect@email": {
    "data": { "protected_data_flag": "Yes" }
  },
  "projects/$PROJECT_NUMBER/locations/$REGION/aspectTypes/protected-data-aspect@latitude": {
    "data": { "protected_data_flag": "Yes" }
  },
  "projects/$PROJECT_NUMBER/locations/$REGION/aspectTypes/protected-data-aspect@first_name": {
    "data": { "protected_data_flag": "Yes" }
  },
  "projects/$PROJECT_NUMBER/locations/$REGION/aspectTypes/protected-data-aspect@city": {
    "data": { "protected_data_flag": "Yes" }
  },
  "projects/$PROJECT_NUMBER/locations/$REGION/aspectTypes/protected-data-aspect@longitude": {
    "data": { "protected_data_flag": "Yes" }
  }
}
EOF

echo "👉  Check entry list:"
gcloud dataplex entries list \
  --location=$REGION \
  --entry-group=@dataplex
: <<'COMMENT'
COMMENT

# curl -X PATCH \
#   -H "Authorization: Bearer $(gcloud auth print-access-token)" \
#   -H "Content-Type: application/json" \
#   https://dataplex.googleapis.com/v1/projects/$PROJECT_ID/locations/$REGION/entryGroups/YOUR_GROUP/entries/customer_details/aspects/protected_data_aspect \
#   -d @aspect-patch.json
gcloud dataplex entries update-aspects "$ENTRY_ID" \
  --project="$PROJECT_ID" \
  --location="$REGION" \
  --entry-group=@dataplex \
  --aspects=aspect-patch.json
echo "✅  Aspect $ENTRY_ID updated"
  
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
        "projects/'"$PROJECT_ID"'/locations/'"$REGION"'/aspectTypes/protected_data_aspect"
      ]
    }
  }'
