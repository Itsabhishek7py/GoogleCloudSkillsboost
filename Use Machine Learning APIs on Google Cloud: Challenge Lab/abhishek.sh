#!/bin/bash

BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[38;5;220m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
ORANGE_TEXT=$'\033[38;5;208m'
DARK_ORANGE=$'\033[38;5;166m'
LIGHT_ORANGE=$'\033[38;5;215m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'
RESET_FORMAT=$'\033[0m'

clear

# ============================================
#                SPINNER FUNCTION
# ============================================

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'

    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " ${ORANGE_TEXT}${BOLD_TEXT}[%c] Subscribe to Dr Abhishek Cloud Tutorial...${RESET_FORMAT}  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\r"
    done

    printf "                                                                 \r"
}

# ============================================
#              WELCOME MESSAGE
# ============================================

echo "${ORANGE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}             WELCOME TO DR ABHISHEK CLOUD TUTORIAL               ${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

echo -e "${LIGHT_ORANGE}${BOLD_TEXT}Please enter the following configuration details:${RESET_FORMAT}"

read -p "$(echo -e "${YELLOW_TEXT}${BOLD_TEXT}ENTER LANGUAGE (e.g., en, fr, es): ${RESET_FORMAT}")" LANGUAGE

read -p "$(echo -e "${YELLOW_TEXT}${BOLD_TEXT}ENTER LOCAL (e.g., ja, en_US): ${RESET_FORMAT}")" LOCAL

read -p "$(echo -e "${YELLOW_TEXT}${BOLD_TEXT}ENTER BIGQUERY ROLE (roles/bigquery.admin): ${RESET_FORMAT}")" BIGQUERY_ROLE

read -p "$(echo -e "${YELLOW_TEXT}${BOLD_TEXT}ENTER CLOUD STORAGE ROLE (roles/storage.admin): ${RESET_FORMAT}")" CLOUD_STORAGE_ROLE

echo ""

# ============================================
#              VARIABLES
# ============================================

SA_NAME="sample-sa"
SA_EMAIL="${SA_NAME}@${DEVSHELL_PROJECT_ID}.iam.gserviceaccount.com"
KEY_FILE="sample-sa-key.json"
SCRIPT_NAME="analyze-images-v2.py"

# ============================================
#              ENABLE APIS
# ============================================

echo -e "${ORANGE_TEXT}${BOLD_TEXT}→ Enabling required APIs...${RESET_FORMAT}"

(
gcloud services enable \
vision.googleapis.com \
translate.googleapis.com \
bigquery.googleapis.com \
storage.googleapis.com \
--quiet
) &

spinner $!

echo -e "${GREEN_TEXT}${BOLD_TEXT}✓ APIs enabled successfully${RESET_FORMAT}\n"

# ============================================
#         CREATE SERVICE ACCOUNT
# ============================================

if gcloud iam service-accounts list --filter="email:${SA_EMAIL}" --format="value(email)" | grep -q "${SA_EMAIL}"; then

    echo -e "${YELLOW_TEXT}${BOLD_TEXT}✓ Service account already exists${RESET_FORMAT}"

else

    echo -e "${ORANGE_TEXT}${BOLD_TEXT}→ Creating service account...${RESET_FORMAT}"

    (
    gcloud iam service-accounts create ${SA_NAME} \
    --display-name="ML APIs Challenge Lab SA"
    ) &

    spinner $!

    echo -e "${GREEN_TEXT}${BOLD_TEXT}✓ Service account created${RESET_FORMAT}"

fi

echo ""

# ============================================
#             ASSIGN IAM ROLES
# ============================================

echo -e "${ORANGE_TEXT}${BOLD_TEXT}→ Assigning IAM roles...${RESET_FORMAT}"

(
for ROLE in "${BIGQUERY_ROLE}" "${CLOUD_STORAGE_ROLE}" "roles/serviceusage.serviceUsageConsumer"; do

gcloud projects add-iam-policy-binding ${DEVSHELL_PROJECT_ID} \
--member="serviceAccount:${SA_EMAIL}" \
--role="${ROLE}" \
--quiet

done
) &

spinner $!

echo -e "${GREEN_TEXT}${BOLD_TEXT}✓ IAM roles assigned${RESET_FORMAT}\n"

# ============================================
#          WAIT FOR PROPAGATION
# ============================================

echo -e "${ORANGE_TEXT}${BOLD_TEXT}→ Waiting for IAM propagation...${RESET_FORMAT}"

(
sleep 120
) &

spinner $!

echo -e "${GREEN_TEXT}${BOLD_TEXT}✓ IAM propagation completed${RESET_FORMAT}\n"

# ============================================
#            CREATE KEY FILE
# ============================================

echo -e "${ORANGE_TEXT}${BOLD_TEXT}→ Creating service account key...${RESET_FORMAT}"

rm -f ${KEY_FILE}

(
gcloud iam service-accounts keys create ${KEY_FILE} \
--iam-account="${SA_EMAIL}"
) &

spinner $!

echo -e "${GREEN_TEXT}${BOLD_TEXT}✓ Key file created${RESET_FORMAT}"

echo ""

# ============================================
#        EXPORT CREDENTIALS
# ============================================

export GOOGLE_APPLICATION_CREDENTIALS="${PWD}/${KEY_FILE}"

echo -e "${GREEN_TEXT}${BOLD_TEXT}✓ GOOGLE_APPLICATION_CREDENTIALS exported${RESET_FORMAT}"

echo ""

# ============================================
#      ACTIVATE SERVICE ACCOUNT
# ============================================

echo -e "${ORANGE_TEXT}${BOLD_TEXT}→ Activating service account...${RESET_FORMAT}"

(
gcloud auth activate-service-account \
${SA_EMAIL} \
--key-file=${KEY_FILE}
) &

spinner $!

echo -e "${GREEN_TEXT}${BOLD_TEXT}✓ Service account activated${RESET_FORMAT}"

echo ""

# ============================================
#          DOWNLOAD SCRIPT
# ============================================

echo -e "${ORANGE_TEXT}${BOLD_TEXT}→ Downloading analyze-images-v2.py...${RESET_FORMAT}"

(
wget -q -O ${SCRIPT_NAME} \
https://raw.githubusercontent.com/guys-in-the-cloud/cloud-skill-boosts/main/Challenge-labs/Integrate%20with%20Machine%20Learning%20APIs%3A%20Challenge%20Lab/analyze-images-v2.py
) &

spinner $!

echo -e "${GREEN_TEXT}${BOLD_TEXT}✓ Script downloaded successfully${RESET_FORMAT}"

echo ""

# ============================================
#            UPDATE LOCALE
# ============================================

echo -e "${ORANGE_TEXT}${BOLD_TEXT}→ Updating locale to ${LOCAL}...${RESET_FORMAT}"

(
sed -i "s/'en'/'${LOCAL}'/g" ${SCRIPT_NAME}
) &

spinner $!

echo -e "${GREEN_TEXT}${BOLD_TEXT}✓ Locale updated successfully${RESET_FORMAT}"

echo ""

# ============================================
#            RUN SCRIPT
# ============================================

echo -e "${ORANGE_TEXT}${BOLD_TEXT}→ Running image analysis...${RESET_FORMAT}"

(
python3 ${SCRIPT_NAME} ${DEVSHELL_PROJECT_ID} ${DEVSHELL_PROJECT_ID}
) &

spinner $!

if [ $? -ne 0 ]; then
    echo -e "${RED_TEXT}${BOLD_TEXT}❌ Script execution failed${RESET_FORMAT}"
    exit 1
fi

echo -e "${GREEN_TEXT}${BOLD_TEXT}✓ Image analysis completed${RESET_FORMAT}"

echo ""

# ============================================
#         BIGQUERY VERIFICATION
# ============================================

echo -e "${ORANGE_TEXT}${BOLD_TEXT}→ Running BigQuery verification query...${RESET_FORMAT}"

bq query --use_legacy_sql=false \
"SELECT locale,COUNT(locale) as lcount FROM image_classification_dataset.image_text_detail GROUP BY locale ORDER BY lcount DESC"

echo ""

# ============================================
#          COMPLETION MESSAGE
# ============================================

echo "${ORANGE_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}              LAB COMPLETED SUCCESSFULLY!              ${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"

echo ""

echo "${RED_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"

echo "${GREEN_TEXT}${BOLD_TEXT}Don't forget to Like, Share and Subscribe for more Videos${RESET_FORMAT}"
