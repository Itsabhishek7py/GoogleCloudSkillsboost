#!/bin/bash

# Color Definitions

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

echo
echo "${CYAN_TEXT}${BOLD_TEXT}=================================================${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}        Welcome to Dr Abhishek Cloud Tutorials        ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}=================================================${RESET_FORMAT}"
echo

# Region Input

echo -n "${GREEN_TEXT}${BOLD_TEXT}✏️ Enter App Engine Region (example: us-central1): ${RESET_FORMAT}"
read REGION
export REGION
echo

echo "${BLUE_TEXT}${BOLD_TEXT}📦 Step 1: Copying sample project from Cloud Storage...${RESET_FORMAT}"
gsutil -m cp -r gs://spls/gsp067/python-docs-samples .
echo "${GREEN_TEXT}✓ Files downloaded${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}📂 Step 2: Moving to project directory...${RESET_FORMAT}"
cd python-docs-samples/appengine/standard_python3/hello_world
echo "${GREEN_TEXT}✓ Directory ready${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}⚙️ Step 3: Updating Python version...${RESET_FORMAT}"
sed -i "s/python37/python313/g" app.yaml
echo "${GREEN_TEXT}✓ Python version updated${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}📝 Step 4: Updating requirements.txt...${RESET_FORMAT}"

cat > requirements.txt <<EOF
Flask==1.1.2
itsdangerous==2.0.1
Jinja2==3.0.3
werkzeug==2.0.1
EOF

echo "${GREEN_TEXT}✓ requirements.txt updated${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}🐍 Step 5: Installing Python virtual environment...${RESET_FORMAT}"

sudo apt update -y
sudo apt install python3-venv -y

python3 -m venv myvenv
source myvenv/bin/activate

echo "${GREEN_TEXT}✓ Virtual environment created${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}📦 Step 6: Installing dependencies...${RESET_FORMAT}"
pip install -r requirements.txt
echo "${GREEN_TEXT}✓ Dependencies installed${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}☁️ Step 7: Creating App Engine application...${RESET_FORMAT}"
gcloud app create --region=$REGION
echo "${GREEN_TEXT}✓ App Engine created${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}🚀 Step 8: Deploying application...${RESET_FORMAT}"
yes | gcloud app deploy
echo "${GREEN_TEXT}✓ Deployment successful${RESET_FORMAT}"
echo

echo "${CYAN_TEXT}${BOLD_TEXT}=================================================${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}             🎉 LAB COMPLETED SUCCESSFULLY 🎉            ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}=================================================${RESET_FORMAT}"
echo

echo "${RED_TEXT}${BOLD_TEXT}📺 Learn more Cloud Labs at Dr Abhishek Channel:${RESET_FORMAT}"
echo "${BLUE_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460/${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👍 Like • Share • Subscribe for more tutorials${RESET_FORMAT}"
echo
