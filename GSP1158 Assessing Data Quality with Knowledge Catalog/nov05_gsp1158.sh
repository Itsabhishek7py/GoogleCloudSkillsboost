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
echo

cat << 'EOF'

========================================================
Task 1. Create a lake, zone, and asset in Knowledge Catalog
========================================================

EOF
## Create the Lake
gcloud dataplex lakes create ecommerce-lake \
  --project=$PROJECT_ID \
  --location=$REGION \
  --display-name="Ecommerce Lake"

## Create the Zone (Raw Zone)
gcloud dataplex zones create customer-contact-raw-zone \
  --project=$PROJECT_ID \
  --location=$REGION \
  --lake=ecommerce-lake \
  --type=RAW \
  --display-name="Customer Contact Raw Zone" \
  --resource-location-type=SINGLE_REGION

## Attach BigQuery Dataset as an Asset
gcloud dataplex assets create contact-info \
  --project=$PROJECT_ID \
  --location=$REGION \
  --lake=ecommerce-lake \
  --zone=customer-contact-raw-zone \
  --display-name="Contact Info" \
  --resource-type=BIGQUERY_DATASET \
  --resource-name="projects/$PROJECT_ID/datasets/customers"

## Verify
# gcloud dataplex lakes list --location=$REGION
# gcloud dataplex zones list \
#   --lake=ecommerce-lake \
#   --location=$REGION
# gcloud dataplex assets list \
#   --lake=ecommerce-lake \
#   --zone=customer-contact-raw-zone \
#   --location=$REGION


cat << 'EOF'

========================================================
Task 2. Query a BigQuery table to review data quality
========================================================

EOF
## Confirm dataset + table existence (optional but useful)
bq ls $PROJECT_ID:customers

bq query --use_legacy_sql=false "
SELECT *
FROM \`$PROJECT_ID.customers.contact_info\`
ORDER BY id
LIMIT 50
"

bq query --use_legacy_sql=false "
SELECT COUNT(*) AS missing_ids
FROM \`$PROJECT_ID.customers.contact_info\`
WHERE id IS NULL
"

cat << 'EOF'

========================================================
Task 3. Create and upload a data quality specification file
========================================================

EOF
cat > dq-customer-raw-data.yaml << EOF
rules:
- nonNullExpectation: {}
  column: id
  dimension: COMPLETENESS
  threshold: 1
- regexExpectation:
    regex: '^[^@]+[@]{1}[^@]+$'
  column: email
  dimension: CONFORMANCE
  ignoreNull: true
  threshold: .85
postScanActions:
  bigqueryExport:
    resultsTable: projects/PROJECT_ID/datasets/customers_dq_dataset/tables/dq_results
EOF
# sed -i "s/PROJECT_ID/$(gcloud config get-value project)/g" dq-customer-raw-data.yaml
sed -i "s|PROJECT_ID|$PROJECT_ID|g" dq-customer-raw-data.yaml

cat << 'EOF'

========================================================
Task 4. Define and run an auto data quality job in Knowledge Catalog
========================================================

EOF
cat << 'EOF'

========================================================
Task 5. Review data quality results in BigQuery
========================================================

EOF
