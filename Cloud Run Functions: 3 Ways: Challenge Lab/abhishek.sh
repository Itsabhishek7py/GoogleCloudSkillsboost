#!/bin/bash

# Enable strict error handling
set -e
set -o pipefail

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

# Function to validate function name
validate_function_name() {
    local name=$1
    if [ -z "$name" ]; then
        echo "${COLOR_RED}Error: Function name cannot be empty${COLOR_RESET}"
        return 1
    fi
    if [[ ! $name =~ ^[a-z][a-z0-9-]{4,61}[a-z0-9]$ ]]; then
        echo "${COLOR_RED}Error: Invalid function name '$name'${COLOR_RESET}"
        echo "Function names must:"
        echo "  - Start with a letter"
        echo "  - End with alphanumeric"
        echo "  - Only lowercase letters, numbers, hyphens"
        echo "  - Be 6-63 characters long"
        return 1
    fi
    return 0
}

# Function to validate region
validate_region() {
    local region=$1
    if [ -z "$region" ]; then
        echo "${COLOR_RED}Error: Region cannot be empty${COLOR_RESET}"
        return 1
    fi
    return 0
}

# Function to validate bucket name
validate_bucket() {
    local bucket=$1
    if [ -z "$bucket" ]; then
        echo "${COLOR_RED}Error: Bucket name cannot be empty${COLOR_RESET}"
        return 1
    fi
    return 0
}

# Check required variables
if [ -z "$DEVSHELL_PROJECT_ID" ]; then
    echo "${COLOR_RED}Error: DEVSHELL_PROJECT_ID environment variable not set${COLOR_RESET}"
    echo "Please set it using: export DEVSHELL_PROJECT_ID=your-project-id"
    exit 1
fi

echo
echo "${COLOR_CYAN}${BOLD}┌──────────────────────────────────────────────────────────────┐${COLOR_RESET}"
echo "${COLOR_CYAN}${BOLD}│             Welcome to Dr abhishek cloud tutorial              │${COLOR_RESET}"
echo "${COLOR_CYAN}${BOLD}└──────────────────────────────────────────────────────────────┘${COLOR_RESET}"
echo

# User Inputs with Validation
while true; do
    read -p "${COLOR_YELLOW}${BOLD}Enter Cloud Storage Function Name: ${COLOR_RESET}" STORAGE_FUNCTION
    if validate_function_name "$STORAGE_FUNCTION"; then
        break
    fi
done
echo

while true; do
    read -p "${COLOR_YELLOW}${BOLD}Enter HTTP Function Name: ${COLOR_RESET}" HTTP_FUNCTION
    if validate_function_name "$HTTP_FUNCTION"; then
        break
    fi
done
echo

while true; do
    read -p "${COLOR_YELLOW}${BOLD}Enter Region: ${COLOR_RESET}" REGION
    if validate_region "$REGION"; then
        break
    fi
done
echo

while true; do
    read -p "${COLOR_YELLOW}${BOLD}Enter Bucket Name (from task 1): ${COLOR_RESET}" BUCKET_NAME
    if validate_bucket "$BUCKET_NAME"; then
        break
    fi
done
echo

# Export Variables
export STORAGE_FUNCTION=$STORAGE_FUNCTION
export HTTP_FUNCTION=$HTTP_FUNCTION
export REGION=$REGION
export BUCKET_NAME=$BUCKET_NAME

# Cleanup function
cleanup() {
    echo "${COLOR_YELLOW}${BOLD}🧹 Cleaning up temporary files...${COLOR_RESET}"
    if [ -d ~/$STORAGE_FUNCTION ]; then
        rm -rf ~/$STORAGE_FUNCTION
    fi
    if [ -d ~/$HTTP_FUNCTION ]; then
        rm -rf ~/$HTTP_FUNCTION
    fi
}
trap cleanup EXIT

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
SERVICE_ACCOUNT="${PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

echo "${COLOR_BLUE}${BOLD}⏳ Configuring IAM permissions...${COLOR_RESET}"

# Add necessary IAM bindings
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT \
  --role roles/pubsub.publisher

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT \
  --role roles/storage.objectAdmin

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member serviceAccount:$SERVICE_ACCOUNT \
  --role roles/eventarc.eventReceiver

echo "${COLOR_GREEN}${BOLD}✅ IAM permissions configured!${COLOR_RESET}"
echo

# Check if bucket exists, if not create it
echo "${COLOR_BLUE}${BOLD}⏳ Checking storage bucket...${COLOR_RESET}"
if gsutil ls gs://$BUCKET_NAME &> /dev/null; then
    echo "${COLOR_GREEN}${BOLD}✅ Bucket $BUCKET_NAME already exists!${COLOR_RESET}"
else
    echo "${COLOR_YELLOW}${BOLD}⚠️  Bucket $BUCKET_NAME not found. Creating...${COLOR_RESET}"
    gsutil mb -l $REGION gs://$BUCKET_NAME
    echo "${COLOR_GREEN}${BOLD}✅ Storage bucket created successfully!${COLOR_RESET}"
fi
echo

# Create Cloud Storage Event Function
echo "${COLOR_BLUE}${BOLD}🛠️  Building Cloud Storage Event Function...${COLOR_RESET}"
echo

mkdir -p ~/$STORAGE_FUNCTION && cd $_
touch index.js && touch package.json

# Create index.js with exact code from task
cat > index.js <<EOF
const functions = require('@google-cloud/functions-framework');

functions.cloudEvent('$STORAGE_FUNCTION', (cloudevent) => {
  console.log('A new event in your Cloud Storage bucket has been logged!');
  console.log(cloudevent);
});
EOF

# Create package.json with exact code from task
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

echo "${COLOR_GREEN}${BOLD}✅ Storage function files created!${COLOR_RESET}"
echo

deploy_storage_function() {
  echo "${COLOR_BLUE}${BOLD}🚀 Deploying Cloud Storage Function...${COLOR_RESET}"
  gcloud functions deploy $STORAGE_FUNCTION \
  --gen2 \
  --runtime nodejs24 \
  --entry-point $STORAGE_FUNCTION \
  --source . \
  --region $REGION \
  --trigger-bucket gs://$BUCKET_NAME \
  --trigger-location $REGION \
  --max-instances 2 \
  --quiet
}

# Deploy Storage Function with retry
echo "${COLOR_BLUE}${BOLD}⏳ Deploying Storage Function (may take a few minutes)...${COLOR_RESET}"
echo

MAX_RETRIES=5
RETRY_COUNT=0
DEPLOYED=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$DEPLOYED" = false ]; do
    if deploy_storage_function; then
        echo "${COLOR_GREEN}${BOLD}✅ Cloud Storage Function deployed successfully!${COLOR_RESET}"
        DEPLOYED=true
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "${COLOR_YELLOW}${BOLD}⚠️  Deployment failed. Waiting 30 seconds before retry $RETRY_COUNT of $MAX_RETRIES...${COLOR_RESET}"
            sleep 30
        else
            echo "${COLOR_RED}${BOLD}❌ Failed to deploy after $MAX_RETRIES attempts.${COLOR_RESET}"
            echo "${COLOR_YELLOW}${BOLD}💡 Note: It may take a few minutes for APIs to be fully enabled.${COLOR_RESET}"
            echo "${COLOR_YELLOW}${BOLD}   Try running the script again after 2-3 minutes.${COLOR_RESET}"
            exit 1
        fi
    fi
done

cd ..

# Create HTTP Function
echo
echo "${COLOR_BLUE}${BOLD}🛠️  Building HTTP Trigger Function...${COLOR_RESET}"
echo

mkdir -p ~/$HTTP_FUNCTION && cd $_
touch index.js && touch package.json

# Create index.js with exact code from task
cat > index.js <<EOF
const functions = require('@google-cloud/functions-framework');

functions.http('$HTTP_FUNCTION', (req, res) => {
  res.status(200).send('HTTP function (2nd gen) has been called!');
});
EOF

# Create package.json with exact code from task
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

echo "${COLOR_GREEN}${BOLD}✅ HTTP function files created!${COLOR_RESET}"
echo

deploy_http_function() {
  echo "${COLOR_BLUE}${BOLD}🚀 Deploying HTTP Function...${COLOR_RESET}"
  gcloud functions deploy $HTTP_FUNCTION \
  --gen2 \
  --runtime nodejs24 \
  --entry-point $HTTP_FUNCTION \
  --source . \
  --region $REGION \
  --trigger-http \
  --allow-unauthenticated \
  --min-instances 1 \
  --max-instances 2 \
  --quiet
}

# Deploy HTTP Function
echo "${COLOR_BLUE}${BOLD}⏳ Deploying HTTP Function...${COLOR_RESET}"
echo

RETRY_COUNT=0
DEPLOYED=false

while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$DEPLOYED" = false ]; do
    if deploy_http_function; then
        echo "${COLOR_GREEN}${BOLD}✅ HTTP Function deployed successfully!${COLOR_RESET}"
        DEPLOYED=true
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "${COLOR_YELLOW}${BOLD}⚠️  Deployment failed. Waiting 30 seconds before retry $RETRY_COUNT of $MAX_RETRIES...${COLOR_RESET}"
            sleep 30
        else
            echo "${COLOR_RED}${BOLD}❌ Failed to deploy after $MAX_RETRIES attempts.${COLOR_RESET}"
            exit 1
        fi
    fi
done

# Get HTTP Function URL
HTTP_URL=$(gcloud functions describe $HTTP_FUNCTION --region $REGION --format='value(serviceConfig.uri)')

cd ..

# Completion Message
echo
echo "${COLOR_GREEN}${BOLD}┌──────────────────────────────────────────────────────────────┐${COLOR_RESET}"
echo "${COLOR_GREEN}${BOLD}│          Lab Completed Successfully!                        │${COLOR_RESET}"
echo "${COLOR_GREEN}${BOLD}└──────────────────────────────────────────────────────────────┘${COLOR_RESET}"
echo
echo "${COLOR_MAGENTA}${BOLD}📋 Deployment Details:${COLOR_RESET}"
echo "${COLOR_CYAN}Project ID: ${DEVSHELL_PROJECT_ID}${COLOR_RESET}"
echo "${COLOR_CYAN}Region: ${REGION}${COLOR_RESET}"
echo "${COLOR_CYAN}Bucket: gs://${BUCKET_NAME}${COLOR_RESET}"
echo "${COLOR_CYAN}Storage Function: ${STORAGE_FUNCTION}${COLOR_RESET}"
echo "${COLOR_CYAN}HTTP Function: ${HTTP_FUNCTION}${COLOR_RESET}"
if [ ! -z "$HTTP_URL" ]; then
    echo "${COLOR_CYAN}HTTP Function URL: ${HTTP_URL}${COLOR_RESET}"
fi
echo
echo "${COLOR_MAGENTA}${BOLD}💡 Test your HTTP Function:${COLOR_RESET}"
echo "${COLOR_CYAN}curl ${HTTP_URL}${COLOR_RESET}"
echo
echo "${COLOR_MAGENTA}${BOLD}💡 Test your Storage Trigger:${COLOR_RESET}"
echo "${COLOR_CYAN}echo \"Hello World\" > test.txt && gsutil cp test.txt gs://${BUCKET_NAME}/${COLOR_RESET}"
echo "${COLOR_CYAN}Then check logs: gcloud functions logs read ${STORAGE_FUNCTION} --region ${REGION}${COLOR_RESET}"
echo
echo "${COLOR_MAGENTA}${BOLD}📊 Check function status:${COLOR_RESET}"
echo "${COLOR_CYAN}gcloud functions describe ${STORAGE_FUNCTION} --region ${REGION}${COLOR_RESET}"
echo "${COLOR_CYAN}gcloud functions describe ${HTTP_FUNCTION} --region ${REGION}${COLOR_RESET}"
echo
echo "${COLOR_MAGENTA}${BOLD}For more cloud tutorials, subscribe:${COLOR_RESET}"
echo "${COLOR_CYAN}${BOLD}https://www.youtube.com/@drabhishek.5460/videos${COLOR_RESET}"
echo "${COLOR_MAGENTA}${BOLD}Dr. Abhishek - Cloud Computing Expert${COLOR_RESET}"
echo
