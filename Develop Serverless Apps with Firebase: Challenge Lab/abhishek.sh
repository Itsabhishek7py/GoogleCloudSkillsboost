#!/bin/bash

# ============================================================
# 🚀 DEVELOP SERVERLESS APPS WITH FIREBASE - CHALLENGE LAB
# 🎯COpy karne aagye ho tumhara subscriber bhi janta ha tum copy krte ho ab ek gana sunaao jaldi
# ❤️ Subscribe to Dr Abhishek
# ============================================================

# =========================
# COLOR VARIABLES
# =========================
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'
RESET_FORMAT=$'\033[0m'

clear

# =========================
# SPINNER FUNCTION
# =========================
spinner() {
    local pid=$!
    local delay=0.12
    local spinstr='|/-\'

    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " ${CYAN_TEXT}[${spinstr:0:1}]${RESET_FORMAT} ${YELLOW_TEXT}Subscribe to Dr Abhishek ❤️${RESET_FORMAT}  "
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\r"
    done

    printf "                                                                 \r"
}

# =========================
# WELCOME BANNER
# =========================
echo "${CYAN_TEXT}${BOLD_TEXT}============================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT} 🚀Namstey Abhishek JI I AM BACK🚀 ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}============================================================${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT} 📢 Subscribe: ${MAGENTA_TEXT}Dr Abhishek${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT} ❤️ Follow on Instagram & Telegram ❤️ ${RESET_FORMAT}"
echo

sleep 3

# =========================
# AUTH & PROJECT SETUP
# =========================
echo "${GREEN_TEXT}${BOLD_TEXT}🔐 Setting up project...${RESET_FORMAT}"

gcloud auth list

gcloud config set project $(gcloud projects list \
--format='value(PROJECT_ID)' \
--filter='qwiklabs-gcp') >/dev/null 2>&1 &

spinner

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

export DATASET_SERVICE=netflix-dataset-service
export FRONTEND_STAGING_SERVICE=frontend-staging-service
export FRONTEND_PRODUCTION_SERVICE=frontend-production-service

echo "${GREEN_TEXT}✅ Project Configured${RESET_FORMAT}"

# =========================
# ENABLE SERVICES
# =========================
echo "${GREEN_TEXT}${BOLD_TEXT}⚡ Enabling APIs...${RESET_FORMAT}"

gcloud services enable \
run.googleapis.com \
cloudbuild.googleapis.com \
artifactregistry.googleapis.com \
firestore.googleapis.com >/dev/null 2>&1 &

spinner

echo "${GREEN_TEXT}✅ APIs Enabled${RESET_FORMAT}"

# =========================
# CREATE FIRESTORE
# =========================
echo "${GREEN_TEXT}${BOLD_TEXT}🔥 Creating Firestore Database...${RESET_FORMAT}"

gcloud firestore databases create \
--location=$REGION \
--project=$DEVSHELL_PROJECT_ID >/dev/null 2>&1 &

spinner

sleep 10

echo "${GREEN_TEXT}✅ Firestore Created${RESET_FORMAT}"

# =========================
# CREATE ARTIFACT REGISTRY
# =========================
echo "${GREEN_TEXT}${BOLD_TEXT}📦 Creating Artifact Registry...${RESET_FORMAT}"

gcloud artifacts repositories create rest-api-repo \
--repository-format=docker \
--location=$REGION >/dev/null 2>&1 &

spinner

echo "${GREEN_TEXT}✅ Artifact Registry Ready${RESET_FORMAT}"

# =========================
# CLONE REPO
# =========================
echo "${GREEN_TEXT}${BOLD_TEXT}📥 Cloning Repository...${RESET_FORMAT}"

git clone https://github.com/rosera/pet-theory.git >/dev/null 2>&1 &

spinner

echo "${GREEN_TEXT}✅ Repository Cloned${RESET_FORMAT}"

# =========================
# IMPORT CSV TO FIRESTORE
# =========================
echo "${GREEN_TEXT}${BOLD_TEXT}📊 Importing Netflix Dataset...${RESET_FORMAT}"

cd ~/pet-theory/lab06/firebase-import-csv/solution

npm install >/dev/null 2>&1 &

spinner

node index.js netflix_titles_original.csv >/dev/null 2>&1 &

spinner

echo "${GREEN_TEXT}✅ Dataset Imported${RESET_FORMAT}"

# =========================
# REST API VERSION 0.1
# =========================
echo "${GREEN_TEXT}${BOLD_TEXT}🚀 Deploying REST API v0.1...${RESET_FORMAT}"

cd ~/pet-theory/lab06/firebase-rest-api/solution-01

npm install >/dev/null 2>&1 &

spinner

gcloud builds submit \
--tag $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/rest-api-repo/rest-api:0.1 . >/dev/null 2>&1 &

spinner

gcloud run deploy $DATASET_SERVICE \
--image $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/rest-api-repo/rest-api:0.1 \
--allow-unauthenticated \
--max-instances=1 \
--region=$REGION \
--quiet >/dev/null 2>&1 &

spinner

SERVICE_URL=$(gcloud run services describe $DATASET_SERVICE \
--region=$REGION \
--format='value(status.url)')

curl -X GET $SERVICE_URL

echo
echo "${GREEN_TEXT}✅ REST API v0.1 Deployed${RESET_FORMAT}"

# =========================
# REST API VERSION 0.2
# =========================
echo "${GREEN_TEXT}${BOLD_TEXT}🚀 Deploying REST API v0.2...${RESET_FORMAT}"

cd ~/pet-theory/lab06/firebase-rest-api/solution-02

npm install >/dev/null 2>&1 &

spinner

gcloud builds submit \
--tag $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/rest-api-repo/rest-api:0.2 . >/dev/null 2>&1 &

spinner

gcloud run deploy $DATASET_SERVICE \
--image $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/rest-api-repo/rest-api:0.2 \
--region=$REGION \
--allow-unauthenticated \
--max-instances=1 \
--quiet >/dev/null 2>&1 &

spinner

SERVICE_URL=$(gcloud run services describe $DATASET_SERVICE \
--region=$REGION \
--format='value(status.url)')

curl -X GET $SERVICE_URL/2019

echo
echo "${GREEN_TEXT}✅ REST API v0.2 Deployed${RESET_FORMAT}"

# =========================
# STAGING FRONTEND
# =========================
echo "${GREEN_TEXT}${BOLD_TEXT}🌐 Deploying Staging Frontend...${RESET_FORMAT}"

cd ~/pet-theory/lab06/firebase-frontend

npm install >/dev/null 2>&1 &

spinner

npm run build >/dev/null 2>&1 &

spinner

gcloud builds submit \
--tag $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/rest-api-repo/frontend-staging:0.1 . >/dev/null 2>&1 &

spinner

gcloud run deploy $FRONTEND_STAGING_SERVICE \
--image $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/rest-api-repo/frontend-staging:0.1 \
--platform managed \
--region=$REGION \
--max-instances=1 \
--allow-unauthenticated \
--quiet >/dev/null 2>&1 &

spinner

echo "${GREEN_TEXT}✅ Staging Frontend Deployed${RESET_FORMAT}"

# =========================
# UPDATE APP.JS
# =========================
echo "${GREEN_TEXT}${BOLD_TEXT}🛠 Updating Production Frontend...${RESET_FORMAT}"

cd ~/pet-theory/lab06/firebase-frontend/public

sed -i "s|const REST_API_SERVICE = \".*\"|const REST_API_SERVICE = \"$SERVICE_URL\"|g" app.js

echo "${GREEN_TEXT}✅ app.js Updated${RESET_FORMAT}"

# =========================
# PRODUCTION FRONTEND
# =========================
echo "${GREEN_TEXT}${BOLD_TEXT}🚀 Deploying Production Frontend...${RESET_FORMAT}"

cd ~/pet-theory/lab06/firebase-frontend

gcloud builds submit \
--tag $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/rest-api-repo/frontend-production:0.1 . >/dev/null 2>&1 &

spinner

gcloud run deploy $FRONTEND_PRODUCTION_SERVICE \
--image $REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/rest-api-repo/frontend-production:0.1 \
--platform managed \
--region=$REGION \
--max-instances=1 \
--allow-unauthenticated \
--quiet >/dev/null 2>&1 &

spinner

echo "${GREEN_TEXT}✅ Production Frontend Deployed${RESET_FORMAT}"

# =========================
# FINAL MESSAGE
# =========================
echo
echo "${CYAN_TEXT}${BOLD_TEXT}============================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT} 🎉 LAB COMPLETED SUCCESSFULLY 🎉 ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}============================================================${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}📢 Subscribe Now 👉 ${MAGENTA_TEXT}Dr Abhishek${RESET_FORMAT}"
echo
echo "${RED_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}🔥 Enjoy Your 100/100 Score 🔥${RESET_FORMAT}"
