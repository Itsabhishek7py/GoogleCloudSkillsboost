#!/bin/bash


PURPLE_TEXT=$'\033[0;35m'
ORANGE_TEXT=$'\033[0;33m'
NEON_GREEN_TEXT=$'\033[1;32m'
PINK_TEXT=$'\033[1;35m'
LIGHT_BLUE_TEXT=$'\033[1;34m'
LIGHT_CYAN_TEXT=$'\033[1;36m'
BOLD_WHITE=$'\033[1;37m'
RESET_FORMAT=$'\033[0m'

echo
echo "${PINK_TEXT}${BOLD_WHITE}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${PINK_TEXT}${BOLD_WHITE}          Welcome to Dr. Abhishek's Cloud Lab           ${RESET_FORMAT}"
echo "${PINK_TEXT}${BOLD_WHITE}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo

# Displaying instructions
echo "${ORANGE_TEXT}${BOLD_WHITE}Fetching the Compute Engine instance zone...${RESET_FORMAT}"
ZONE="$(gcloud compute instances list --project=$DEVSHELL_PROJECT_ID --format='value(ZONE)')"

export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value core/project)
gcloud iam service-accounts create my-natlang-sa \
  --display-name "my natural language service account"

gcloud iam service-accounts keys create ~/key.json \
  --iam-account my-natlang-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com

export GOOGLE_APPLICATION_CREDENTIALS="/home/USER/key.json"

gcloud compute ssh --zone "$ZONE" "linux-instance" --project "$DEVSHELL_PROJECT_ID" --quiet --command "gcloud ml language analyze-entities --content='Michelangelo Caravaggio, Italian painter, is known for \"The Calling of Saint Matthew\".' > result.json"
echo


echo "${PINK_TEXT}${BOLD_WHITE}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${PINK_TEXT}${BOLD_WHITE}               Lab Completed Successfully!               ${RESET_FORMAT}"
echo "${PINK_TEXT}${BOLD_WHITE}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo -e "${NEON_GREEN_TEXT}${BOLD_WHITE}Subscribe our Channel:${RESET_FORMAT} ${LIGHT_BLUE_TEXT}${BOLD_WHITE}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo -e "${LIGHT_CYAN_TEXT}${BOLD_WHITE}Follow on Instagram:${RESET_FORMAT} ${PURPLE_TEXT}${BOLD_WHITE}https://www.instagram.com/drabhishek.5460/${RESET_FORMAT}"
echo
