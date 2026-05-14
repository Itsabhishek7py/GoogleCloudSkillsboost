#!/bin/bash

# Define color variables
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# Welcome Banner
echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}         Welcome To Dr Abhishek Cloud Tutorials       ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}Let's deploys a Node.js Cloud Function with HTTP trigger${RESET_FORMAT}"
echo "${WHITE_TEXT}using Google Cloud Functions (2nd gen)${RESET_FORMAT}"
echo

# Get project information
echo "${YELLOW_TEXT}${BOLD_TEXT}🔍 Retrieving your Google Cloud Project ID...${RESET_FORMAT}"
export PROJECT_ID=$(gcloud config get-value project 2>/dev/null)

if [ -z "$PROJECT_ID" ]; then
    echo "${RED_TEXT}✗ Failed to get Project ID. Please ensure:"
    echo "1. You are authenticated (gcloud auth login)"
    echo "2. You have set a default project (gcloud config set project PROJECT_ID)${RESET_FORMAT}"
    exit 1
fi
echo "${GREEN_TEXT}✓ Project ID: ${BOLD_TEXT}${PROJECT_ID}${RESET_FORMAT}"
echo

# Get user input with validation
while true; do
    read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the region (e.g., us-central1): ${RESET_FORMAT}" REGION
    if [[ $REGION =~ ^[a-z]+-[a-z]+[0-9]+$ ]]; then
        break
    else
        echo "${RED_TEXT}Invalid region format. Example: us-central1${RESET_FORMAT}"
    fi
done

while true; do
    read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the Cloud Function name: ${RESET_FORMAT}" FUNCTION_NAME
    if [[ $FUNCTION_NAME =~ ^[a-z]([-a-z0-9]*[a-z0-9])?$ ]]; then
        break
    else
        echo "${RED_TEXT}Invalid function name. Must start with a letter and contain only lowercase letters, numbers, and hyphens.${RESET_FORMAT}"
    fi
done

# Create source files
echo
echo "${BLUE_TEXT}${BOLD_TEXT}📦 Creating sample Node.js function files...${RESET_FORMAT}"
mkdir -p cloud-function || {
    echo "${RED_TEXT}Failed to create directory. Check permissions.${RESET_FORMAT}"
    exit 1
}

cat > cloud-function/index.js <<'EOF'
exports.helloWorld = (req, res) => {
    const message = `Hello from ${process.env.FUNCTION_NAME} (v2)!\n` +
                   `Project: ${process.env.GCP_PROJECT}\n` +
                   `Region: ${process.env.FUNCTION_REGION}`;
    res.status(200).send(message);
};
EOF

cat > cloud-function/package.json <<'EOF'
{
  "name": "cloud-function",
  "version": "1.0.0",
  "main": "index.js",
  "engines": {
    "node": ">=20.0.0"
  }
}
EOF

echo "${GREEN_TEXT}✓ Created source files in 'cloud-function' directory${RESET_FORMAT}"
echo

# Deploy function
echo "${MAGENTA_TEXT}${BOLD_TEXT}🚀 Deploying Cloud Function (Gen2)...${RESET_FORMAT}"
if gcloud functions deploy ${FUNCTION_NAME} \
    --gen2 \
    --runtime=nodejs20 \
    --region=${REGION} \
    --source=cloud-function \
    --entry-point=helloWorld \
    --trigger-http \
    --max-instances=5 \
    --allow-unauthenticated 2>&1 | tee /tmp/function-deploy.log; then
    
    echo "${GREEN_TEXT}✓ Successfully deployed function '${FUNCTION_NAME}'${RESET_FORMAT}"
    echo
    echo "${BLUE_TEXT}${BOLD_TEXT}Function URL:${RESET_FORMAT}"
    gcloud functions describe ${FUNCTION_NAME} --region ${REGION} --gen2 --format="value(serviceConfig.uri)"
else
    echo "${RED_TEXT}✗ Deployment failed. Error details:${RESET_FORMAT}"
    cat /tmp/function-deploy.log
    echo
    echo "${YELLOW_TEXT}Troubleshooting tips:"
    echo "1. Ensure Cloud Functions API is enabled"
    echo "2. Check your project quota"
    echo "3. Verify you have Editor or Owner permissions${RESET_FORMAT}"
    rm /tmp/function-deploy.log
    exit 1
fi
rm /tmp/function-deploy.log

# Completion message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}          DEPLOYMENT COMPLETED SUCCESSFULLY        ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Next steps:${RESET_FORMAT}"
echo "1. Test your function: curl $(gcloud functions describe ${FUNCTION_NAME} --region ${REGION} --gen2 --format="value(serviceConfig.uri)")"
echo "2. View logs: gcloud functions logs read ${FUNCTION_NAME} --region ${REGION} --gen2"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}For more cloud tutorials:${RESET_FORMAT}"
echo "${BLUE_TEXT}${UNDERLINE_TEXT}Subscribe to Dr. Abhishek's YouTube Channel${RESET_FORMAT}"
echo "${BLUE_TEXT}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
