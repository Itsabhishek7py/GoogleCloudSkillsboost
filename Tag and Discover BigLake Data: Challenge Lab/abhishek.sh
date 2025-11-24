#!/bin/bash

# Enhanced Color Definitions
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

# Special Formatting
NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'
BLINK_TEXT=$'\033[5m'
REVERSE_TEXT=$'\033[7m'

clear
# Welcome Banner
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         BIGQUERY DATA GOVERNANCE TUTORIAL               ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}          Expert Tutorial by Dr. Abhishek              ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}   Learn more at: ${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo
echo "${BLUE_TEXT}${BLINK_TEXT}⚡ Initializing BigQuery Data Governance Setup...${RESET_FORMAT}"
echo

# Section 1: Region Configuration
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬▬ REGION SETUP ▬▬▬▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo "${WHITE_TEXT}${BOLD_TEXT}🌍 Please Enter REGION (e.g., us-central1): ${RESET_FORMAT}"
read -r REGION
export REGION=$REGION
echo "${CYAN_TEXT}${REVERSE_TEXT} Selected Region: $REGION ${RESET_FORMAT}"
echo

# Section 2: Service Enablement
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬ SERVICE ENABLEMENT ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}🛠️  Enabling Data Catalog API...${RESET_FORMAT}"
gcloud services enable datacatalog.googleapis.com
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Data Catalog API enabled successfully!${RESET_FORMAT}"
echo

# Section 3: Dataset Creation
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬ DATASET CREATION ▬▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}📊 Creating 'ecommerce' dataset in BigQuery...${RESET_FORMAT}"
bq mk ecommerce
echo "${GREEN_TEXT}${BOLD_TEXT}✅ 'ecommerce' dataset created successfully!${RESET_FORMAT}"
echo

# Section 4: Connection Setup
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬ CONNECTION SETUP ▬▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}🔗 Enabling BigQuery Connection API...${RESET_FORMAT}"
gcloud services enable bigqueryconnection.googleapis.com
echo "${GREEN_TEXT}${BOLD_TEXT}✅ API enabled successfully!${RESET_FORMAT}"

echo "${MAGENTA_TEXT}${BOLD_TEXT}🔌 Creating 'customer_data_connection'...${RESET_FORMAT}"
bq mk --connection --location=$REGION --project_id=$DEVSHELL_PROJECT_ID \
    --connection_type=CLOUD_RESOURCE customer_data_connection
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Connection created successfully!${RESET_FORMAT}"
echo

# Section 5: IAM Configuration
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬▬ IAM CONFIGURATION ▬▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}👤 Retrieving service account...${RESET_FORMAT}"
CLOUD=$(bq show --connection $DEVSHELL_PROJECT_ID.$REGION.customer_data_connection | grep "serviceAccountId" | awk '{gsub(/"/, "", $8); print $8}')
NEWs="${CLOUD%?}"
echo "${CYAN_TEXT}${BOLD_TEXT}Service Account: ${WHITE_TEXT}$NEWs${RESET_FORMAT}"

echo "${YELLOW_TEXT}${BOLD_TEXT}🔑 Adding IAM policy binding...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
    --member="serviceAccount:$NEWs" \
    --role="roles/storage.objectViewer"
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Permissions granted successfully!${RESET_FORMAT}"
echo

# Section 6: External Table Setup
echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ EXTERNAL TABLE SETUP ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}📋 Creating 'customer_online_sessions' external table...${RESET_FORMAT}"
bq mk --external_table_definition=gs://$DEVSHELL_PROJECT_ID-bucket/customer-online-sessions.csv \
ecommerce.customer_online_sessions
echo "${GREEN_TEXT}${BOLD_TEXT}✅ External table created successfully!${RESET_FORMAT}"
echo

# Section 7: Data Catalog Configuration
# echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ DATA CATALOG SETUP ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
# echo "${YELLOW_TEXT}${BOLD_TEXT}🏷️  Creating 'sensitive_data_template' tag template...${RESET_FORMAT}"
# gcloud data-catalog tag-templates create sensitive_data_template \
#     --location=$REGION \
#     --display-name="Sensitive Data Template" \
#     --field=id=has_sensitive_data,display-name="Has Sensitive Data",type=bool \
#     --field=id=sensitive_data_type,display-name="Sensitive Data Type",type='enum(Location Info|Contact Info|None)'
# echo "${GREEN_TEXT}${BOLD_TEXT}✅ Tag template created successfully!${RESET_FORMAT}"

# echo "${YELLOW_TEXT}${BOLD_TEXT}📝 Creating tag configuration...${RESET_FORMAT}"
# cat > tag_file.json << EOF
#   {
#     "has_sensitive_data": TRUE,
#     "sensitive_data_type": "Location Info"
#   }
# EOF

# echo "${YELLOW_TEXT}${BOLD_TEXT}🔍 Looking up table entry...${RESET_FORMAT}"
# ENTRY_NAME=$(gcloud data-catalog entries lookup '//bigquery.googleapis.com/projects/'$DEVSHELL_PROJECT_ID'/datasets/ecommerce/tables/customer_online_sessions' --format="value(name)")
# echo "${CYAN_TEXT}${BOLD_TEXT}Entry Name: ${WHITE_TEXT}$ENTRY_NAME${RESET_FORMAT}"

# echo "${YELLOW_TEXT}${BOLD_TEXT}🏷️  Applying tag to table...${RESET_FORMAT}"
# gcloud data-catalog tags create --entry=${ENTRY_NAME} \
#     --tag-template=sensitive_data_template --tag-template-location=$REGION --tag-file=tag_file.json
# echo "${GREEN_TEXT}${BOLD_TEXT}✅ Tag applied successfully!${RESET_FORMAT}"


echo "${YELLOW_TEXT}${BOLD_TEXT}🔍 Looking up table entry...${RESET_FORMAT}"
ENTRY_NAME=$(gcloud data-catalog entries lookup '//bigquery.googleapis.com/projects/'$DEVSHELL_PROJECT_ID'/datasets/ecommerce/tables/customer_online_sessions' --format="value(name)")
echo "${CYAN_TEXT}${BOLD_TEXT}Entry Name: ${WHITE_TEXT}$ENTRY_NAME${RESET_FORMAT}"

echo "${YELLOW_TEXT}${BOLD_TEXT}🏷️  Applying tag to table...${RESET_FORMAT}"
gcloud data-catalog tags create --entry=${ENTRY_NAME} \
    --tag-template=sensitive_data_template --tag-template-location=$REGION --tag-file=tag_file.json
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Tag applied successfully!${RESET_FORMAT}"
echo

# Completion Banner
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}          LAB IS NOW COMPLETE!                ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${RED_TEXT}${BOLD_TEXT}🙏 Special thanks to Dr. Abhishek for this tutorial!${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}📺 Subscribe for more GCP content:${RESET_FORMAT}"
echo "${BLUE_TEXT}${UNDERLINE_TEXT}${BOLD_TEXT}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}🔐 Happy secure data processing with BigQuery!${RESET_FORMAT}"
