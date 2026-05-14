#!/bin/bash

# Bright Foreground Colors
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

# Displaying start message
echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}       DATAPLEX SETUP TUTORIAL BY DR. ABHISHEK            ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}For more GCP tutorials, visit: ${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Set the Location ========================== ${RESET_FORMAT}"
echo "${YELLOW_TEXT} ${BOLD_TEXT} Enter LOCATION: ${RESET_FORMAT}"
read -r LOCATION
echo
echo "${YELLOW_TEXT} ${BOLD_TEXT} You entered: ${LOCATION} ${RESET_FORMAT}"
echo

export ID=$DEVSHELL_PROJECT_ID
export REGION=${LOCATION}

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Enable Services ========================== ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT} Enabling required services (datacatalog.googleapis.com and dataplex.googleapis.com)... ${RESET_FORMAT}"
echo
gcloud services enable datacatalog.googleapis.com
gcloud services enable dataplex.googleapis.com

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Create Dataplex Lake ========================== ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}   Creating Dataplex Lake 'customer-engagements' in location ${LOCATION}  ${RESET_FORMAT}"
echo

gcloud dataplex lakes create customer-engagements \
   --location=$LOCATION \
   --display-name="Customer Engagements"

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Create Dataplex Zone ========================== ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}  Creating Dataplex Zone 'raw-event-data' in location ${LOCATION}  ${RESET_FORMAT}"
echo
gcloud dataplex zones create raw-event-data \
    --location=$LOCATION \
    --lake=customer-engagements \
    --display-name="Raw Event Data" \
    --type=RAW \
    --resource-location-type=SINGLE_REGION \
    --discovery-enabled

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Create Storage Bucket ========================== ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT} Creating storage bucket 'gs://$ID' in location ${LOCATION} for the project '${ID}'  ${RESET_FORMAT}"
echo
gsutil mb -p $ID -c REGIONAL -l $LOCATION gs://$ID

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Create Dataplex Asset ========================== ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT} Creating Dataplex Asset 'raw-event-files' in location ${LOCATION}   ${RESET_FORMAT}"
echo

gcloud dataplex assets create raw-event-files \
--location=$LOCATION \
--lake=customer-engagements \
--zone=raw-event-data \
--display-name="Raw Event Files" \
--resource-type=STORAGE_BUCKET \
--resource-name=projects/my-project/buckets/${ID}

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Create Tag Template ========================== ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT} Creating 'Protected Raw Data Template' in region ${REGION} ${RESET_FORMAT}"
echo

gcloud data-catalog tag-templates create "Protected Raw Data Template" \
    --location=$REGION \
    --display-name="Protected Raw Data Template" \
    --field=id=protected_raw_data_flag,display-name="Protected Raw Data Flag",type=enum,enum-values="Y,N",required=TRUE

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Tag the Zone ========================== ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT} Tagging 'raw-event-data' zone as protected raw data ${RESET_FORMAT}"
echo

# Look up the zone entry
ZONE_ENTRY_NAME=$(gcloud data-catalog entries lookup \
    "//dataplex.googleapis.com/projects/$ID/locations/$LOCATION/lakes/customer-engagements/zones/raw-event-data" \
    --format="value(name)")

# Create tag.json file
cat > tag.json << EOF
{
  "protected_raw_data_flag": "Y"
}
EOF

# Apply the tag
gcloud data-catalog tags create \
    --entry=$ZONE_ENTRY_NAME \
    --tag-template="Protected Raw Data Template" \
    --tag-template-location=$REGION \
    --tag-file=tag.json

PROJECT_ID=$(gcloud config get-value project)
URL="https://console.cloud.google.com/dataplex/templates/create?project=${PROJECT_ID}"

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Open Dataplex Templates URL ========================== ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}Open the following URL:${RESET_FORMAT}"
echo "${WHITE_TEXT}${BOLD_TEXT} $URL ${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}          DATAPLEX LAB COMPLETED SUCCESSFULLY!          ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${RED_TEXT}${BOLD_TEXT}Special thanks to Dr. Abhishek for this tutorial!${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}Subscribe for more GCP content:${RESET_FORMAT}"
echo "${BLUE_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}Happy Data Management with Google Cloud!${RESET_FORMAT}"
