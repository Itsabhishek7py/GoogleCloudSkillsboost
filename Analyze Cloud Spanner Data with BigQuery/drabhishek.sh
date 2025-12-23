#!/bin/bash
set -e



echo "==============================================="
echo "🚀 Welcome to Dr Abhishek Cloud"
echo "📺 YouTube: https://www.youtube.com/@drabhishek.5460/videos"
echo "⭐ Subscribe for Google Cloud & DevOps Labs"
echo "==============================================="


PROJECT_ID=$(gcloud config get-value project)

SPANNER_INSTANCE="INSTANCE_NAME_FILLED_AFTER_LAB_START"
SPANNER_DATABASE="DATABASE_NAME_FILLED_AFTER_LAB_START"
SPANNER_TABLE="TABLE_NAME_FILLED_AFTER_LAB_START"

BQ_DATASET="DATASET_NAME_FILLED_AFTER_LAB_START"
BQ_CONNECTION="spanner_connection"
BQ_LOCATION="US"


echo "🔧 Enabling required APIs..."
gcloud services enable \
  bigquery.googleapis.com \
  bigqueryconnection.googleapis.com \
  spanner.googleapis.com


echo "🔗 Creating BigQuery-Spanner connection..."
bq mk \
  --connection \
  --connection_type=CLOUD_SPANNER \
  --location=$BQ_LOCATION \
  --project_id=$PROJECT_ID \
  --display_name="Spanner to BigQuery Connection" \
  --properties="instanceId=projects/$PROJECT_ID/instances/$SPANNER_INSTANCE;database=$SPANNER_DATABASE" \
  $BQ_CONNECTION


echo "🔐 Granting Spanner read access..."
CONNECTION_SA=$(bq show --connection --location=$BQ_LOCATION $BQ_CONNECTION \
  | grep "serviceAccountId" | awk -F\" '{print $4}')

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$CONNECTION_SA" \
  --role="roles/spanner.databaseReader"

echo "📊 Creating BigQuery View: order_history..."
bq query --use_legacy_sql=false <<EOF
CREATE OR REPLACE VIEW \`${PROJECT_ID}.${BQ_DATASET}.order_history\` AS
SELECT *
FROM EXTERNAL_QUERY(
  '${PROJECT_ID}.${BQ_LOCATION}.${BQ_CONNECTION}',
  'SELECT * FROM ${SPANNER_TABLE}'
);
EOF

echo "==============================================="
echo "✅ BigQuery connection created successfully"
echo "✅ View order_history created successfully"
echo "🙏 Thanks for using Dr Abhishek Cloud"
echo "👉 Subscribe: https://www.youtube.com/@drabhishek.5460/videos"
echo "==============================================="
