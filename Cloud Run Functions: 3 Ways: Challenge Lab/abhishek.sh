#!/bin/bash
# Define color variables

BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

echo "${CYAN}${BOLD}Please enter the following values:${RESET}"
echo ""

read -p "$(echo ${YELLOW}Enter REGION ${RESET}(e.g., us-central1, us-east1, europe-west1): " REGION
while [[ -z "$REGION" ]]; do
    echo "${RED}REGION cannot be empty. Please enter a valid region.${RESET}"
    read -p "Enter REGION: " REGION
done

read -p "$(echo ${YELLOW}Enter FUNCTION_NAME ${RESET}(e.g., my-storage-function): " FUNCTION_NAME
while [[ -z "$FUNCTION_NAME" ]]; do
    echo "${RED}FUNCTION_NAME cannot be empty. Please enter a valid name.${RESET}"
    read -p "Enter FUNCTION_NAME: " FUNCTION_NAME
done

read -p "$(echo ${YELLOW}Enter HTTP_FUNCTION ${RESET}(e.g., my-http-function): " HTTP_FUNCTION
while [[ -z "$HTTP_FUNCTION" ]]; do
    echo "${RED}HTTP_FUNCTION cannot be empty. Please enter a valid name.${RESET}"
    read -p "Enter HTTP_FUNCTION: " HTTP_FUNCTION
done

echo ""
echo "${GREEN}${BOLD}You entered:${RESET}"
echo "  REGION: ${CYAN}$REGION${RESET}"
echo "  FUNCTION_NAME: ${CYAN}$FUNCTION_NAME${RESET}"
echo "  HTTP_FUNCTION: ${CYAN}$HTTP_FUNCTION${RESET}"
echo ""

read -p "$(echo ${MAGENTA}Are these values correct? ${RESET}(y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "${RED}Exiting. Please run the script again and enter correct values.${RESET}"
    exit 1
fi

echo ""
echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

# Enable required services
gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  pubsub.googleapis.com

sleep 30

# Get project details
PROJECT_NUMBER=$(gcloud projects list --filter="project_id:$DEVSHELL_PROJECT_ID" --format='value(project_number)')

# Get the default compute service account
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

# Add IAM binding for Pub/Sub publisher
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT \
  --role roles/pubsub.publisher

# Create Cloud Storage bucket
gsutil mb -l $REGION gs://$DEVSHELL_PROJECT_ID

export BUCKET="gs://$DEVSHELL_PROJECT_ID"

# Create and deploy Cloud Storage triggered function
mkdir ~/$FUNCTION_NAME && cd $_
touch index.js && touch package.json

cat > index.js <<EOF
const functions = require('@google-cloud/functions-framework');
functions.cloudEvent('$FUNCTION_NAME', (cloudevent) => {
  console.log('A new event in your Cloud Storage bucket has been logged!');
  console.log(cloudevent);
});
EOF

cat > package.json <<EOF
{
  "name": "nodejs-functions-gen2-codelab",
  "version": "0.0.1",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/functions-framework": "^2.0.0"
  }
}
EOF

# Deploy storage function
gcloud functions deploy $FUNCTION_NAME \
  --gen2 \
  --runtime nodejs24 \
  --entry-point $FUNCTION_NAME \
  --source . \
  --region $REGION \
  --trigger-bucket $BUCKET \
  --trigger-location $REGION \
  --max-instances 2 \
  --quiet

# Wait for function to be ready
echo "Waiting for $FUNCTION_NAME to be deployed..."
sleep 30

cd ..

# Create and deploy HTTP function
mkdir ~/HTTP_FUNCTION && cd $_
touch index.js && touch package.json

cat > index.js <<EOF
const functions = require('@google-cloud/functions-framework');
functions.http('$HTTP_FUNCTION', (req, res) => {
  res.status(200).send('awesome lab');
});
EOF

cat > package.json <<EOF
{
  "name": "nodejs-functions-gen2-codelab",
  "version": "0.0.1",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/functions-framework": "^2.0.0"
  }
}
EOF

# Deploy HTTP function
gcloud functions deploy $HTTP_FUNCTION \
  --gen2 \
  --runtime nodejs24 \
  --entry-point $HTTP_FUNCTION \
  --source . \
  --region $REGION \
  --trigger-http \
  --timeout 600s \
  --max-instances 2 \
  --min-instances 1 \
  --quiet

# Wait for HTTP function to be ready
echo "Waiting for $HTTP_FUNCTION to be deployed..."
sleep 30

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

echo "${BG_GREEN}${BOLD}Subscribe to Dr. Abhishek's YouTube Channel for more awesome content!${RESET}"
echo "${CYAN}${BOLD}👉 https://www.youtube.com/@dr.abhishek${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
