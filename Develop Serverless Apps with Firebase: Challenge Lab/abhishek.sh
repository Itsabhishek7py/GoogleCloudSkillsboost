#!/bin/bash

# =========================
# COLORS
# =========================
GREEN=$'\033[0;92m'
YELLOW=$'\033[0;93m'
BLUE=$'\033[0;94m'
CYAN=$'\033[0;96m'
RESET=$'\033[0m'
BOLD=$'\033[1m'

# =========================
# SPINNER
# =========================
spinner() {
  local pid=$!
  local spin='-\|/'
  local i=0
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\r${YELLOW}${spin:$i:1} Processing...${RESET}"
    sleep .2
  done
  printf "\r${GREEN}✔ Done!${RESET}\n"
}

run_cmd() {
  "$@" & spinner
}

clear
echo "${CYAN}${BOLD}🚀 ye hai jaaadu ha 🚀${RESET}"
sleep 2

# =========================
# PROJECT SET
# =========================
echo "${BLUE}Setting project...${RESET}"
run_cmd gcloud config set project $(gcloud projects list --format='value(PROJECT_ID)' --filter='qwiklabs-gcp')

# =========================
# DYNAMIC REGION
# =========================
echo "${BLUE}Detecting region...${RESET}"

REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])" 2>/dev/null)

# fallback
if [[ -z "$REGION" ]]; then
  REGION=$(gcloud config get-value compute/region 2>/dev/null)
fi

# final fallback
if [[ -z "$REGION" ]]; then
  REGION="us-central1"
fi

export REGION
echo "${GREEN}✔ Using REGION: $REGION${RESET}"

# =========================
# VARIABLES
# =========================
export DATASET_SERVICE=netflix-dataset-service
export FRONTEND_STAGING_SERVICE=frontend-staging-service
export FRONTEND_PRODUCTION_SERVICE=frontend-production-service

# =========================
# ENABLE SERVICES
# =========================
echo "${BLUE}Enabling services...${RESET}"
run_cmd gcloud services enable run.googleapis.com firestore.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com

# =========================
# FIRESTORE
# =========================
echo "${BLUE}Creating Firestore...${RESET}"
run_cmd gcloud firestore databases create --location=$REGION || true
sleep 10

# =========================
# ARTIFACT REGISTRY
# =========================
echo "${BLUE}Creating Artifact Registry...${RESET}"
run_cmd gcloud artifacts repositories create rest-api-repo \
--repository-format=docker \
--location=$REGION || true

# =========================
# CLONE REPO
# =========================
echo "${BLUE}Cloning repo...${RESET}"
run_cmd git clone https://github.com/rosera/pet-theory.git

# =========================
# IMPORT DATA
# =========================
cd pet-theory/lab06/firebase-import-csv/solution
run_cmd npm install
run_cmd node index.js netflix_titles_original.csv

# =========================
# REST API v0.1
# =========================
cd ~/pet-theory/lab06/firebase-rest-api/solution-01
run_cmd npm install

IMAGE1=$REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/rest-api-repo/rest-api:0.1

echo "${BLUE}Building REST API v0.1...${RESET}"
run_cmd gcloud builds submit --tag $IMAGE1 .

echo "${BLUE}Deploying REST API v0.1...${RESET}"
run_cmd gcloud run deploy $DATASET_SERVICE \
--image $IMAGE1 \
--region=$REGION \
--allow-unauthenticated \
--max-instances=1

# =========================
# REST API v0.2
# =========================
cd ~/pet-theory/lab06/firebase-rest-api/solution-02
run_cmd npm install

IMAGE2=$REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/rest-api-repo/rest-api:0.2

echo "${BLUE}Building REST API v0.2...${RESET}"
run_cmd gcloud builds submit --tag $IMAGE2 .

echo "${BLUE}Deploying REST API v0.2...${RESET}"
run_cmd gcloud run deploy $DATASET_SERVICE \
--image $IMAGE2 \
--region=$REGION \
--allow-unauthenticated \
--max-instances=1

# =========================
# GET SERVICE URL
# =========================
SERVICE_URL=$(gcloud run services describe $DATASET_SERVICE \
--region=$REGION \
--format='value(status.url)')

echo "${CYAN}SERVICE_URL: $SERVICE_URL${RESET}"

# =========================
# FRONTEND STAGING
# =========================
cd ~/pet-theory/lab06/firebase-frontend

IMAGE3=$REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/rest-api-repo/frontend-staging:0.1

echo "${BLUE}Building Staging...${RESET}"
run_cmd gcloud builds submit --tag $IMAGE3 .

echo "${BLUE}Deploying Staging...${RESET}"
run_cmd gcloud run deploy $FRONTEND_STAGING_SERVICE \
--image $IMAGE3 \
--region=$REGION \
--allow-unauthenticated \
--max-instances=1

# =========================
# FRONTEND PRODUCTION
# =========================
cd ~/pet-theory/lab06/firebase-frontend/public

echo "${BLUE}Updating frontend for production...${RESET}"
sed -i "s|const API_URL = .*|const API_URL = '$SERVICE_URL';|" app.js
sed -i "s|fetch(API_URL)|fetch(\`\${API_URL}/\${year}\`)|g" app.js

# =========================
# BUILD PRODUCTION
# =========================
cd ~/pet-theory/lab06/firebase-frontend

IMAGE4=$REGION-docker.pkg.dev/$DEVSHELL_PROJECT_ID/rest-api-repo/frontend-production:0.1

echo "${BLUE}Building Production...${RESET}"
run_cmd gcloud builds submit --no-cache --tag $IMAGE4 .

echo "${BLUE}Deploying Production...${RESET}"
run_cmd gcloud run deploy $FRONTEND_PRODUCTION_SERVICE \
--image $IMAGE4 \
--region=$REGION \
--allow-unauthenticated \
--max-instances=1

# =========================
# DONE
# =========================
echo
echo "${GREEN}${BOLD}✅ ALL TASKS COMPLETED (5 & 6 PASS)${RESET}"

# =========================
# SUBSCRIBE CTA
# =========================
echo -e "\n${YELLOW}${BOLD}👉 Subscribe to Dr Abhishek for more lab solutions! 🚀${RESET}\n"
