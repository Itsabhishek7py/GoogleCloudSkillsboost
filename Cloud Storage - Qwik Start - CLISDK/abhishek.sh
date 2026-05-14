#!/bin/bash


HEADER_COLOR=$'\033[38;5;54m'       # Deep purple
TITLE_COLOR=$'\033[38;5;93m'         # Bright purple
PROMPT_COLOR=$'\033[38;5;178m'       # Gold
ACTION_COLOR=$'\033[38;5;44m'        # Teal
SUCCESS_COLOR=$'\033[38;5;46m'       # Bright green
WARNING_COLOR=$'\033[38;5;196m'      # Bright red
LINK_COLOR=$'\033[38;5;27m'          # Blue
TEXT_COLOR=$'\033[38;5;255m'         # Bright white

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'


echo
echo "${HEADER_COLOR}${BOLD_TEXT}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET_FORMAT}"
echo "${TITLE_COLOR}${BOLD_TEXT}        🚀 DR. ABHISHEK'S CLOUD  TUTORIALS       ${RESET_FORMAT}"
echo "${HEADER_COLOR}${BOLD_TEXT}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET_FORMAT}"
echo
echo "${TEXT_COLOR}This interactive lab will guide you through Cloud Storage operations${RESET_FORMAT}"
echo "${TEXT_COLOR}using Google Cloud Platform. Follow the prompts to complete the lab.${RESET_FORMAT}"
echo

# Region selection with validation
while true; do
    read -p "${PROMPT_COLOR}${BOLD_TEXT}🌍 Enter your preferred GCP region (e.g., us-central1): ${RESET_FORMAT}" REGION
    if [ -z "$REGION" ]; then
        echo "${WARNING_COLOR}ⓘ Using default region. For production, always specify a region.${RESET_FORMAT}"
        break
    elif [[ $REGION =~ ^[a-z]+-[a-z]+[0-9]+$ ]]; then
        echo "${SUCCESS_COLOR}✓ Valid region format detected${RESET_FORMAT}"
        break
    else
        echo "${WARNING_COLOR}⚠ Invalid region format. Please use format like 'us-central1'${RESET_FORMAT}"
    fi
done

export REGION
gcloud config set compute/region $REGION
echo "${ACTION_COLOR}${BOLD_TEXT}⚙️  Configuring default region to: ${REGION}${RESET_FORMAT}"

# Cloud Storage operations with visual indicators
echo
echo "${HEADER_COLOR}${BOLD_TEXT}┏━━━━━━━━━━━━━━━━━━ CLOUD STORAGE SETUP ━━━━━━━━━━━━━━┓${RESET_FORMAT}"
echo

echo "${ACTION_COLOR}${BOLD_TEXT}🛠️  Creating Cloud Storage bucket...${RESET_FORMAT}"
gsutil mb gs://$DEVSHELL_PROJECT_ID
echo "${SUCCESS_COLOR}✓ Bucket created successfully${RESET_FORMAT}"

echo
echo "${ACTION_COLOR}${BOLD_TEXT}📥 Downloading sample image (Ada Lovelace portrait)...${RESET_FORMAT}"
curl -# https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Ada_Lovelace_portrait.jpg/800px-Ada_Lovelace_portrait.jpg --output ada.jpg
echo "${SUCCESS_COLOR}✓ Image downloaded successfully${RESET_FORMAT}"

echo
echo "${ACTION_COLOR}${BOLD_TEXT}☁️  Uploading image to Cloud Storage...${RESET_FORMAT}"
gsutil cp ada.jpg gs://$DEVSHELL_PROJECT_ID
echo "${SUCCESS_COLOR}✓ Image uploaded to bucket${RESET_FORMAT}"

echo
echo "${ACTION_COLOR}${BOLD_TEXT}⤵️  Downloading copy from bucket...${RESET_FORMAT}"
gsutil cp -r gs://$DEVSHELL_PROJECT_ID/ada.jpg .
echo "${SUCCESS_COLOR}✓ Image downloaded from bucket${RESET_FORMAT}"

echo
echo "${ACTION_COLOR}${BOLD_TEXT}🗂️  Creating organized folder structure...${RESET_FORMAT}"
gsutil cp gs://$DEVSHELL_PROJECT_ID/ada.jpg gs://$DEVSHELL_PROJECT_ID/image-folder/
echo "${SUCCESS_COLOR}✓ Folder structure created${RESET_FORMAT}"

echo
echo "${ACTION_COLOR}${BOLD_TEXT}🔓 Setting public access permissions...${RESET_FORMAT}"
gsutil acl ch -u AllUsers:R gs://$DEVSHELL_PROJECT_ID/ada.jpg
echo "${SUCCESS_COLOR}✓ Public access configured${RESET_FORMAT}"


echo
echo "${HEADER_COLOR}${BOLD_TEXT}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET_FORMAT}"
echo "${SUCCESS_COLOR}${BOLD_TEXT}          🎉 LAB COMPLETED SUCCESSFULLY! 🎉         ${RESET_FORMAT}"
echo "${HEADER_COLOR}${BOLD_TEXT}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET_FORMAT}"
echo
echo "${TEXT_COLOR}${BOLD_TEXT}You've successfully completed these Cloud Storage operations:${RESET_FORMAT}"
echo "${TEXT_COLOR}• Created and configured a storage bucket"
echo "• Uploaded and downloaded files"
echo "• Organized content with folders"
echo "• Managed access permissions${RESET_FORMAT}"
echo
echo -e "${PROMPT_COLOR}${BOLD_TEXT}💡 Continue learning at: ${LINK_COLOR}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo "${PROMPT_COLOR}${BOLD_TEXT}   Don't forget to like and subscribe!${RESET_FORMAT}"
echo
