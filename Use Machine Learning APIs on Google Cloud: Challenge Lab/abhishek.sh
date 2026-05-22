#!/bin/bash

# ============================================
#           mai hu jadugar
# ============================================

ORANGE='\033[38;5;208m'
DARK_ORANGE='\033[38;5;166m'
LIGHT_ORANGE='\033[38;5;215m'
GOLD='\033[38;5;220m'
WHITE='\033[1;37m'
GREEN='\033[1;32m'
RED='\033[1;31m'
CYAN='\033[1;36m'
RESET='\033[0m'

# ============================================
#                HEADER
# ============================================

clear

echo -e "${ORANGE}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${ORANGE}║                                                      ║${RESET}"
echo -e "${ORANGE}║      ${GOLD}WELCOME TO DR ABHISHEK CLOUD LAB like karo jaldi ${ORANGE}         ║${RESET}"
echo -e "${ORANGE}║                                                      ║${RESET}"
echo -e "${ORANGE}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

# ============================================
#          USER CONFIGURATION INPUT
# ============================================

echo -e "${DARK_ORANGE}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${DARK_ORANGE}║              ${WHITE}CONFIGURATION PANEL${DARK_ORANGE}                ║${RESET}"
echo -e "${DARK_ORANGE}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

read -p "$(echo -e "${LIGHT_ORANGE}ENTER LANGUAGE (en/fr/es): ${RESET}")" LANGUAGE
read -p "$(echo -e "${LIGHT_ORANGE}ENTER LOCALE (en_US/fr_FR): ${RESET}")" LOCAL
read -p "$(echo -e "${LIGHT_ORANGE}ENTER BIGQUERY ROLE: ${RESET}")" BIGQUERY_ROLE
read -p "$(echo -e "${LIGHT_ORANGE}ENTER STORAGE ROLE: ${RESET}")" CLOUD_STORAGE_ROLE

echo ""

# ============================================
#          ENABLE REQUIRED APIs
# ============================================

echo -e "${ORANGE}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${ORANGE}║                 ${WHITE}ENABLING APIs${ORANGE}                     ║${RESET}"
echo -e "${ORANGE}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

gcloud services enable vision.googleapis.com
gcloud services enable translate.googleapis.com
gcloud services enable bigquery.googleapis.com
gcloud services enable storage.googleapis.com

echo -e "${GREEN}✓ Required APIs Enabled Successfully${RESET}"
echo ""

# ============================================
#          SERVICE ACCOUNT SETUP
# ============================================

echo -e "${ORANGE}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${ORANGE}║             ${WHITE}SERVICE ACCOUNT SETUP${ORANGE}               ║${RESET}"
echo -e "${ORANGE}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

echo -e "${CYAN}→ Creating Service Account...${RESET}"

gcloud iam service-accounts create sample-sa

echo ""

echo -e "${CYAN}→ Assigning BigQuery Role...${RESET}"

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member=serviceAccount:sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com \
--role=$BIGQUERY_ROLE

echo ""

echo -e "${CYAN}→ Assigning Storage Role...${RESET}"

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member=serviceAccount:sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com \
--role=$CLOUD_STORAGE_ROLE

echo ""

echo -e "${CYAN}→ Assigning Service Usage Consumer Role...${RESET}"

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member=serviceAccount:sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com \
--role=roles/serviceusage.serviceUsageConsumer

echo ""

# ============================================
#             WAIT FOR IAM
# ============================================

echo -e "${LIGHT_ORANGE}Waiting 60 seconds for IAM propagation...${RESET}"

for i in {1..60}; do
    echo -ne "${GOLD}$i/60 seconds completed...\r${RESET}"
    sleep 1
done

echo ""
echo ""

# ============================================
#          CREATE KEY FILE
# ============================================

echo -e "${CYAN}→ Creating Credential Key...${RESET}"

gcloud iam service-accounts keys create sample-sa-key.json \
--iam-account sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com

export GOOGLE_APPLICATION_CREDENTIALS=${PWD}/sample-sa-key.json

echo -e "${GREEN}✓ Credential File Created${RESET}"
echo ""

# ============================================
#          DOWNLOAD PYTHON SCRIPT
# ============================================

echo -e "${ORANGE}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${ORANGE}║                ${WHITE}DOWNLOADING FILES${ORANGE}                  ║${RESET}"
echo -e "${ORANGE}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

wget https://raw.githubusercontent.com/guys-in-the-cloud/cloud-skill-boosts/main/Challenge-labs/Integrate%20with%20Machine%20Learning%20APIs%3A%20Challenge%20Lab/analyze-images-v2.py

echo -e "${GREEN}✓ Python Script Downloaded${RESET}"
echo ""

# ============================================
#           UPDATE LOCALE
# ============================================

echo -e "${CYAN}→ Updating Locale to ${WHITE}$LOCAL${RESET}"

sed -i "s/'en'/'${LOCAL}'/g" analyze-images-v2.py

echo -e "${GREEN}✓ Locale Updated Successfully${RESET}"
echo ""

# ============================================
#          RUN PYTHON SCRIPT
# ============================================

echo -e "${ORANGE}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${ORANGE}║               ${WHITE}RUNNING ANALYSIS${ORANGE}                   ║${RESET}"
echo -e "${ORANGE}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

python3 analyze-images-v2.py

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error Running Script${RESET}"
    exit 1
fi

python3 analyze-images-v2.py $DEVSHELL_PROJECT_ID $DEVSHELL_PROJECT_ID

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error Running BigQuery Upload${RESET}"
    exit 1
fi

echo -e "${GREEN}✓ Image Processing Completed${RESET}"
echo ""

# ============================================
#            BIGQUERY RESULT
# ============================================

echo -e "${ORANGE}╔══════════════════════════════════════════════════════╗${RESET}"
echo -e "${ORANGE}║                ${WHITE}BIGQUERY RESULTS${ORANGE}                  ║${RESET}"
echo -e "${ORANGE}╚══════════════════════════════════════════════════════╝${RESET}"
echo ""

bq query --use_legacy_sql=false \
"SELECT locale,COUNT(locale) as lcount FROM image_classification_dataset.image_text_detail GROUP BY locale ORDER BY lcount DESC"

echo ""

# ============================================
#              SUCCESS MESSAGE
# ============================================

echo -e "${GREEN}══════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}                                                      ${RESET}"
echo -e "${GREEN}        🎉 LAB COMPLETED SUCCESSFULLY 🎉              ${RESET}"
echo -e "${GREEN}                                                      ${RESET}"
echo -e "${GREEN}══════════════════════════════════════════════════════${RESET}"

echo ""
echo -e "${LIGHT_ORANGE}YouTube:${RESET} https://www.youtube.com/@drabhishek.5460/videos"
echo ""
