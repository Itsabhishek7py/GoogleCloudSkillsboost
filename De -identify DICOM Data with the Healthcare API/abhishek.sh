#!/bin/bash
# Define rich color variables
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

# Background colors
BG_BLACK=$(tput setab 0)
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)
BG_MAGENTA=$(tput setab 5)
BG_CYAN=$(tput setab 6)
BG_WHITE=$(tput setab 7)

# Text effects
BOLD=$(tput bold)
DIM=$(tput dim)
BLINK=$(tput blink)
REVERSE=$(tput rev)
RESET=$(tput sgr0)

#----------------------------------------------------start--------------------------------------------------#

echo "${BG_BLUE}${WHITE}${BOLD}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║   🏥 Welcome To Dr Abhishek Cloud Tutorial    ║"
echo "║                                                            ║"
echo "║   📺 Learn more at:                                        ║"
echo "║   ${BLINK}https://youtube.com/@drabhishek.5460${RESET}${BG_BLUE}${WHITE}${BOLD}               ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo "${RESET}"

# Section header function
section() {
    echo ""
    echo "${BG_MAGENTA}${WHITE}${BOLD}»»» $1 «««${RESET}"
    echo ""
}

# Initialize environment
section "INITIALIZING ENVIRONMENT"
echo "${BOLD}${GREEN}✓${RESET} ${YELLOW}Setting region and zone...${RESET}"
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

echo "${BOLD}${GREEN}✓${RESET} ${YELLOW}Setting project variables...${RESET}"
PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

# TASK 1: Enable API and create dataset
section "TASK 1: ENABLE HEALTHCARE API"
echo "${BOLD}${GREEN}✓${RESET} ${CYAN}Enabling Healthcare API...${RESET}"
gcloud services enable healthcare.googleapis.com
sleep 20

echo "${BOLD}${GREEN}✓${RESET} ${CYAN}Creating healthcare dataset...${RESET}"
gcloud healthcare datasets create dataset1 --location=$REGION
sleep 50

# TASK 2: Configure IAM permissions
section "TASK 2: CONFIGURE IAM PERMISSIONS"
SERVICE_ACCOUNT_EMAIL="service-$PROJECT_NUMBER@gcp-sa-healthcare.iam.gserviceaccount.com"

echo "${BOLD}${GREEN}✓${RESET} ${BLUE}Assigning Storage Object Admin role...${RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/storage.objectAdmin"

echo "${BOLD}${GREEN}✓${RESET} ${BLUE}Assigning Healthcare Dataset Admin role...${RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/healthcare.datasetAdmin"

echo "${BOLD}${GREEN}✓${RESET} ${BLUE}Assigning DICOM Editor role...${RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/healthcare.dicomEditor"

echo "${BOLD}${GREEN}✓${RESET} ${BLUE}Assigning DICOM Store Admin role...${RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/healthcare.dicomStoreAdmin"

echo "${BOLD}${GREEN}✓${RESET} ${BLUE}Assigning Storage Object Creator role...${RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-healthcare.iam.gserviceaccount.com \
--role=roles/storage.objectCreator

echo "${BOLD}${GREEN}✓${RESET} ${BLUE}Assigning Storage Admin role...${RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-healthcare.iam.gserviceaccount.com \
--role=roles/storage.admin

echo "${BOLD}${GREEN}✓${RESET} ${BLUE}Assigning Storage Admin role to current user...${RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="user:$(gcloud config get-value account)" \
    --role="roles/storage.admin"

# TASK 3: Configure audit logs
section "TASK 3: CONFIGURE AUDIT LOGS"
echo "${BOLD}${GREEN}✓${RESET} ${MAGENTA}Updating audit logging configuration...${RESET}"
gcloud projects get-iam-policy $PROJECT_ID > policy.yaml

cat <<EOF >> policy.yaml
auditConfigs:
- auditLogConfigs:
  - logType: DATA_READ
  - logType: DATA_WRITE
  service: healthcare.googleapis.com
EOF

gcloud projects set-iam-policy $PROJECT_ID policy.yaml --quiet

# TASK 4: Create DICOM stores
section "TASK 4: CREATE DICOM STORES"
export DATASET_ID=dataset1
export DICOM_STORE_ID=dicomstore1

echo "${BOLD}${GREEN}✓${RESET} ${GREEN}Creating DICOM store via gcloud...${RESET}"
gcloud beta healthcare dicom-stores create $DICOM_STORE_ID --dataset=$DATASET_ID --location=$REGION

echo "${BOLD}${GREEN}✓${RESET} ${GREEN}Creating DICOM store via API...${RESET}"
curl -X POST \
     -H "Authorization: Bearer "$(sudo gcloud auth print-access-token) \
     -H "Content-Type: application/json; charset=utf-8" \
"https://healthcare.googleapis.com/v1beta1/projects/$PROJECT_ID/locations/$REGION/datasets/$DATASET_ID/dicomStores?dicomStoreId=dicomstore2"

# TASK 6: Import DICOM data
section "TASK 6: IMPORT DICOM DATA"
sleep 20
echo "${BOLD}${GREEN}✓${RESET} ${YELLOW}Importing DICOM images from Cloud Storage...${RESET}"
gcloud beta healthcare dicom-stores import gcs $DICOM_STORE_ID --dataset=$DATASET_ID --location=$REGION --gcs-uri=gs://spls/gsp626/LungCT-Diagnosis/R_004/*

# TASK 8: De-identify data
section "TASK 8: DE-IDENTIFY DATA"
echo "${BOLD}${GREEN}✓${RESET} ${CYAN}Starting de-identification process...${RESET}"
RESPONSE=$(curl -X POST \
    -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json; charset=utf-8" \
    --data "{
      \"destinationDataset\": \"projects/$PROJECT_ID/locations/$REGION/datasets/de-id\",
      \"config\": {
        \"dicom\": {
          \"filterProfile\": \"ATTRIBUTE_CONFIDENTIALITY_BASIC_PROFILE\"
        },
        \"image\": {
          \"textRedactionMode\": \"REDACT_NO_TEXT\"
        }
      }
    }" "https://healthcare.googleapis.com/v1beta1/projects/$PROJECT_ID/locations/$REGION/datasets/$DATASET_ID:deidentify")

OPERATION_ID=$(echo $RESPONSE | jq -r '.name' | awk -F'/' '{print $NF}')
echo "${BOLD}Operation ID:${RESET} ${WHITE}$OPERATION_ID${RESET}"

echo "${BOLD}${GREEN}✓${RESET} ${CYAN}Checking operation status...${RESET}"
curl -X GET \
"https://healthcare.googleapis.com/v1beta1/projects/$PROJECT_ID/locations/$REGION/datasets/$DATASET_ID/operations/$OPERATION_ID" \
-H "Authorization: Bearer "$(sudo gcloud auth print-access-token) \
-H 'Content-Type: application/json; charset=utf-8'

# TASK 9: Export DICOM data
section "TASK 9: EXPORT DICOM DATA"
echo "${BOLD}${GREEN}✓${RESET} ${MAGENTA}Creating storage bucket...${RESET}"
gsutil mb gs://$PROJECT_ID

SERVICE_ACCOUNT="service-$PROJECT_NUMBER@gcp-sa-healthcare.iam.gserviceaccount.com"

echo "${BOLD}${GREEN}✓${RESET} ${MAGENTA}Setting bucket permissions...${RESET}"
gsutil iam ch serviceAccount:$SERVICE_ACCOUNT:roles/storage.objectCreator gs://$DEVSHELL_PROJECT_ID

echo "${BOLD}${GREEN}✓${RESET} ${MAGENTA}Exporting DICOM images...${RESET}"
gcloud beta healthcare dicom-stores export gcs $DICOM_STORE_ID --dataset=$DATASET_ID --gcs-uri-prefix=gs://$PROJECT_ID/ --mime-type="image/jpeg; transfer-syntax=1.2.840.10008.1.2.4.50" --location=$REGION

echo "${BOLD}${GREEN}✓${RESET} ${MAGENTA}Re-importing DICOM images...${RESET}"
gcloud beta healthcare dicom-stores import gcs $DICOM_STORE_ID --dataset=$DATASET_ID --location=$REGION --gcs-uri=gs://spls/gsp626/LungCT-Diagnosis/R_004/*

# Completion message
echo ""
echo "${BG_GREEN}${BLACK}${BOLD}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║   🎉 ${WHITE LAB COMPLETED SUCCESSFULLY!${BLACK}                ║"
echo "║                                                            ║"
echo "║   ${WHITE}For more cloud tutorials:${BLACK}               ║"
echo "║   ${BLINK}${WHITE}Subscribe to Dr. Abhishek's YouTube Channel${RESET}${BG_GREEN}${BLACK}${BOLD}  ║"
echo "║   ${WHITE}https://youtube.com/@drabhishek.5460${BLACK}                ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo "${RESET}"
