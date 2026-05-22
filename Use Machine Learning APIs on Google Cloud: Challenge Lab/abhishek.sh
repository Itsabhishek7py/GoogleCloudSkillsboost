#!/bin/bash

# ============================================
# fir se agyaa copy krne is bar iska report bhjeta hu
# ============================================

ORANGE='\033[38;5;208m'
DARK_ORANGE='\033[38;5;166m'
LIGHT_ORANGE='\033[38;5;215m'
GOLD='\033[38;5;220m'
GREEN='\033[1;32m'
RED='\033[1;31m'
WHITE='\033[1;37m'
CYAN='\033[1;36m'
RESET='\033[0m'

clear

# ============================================
#                HEADER
# ============================================

echo -e "${ORANGE}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${ORANGE}║                                                      ║${RESET}"
echo -e "${ORANGE}║        ${GOLD}DR ABHISHEK CLOUD LAB AUTOMATION${ORANGE}       ║${RESET}"
echo -e "${ORANGE}║                                                      ║${RESET}"
echo -e "${ORANGE}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

# ============================================
#          USER INPUT SECTION
# ============================================

echo -e "${DARK_ORANGE}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${DARK_ORANGE}║               ${WHITE}CONFIGURATION PANEL${DARK_ORANGE}               ║${RESET}"
echo -e "${DARK_ORANGE}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

read -p "$(echo -e "${LIGHT_ORANGE}ENTER LANGUAGE (ex: en/ja/fr): ${RESET}")" LANGUAGE
read -p "$(echo -e "${LIGHT_ORANGE}ENTER LOCALE (ex: en_US/ja_JP): ${RESET}")" LOCAL

echo ""

# ============================================
#             ENABLE APIS
# ============================================

echo -e "${ORANGE}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${ORANGE}║                  ${WHITE}ENABLING APIs${ORANGE}                    ║${RESET}"
echo -e "${ORANGE}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

gcloud services enable vision.googleapis.com
gcloud services enable translate.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable storage.googleapis.com

echo ""
echo -e "${GREEN}✓ APIs Enabled Successfully${RESET}"
echo ""

# ============================================
#        SERVICE ACCOUNT CREATION
# ============================================

echo -e "${ORANGE}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${ORANGE}║              ${WHITE}SERVICE ACCOUNT SETUP${ORANGE}               ║${RESET}"
echo -e "${ORANGE}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

echo -e "${CYAN}→ Creating Service Account...${RESET}"

gcloud iam service-accounts create sample-sa --quiet

echo ""

# ============================================
#         EXPORT ROLE VARIABLES
# ============================================

export BIGQUERY_ROLE="roles/bigquery.admin"
export CLOUD_STORAGE_ROLE="roles/storage.admin"

echo -e "${GREEN}✓ Roles Exported${RESET}"
echo ""

# ============================================
#         ASSIGN IAM ROLES
# ============================================

echo -e "${CYAN}→ Assigning IAM Roles...${RESET}"

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member="serviceAccount:sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
--role="$BIGQUERY_ROLE" --quiet

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member="serviceAccount:sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
--role="$CLOUD_STORAGE_ROLE" --quiet

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member="serviceAccount:sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/serviceusage.serviceUsageConsumer" --quiet

echo ""
echo -e "${GREEN}✓ IAM Roles Assigned${RESET}"
echo ""

# ============================================
#           WAIT FOR IAM
# ============================================

echo -e "${LIGHT_ORANGE}Waiting for IAM propagation...${RESET}"

for i in {1..60}; do
    echo -ne "${GOLD}$i/60 seconds completed...\r${RESET}"
    sleep 1
done

echo ""
echo ""

# ============================================
#          CREATE FRESH KEY
# ============================================

echo -e "${CYAN}→ Creating Fresh Credential Key...${RESET}"

rm -f key.json

gcloud iam service-accounts keys create key.json \
--iam-account=sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com

echo ""

# ============================================
#         EXPORT CREDENTIALS
# ============================================

export GOOGLE_APPLICATION_CREDENTIALS=$(pwd)/key.json

echo -e "${GREEN}✓ Credentials Exported${RESET}"
echo ""

# ============================================
#      ACTIVATE SERVICE ACCOUNT
# ============================================

echo -e "${CYAN}→ Activating Service Account...${RESET}"

gcloud auth activate-service-account \
sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com \
--key-file=key.json

echo ""
echo -e "${GREEN}✓ Service Account Activated${RESET}"
echo ""

# ============================================
#       DOWNLOAD PYTHON SCRIPT
# ============================================

echo -e "${ORANGE}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${ORANGE}║               ${WHITE}DOWNLOADING SCRIPT${ORANGE}                  ║${RESET}"
echo -e "${ORANGE}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

wget -O analyze-images-v2.py \
https://raw.githubusercontent.com/guys-in-the-cloud/cloud-skill-boosts/main/Challenge-labs/Integrate%20with%20Machine%20Learning%20APIs%3A%20Challenge%20Lab/analyze-images-v2.py

echo ""
echo -e "${GREEN}✓ Script Downloaded${RESET}"
echo ""

# ============================================
#            UPDATE LOCALE
# ============================================

echo -e "${CYAN}→ Updating Locale to ${WHITE}$LOCAL${RESET}"

sed -i "s/'en'/'${LOCAL}'/g" analyze-images-v2.py

echo ""
echo -e "${GREEN}✓ Locale Updated${RESET}"
echo ""

# ============================================
#           RUN SCRIPT
# ============================================

echo -e "${ORANGE}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${ORANGE}║                ${WHITE}RUNNING ANALYSIS${ORANGE}                  ║${RESET}"
echo -e "${ORANGE}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

python3 analyze-images-v2.py $DEVSHELL_PROJECT_ID $DEVSHELL_PROJECT_ID

if [ $? -ne 0 ]; then
    echo ""
    echo -e "${RED}❌ Script Failed${RESET}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Image Analysis Completed${RESET}"
echo ""

# ============================================
#           BIGQUERY QUERY
# ============================================

echo -e "${ORANGE}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${ORANGE}║                 ${WHITE}BIGQUERY RESULTS${ORANGE}                  ║${RESET}"
echo -e "${ORANGE}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

bq query --use_legacy_sql=false \
"SELECT locale,COUNT(locale) as lcount FROM image_classification_dataset.image_text_detail GROUP BY locale ORDER BY lcount DESC"

echo ""

# ============================================
#             SUCCESS MESSAGE
# ============================================

echo -e "${GREEN}══════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}                                                      ${RESET}"
echo -e "${GREEN}        🎉 LAB COMPLETED SUCCESSFULLY 🎉              ${RESET}"
echo -e "${GREEN}                                                      ${RESET}"
echo -e "${GREEN}══════════════════════════════════════════════════════${RESET}"

echo ""
echo -e "${LIGHT_ORANGE}YouTube:${RESET} https://www.youtube.com/@drabhishek.5460/videos"
echo ""
