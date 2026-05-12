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
# echo "🔹  Bukect: $BUCKET"

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
gcloud dataplex assets create customer-details-dataset \
  --location=$REGION \
  --lake=orders-lake \
  --zone=customer-curated-zone \
  --display-name="Customer Details Dataset" \
  --resource-type=BIGQUERY_DATASET \
  --resource-name="//bigquery.googleapis.com/projects/$PROJECT_ID/datasets/customers"

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

# curl -X POST \
#   -H "Authorization: Bearer $(gcloud auth print-access-token)" \
#   -H "Content-Type: application/json" \
#   "https://dataplex.googleapis.com/v1/projects/$PROJECT_ID/locations/$REGION/aspectTypes?aspectTypeId=protected_data_aspect" \
#   -d @aspect-type.json
gcloud dataplex aspect-types create protected-data-aspect \
  --location=$REGION \
  --display-name="Protected Data Aspect" \
  --metadata-template-file-name=aspect-type.json
  
cat << 'EOF'

========================================================
Task 3. Add an aspect to assets
========================================================

EOF
export BQ_RESOURCE="//bigquery.googleapis.com/projects/$PROJECT_ID/datasets/customers/tables/customer_details"
export ENTRY_NAME=$(curl -s -X GET \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  "https://dataplex.googleapis.com/v1/projects/$PROJECT_ID/locations/$REGION/entries:lookup?linkedResource=//bigquery.googleapis.com/projects/$PROJECT_ID/datasets/customers/tables/customer_details" \
  | jq -r '.name')
echo "👉  Entry name: $ENTRY_NAME"

cat > aspect-patch.json <<EOF
{
  "aspects": {
    "protected_data_aspect": {
      "data": {
        "protected_data_flag": "Yes"
      }
    }
  }
}
EOF

# curl -X PATCH \
#   -H "Authorization: Bearer $(gcloud auth print-access-token)" \
#   -H "Content-Type: application/json" \
#   "https://dataplex.googleapis.com/v1/$ENTRY_NAME?updateMask=aspects" \
#   -d @aspect-patch.json
gcloud dataplex entries update-aspects "$ENTRY_NAME" \
  --project="$PROJECT_ID" \
  --location="$REGION" \
  --entry-group="$ENTRY_GROUP" \
  --aspects-file=aspect-patch.json
echo "✅  Aspect updated"
  
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
