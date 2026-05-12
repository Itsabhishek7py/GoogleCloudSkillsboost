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

bq query \
  --use_legacy_sql=false "\
SELECT *
FROM \`$PROJECT_ID.customers.contact_info\`
ORDER BY id
LIMIT 50
"

bq query \
  --use_legacy_sql=false "\
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
gsutil cp dq-customer-raw-data.yaml gs://$BUCKET/

cat << 'EOF'

========================================================
Task 4. Define and run an auto data quality job in Knowledge Catalog
========================================================

EOF
## Create the Data Quality Scan (CLI equivalent of the UI job)
gcloud dataplex datascans create data-quality customer-orders-data-quality-job \
  --project=$PROJECT_ID \
  --location=$REGION \
  --data-source-resource="//bigquery.googleapis.com/projects/$PROJECT_ID/datasets/customers/tables/contact_info" \
  --data-quality-spec-file="gs://$BUCKET/dq-customer-raw-data.yaml"

## Run the job
gcloud dataplex datascans run customer-orders-data-quality-job \
  --location=$REGION
echo "👉  Running customer-orders-data-quality-job..."

## Check status
while true; do
  STATUS=$(gcloud dataplex datascans describe customer-orders-data-quality-job \
    --location=$REGION \
    --format="value(state)")
  echo "🔹  Job status: $STATUS"
  ## Don't stop for RUNNING, PENDING, CREATING, INITIALIZING
  if [[ "$STATUS" == "SUCCEEDED" || "$STATUS" == "FAILED" ]]; then
    break
  fi
  sleep 10
done
  
## View result
bq query --use_legacy_sql=false "\
SELECT *
FROM \`$PROJECT_ID.customers_dq_dataset.dq_results\`
"


cat << 'EOF'

========================================================
Task 5. Review data quality results in BigQuery
========================================================

EOF
echo "👉  List datasets:"  
bq ls $PROJECT_ID
echo
echo "👉  List tables in dataset customers_dq_dataset:" 
bq ls $PROJECT_ID:customers_dq_dataset
echo
echo "👉  Preview dq_results table"
bq head -n 20 $PROJECT_ID:customers_dq_dataset.dq_results

echo
echo "👉  Query the email values in the contact_info table that are not valid."
EMAIL_QUERY=$(bq query --use_legacy_sql=false --format=prettyjson "\
SELECT rule_failed_records_query
FROM \`$PROJECT_ID.customers_dq_dataset.dq_results\`
LIMIT 1
" | jq -r '.[0].rule_failed_records_query')
bq query --use_legacy_sql=false "$EMAIL_QUERY"

echo
echo "👉  Query the ID values in the contact_info table that are not valid."
ID_QUERY=$(bq query --use_legacy_sql=false --format=prettyjson "\
SELECT rule_failed_records_query
FROM \`$PROJECT_ID.customers_dq_dataset.dq_results\`
LIMIT 2
" | jq -r '.[1].rule_failed_records_query')
bq query --use_legacy_sql=false "$ID_QUERY"

echo
echo "✅  All done"
