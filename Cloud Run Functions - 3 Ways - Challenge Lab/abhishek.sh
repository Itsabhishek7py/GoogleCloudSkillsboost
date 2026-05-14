#!/bin/bash

# Color Definitions
COLOR_BLACK=$'\033[0;30m'
COLOR_RED=$'\033[0;31m'
COLOR_GREEN=$'\033[0;32m'
COLOR_YELLOW=$'\033[0;33m'
COLOR_BLUE=$'\033[0;34m'
COLOR_MAGENTA=$'\033[0;35m'
COLOR_CYAN=$'\033[0;36m'
COLOR_WHITE=$'\033[0;37m'
COLOR_RESET=$'\033[0m'

# Text Formatting
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
BLINK=$'\033[5m'
REVERSE=$'\033[7m'


echo
echo "${COLOR_CYAN}${BOLD}┌──────────────────────────────────────────────────────────────┐${COLOR_RESET}"
echo "${COLOR_CYAN}${BOLD}│             Welcome to Dr abhishek cloud tutorial              │${COLOR_RESET}"
echo "${COLOR_CYAN}${BOLD}└──────────────────────────────────────────────────────────────┘${COLOR_RESET}"
echo

# User Inputs
read -p "${COLOR_YELLOW}${BOLD}Enter Function Name: ${COLOR_RESET}" FUNCTION_NAME
echo
read -p "${COLOR_YELLOW}${BOLD}Enter HTTP Function Name: ${COLOR_RESET}" HTTP_FUNCTION
echo
read -p "${COLOR_YELLOW}${BOLD}Enter Region: ${COLOR_RESET}" REGION
echo

# Export Variables
export HTTP_FUNCTION=$HTTP_FUNCTION
export FUNCTION_NAME=$FUNCTION_NAME
export REGION=$REGION

# Enable GCP Services
echo
echo "${COLOR_BLUE}${BOLD}⏳ Enabling Required GCP Services...${COLOR_RESET}"
echo

gcloud services enable \
  artifactregistry.googleapis.com \
  cloudfunctions.googleapis.com \
  cloudbuild.googleapis.com \
  eventarc.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  pubsub.googleapis.com

sleep 30
echo "${COLOR_GREEN}${BOLD}✅ GCP services enabled successfully!${COLOR_RESET}"
echo

# Configure IAM
PROJECT_NUMBER=$(gcloud projects list --filter="project_id:$DEVSHELL_PROJECT_ID" --format='value(project_number)')
SERVICE_ACCOUNT=$(gsutil kms serviceaccount -p $PROJECT_NUMBER)

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT \
  --role roles/pubsub.publisher

echo "${COLOR_GREEN}${BOLD}✅ IAM permissions configured!${COLOR_RESET}"
echo

# Create Storage Bucket
gsutil mb -l $REGION gs://$DEVSHELL_PROJECT_ID
export BUCKET="gs://$DEVSHELL_PROJECT_ID"

echo "${COLOR_GREEN}${BOLD}✅ Storage bucket created successfully!${COLOR_RESET}"
echo

# Create Cloud Event Function
echo "${COLOR_BLUE}${BOLD}🛠️  Building Cloud Event Function...${COLOR_RESET}"
echo

mkdir ~/$FUNCTION_NAME && cd $_
touch index.js && touch package.json

cat > index.js <<EOF
const functions = require('@google-cloud/functions-framework');
functions.cloudEvent('$FUNCTION_NAME', (cloudevent) => {
  console.log('Storage event detected:');
  console.log(cloudevent);
});
EOF

cat > package.json <<EOF
{
  "name": "cloud-function-storage-trigger",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
EOF

deploy_cloud_function() {
  gcloud functions deploy $FUNCTION_NAME \
  --gen2 \
  --runtime nodejs22 \
  --entry-point $FUNCTION_NAME \
  --source . \
  --region $REGION \
  --trigger-bucket $BUCKET \
  --trigger-location $REGION \
  --max-instances 2 \
  --quiet
}

echo "${COLOR_BLUE}${BOLD}🚀 Deploying Cloud Event Function...${COLOR_RESET}"
echo

while true; do
  deploy_cloud_function
  if gcloud run services describe $FUNCTION_NAME --region $REGION &> /dev/null; then
    echo "${COLOR_GREEN}${BOLD}✅ Cloud Event Function deployed successfully!${COLOR_RESET}"
    break
  else
    echo "${COLOR_YELLOW}${BOLD}⏳ Waiting for deployment to complete...${COLOR_RESET}"
    sleep 10
  fi
done

cd ..

# Create HTTP Function
echo
echo "${COLOR_BLUE}${BOLD}🛠️  Building HTTP Trigger Function...${COLOR_RESET}"
echo

mkdir ~/$HTTP_FUNCTION && cd $_
touch index.js && touch package.json

cat > index.js <<EOF
const functions = require('@google-cloud/functions-framework');
functions.http('$HTTP_FUNCTION', (req, res) => {
  res.status(200).send('Serverless function executed successfully!');
});
EOF

cat > package.json <<EOF
{
  "name": "http-trigger-function",
  "version": "1.0.0",
  "main": "index.js",
  "dependencies": {
    "@google-cloud/functions-framework": "^3.0.0"
  }
}
EOF

deploy_http_function() {
  gcloud functions deploy $HTTP_FUNCTION \
  --gen2 \
  --runtime nodejs22 \
  --entry-point $HTTP_FUNCTION \
  --source . \
  --region $REGION \
  --trigger-http \
  --timeout 600s \
  --max-instances 2 \
  --min-instances 1 \
  --quiet
}

echo "${COLOR_BLUE}${BOLD}🚀 Deploying HTTP Function...${COLOR_RESET}"
echo

while true; do
  deploy_http_function
  if gcloud run services describe $HTTP_FUNCTION --region $REGION &> /dev/null; then
    echo "${COLOR_GREEN}${BOLD}✅ HTTP Function deployed successfully!${COLOR_RESET}"
    break
  else
    echo "${COLOR_YELLOW}${BOLD}⏳ Waiting for deployment to complete...${COLOR_RESET}"
    sleep 10
  fi
done

# Completion Message
echo
echo "${COLOR_GREEN}${BOLD}┌──────────────────────────────────────────────────────────────┐${COLOR_RESET}"
echo "${COLOR_GREEN}${BOLD}│          Lab Completed Successfully!                 │${COLOR_RESET}"
echo "${COLOR_GREEN}${BOLD}└──────────────────────────────────────────────────────────────┘${COLOR_RESET}"
echo
echo "${COLOR_MAGENTA}${BOLD}For more cloud tutorials, subscribe:${COLOR_RESET}"
echo "${COLOR_CYAN}${BOLD}https://www.youtube.com/@drabhishek.5460/videos${COLOR_RESET}"
echo "${COLOR_MAGENTA}${BOLD}Dr. Abhishek - Cloud Computing Expert${COLOR_RESET}"
echo
