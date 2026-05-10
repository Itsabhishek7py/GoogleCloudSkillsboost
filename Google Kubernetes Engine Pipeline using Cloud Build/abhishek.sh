#!/bin/bash
## Changed by nov05, 2026-05-09  

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

## Changed by nov05, 2026-05-09
# spinner() {
#     local pid=$!
#     local delay=0.1
#     local spinstr='|/-\'
#     echo -ne "${CYAN}Loading${NC} "
#     while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
#         local temp=${spinstr#?}
#         printf " [%c]  " "$spinstr"
#         local spinstr=$temp${spinstr%"$temp"}
#         sleep $delay
#         printf "\b\b\b\b\b\b"
#     done
#     echo -ne "\b\b\b\b\b\b"
#     echo -e "${GREEN}       Done!        ${NC}"
#     echo
# }
spinner() {
    local pid=$!
    local spin='|/-\'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r${CYAN}Loading...${NC} [%c]   " "${spin:$i:1}"
        sleep 0.1
    done
    printf "\r${GREEN}Done!         ${NC}\n\n"  
}
(sleep 3) & spinner

#######################################################
## Task 1. Initialize your lab
#######################################################
## Objective: Enable services, create an artifact registry and the GKE cluster   

## Get project id, project number, region
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export REGION=$(gcloud compute project-info describe \
    --format="value(commonInstanceMetadata.items[google-compute-default-region])")
gcloud config set compute/region $REGION
echo "🔹  Project ID: $PROJECT_ID"
echo "🔹  Project number: $PROJECT_NUMBER"
echo "🔹  Region: $REGION"
echo

gcloud services enable container.googleapis.com \
    cloudbuild.googleapis.com \
    secretmanager.googleapis.com \
    containeranalysis.googleapis.com

gcloud artifacts repositories create my-repository \
  --repository-format=docker \
  --location=$REGION

gcloud container clusters create hello-cloudbuild --num-nodes 1 --region $REGION

#######################################################
## Task 2. Create the Git repositories in GitHub repositories
#######################################################

curl -sS https://webi.sh/gh | sh 
gh auth login 
gh api user -q ".login"
GITHUB_USERNAME=$(gh api user -q ".login")
git config --global user.name "${GITHUB_USERNAME}"
# git config --global user.email "you@example.com" 
git config --global user.email "${USER_EMAIL}"  # e.g. student-03-758816dbe52c@qwiklabs.net
echo "🔹  GitHub username: $GITHUB_USERNAME"
echo "🔹  User email: $USER_EMAIL"

## Create 2 GitHub repos as the lab requires
gh repo create hello-cloudbuild-app --private 
gh repo create hello-cloudbuild-env --private

cd ~
mkdir hello-cloudbuild-app
gcloud storage cp -r gs://spls/gsp1077/gke-gitops-tutorial-cloudbuild/* hello-cloudbuild-app
cd ~/hello-cloudbuild-app

sed -i "s/us-central1/$REGION/g" cloudbuild.yaml
sed -i "s/us-central1/$REGION/g" cloudbuild-delivery.yaml
sed -i "s/us-central1/$REGION/g" cloudbuild-trigger-cd.yaml
sed -i "s/us-central1/$REGION/g" kubernetes.yaml.tpl

git init
git config credential.helper gcloud.sh
git remote add google https://github.com/${GITHUB_USERNAME}/hello-cloudbuild-app
git branch -m master
git add . && git commit -m "initial commit"

#######################################################
## Task 3 Create a container image with Cloud Build
#######################################################

cd ~/hello-cloudbuild-app
COMMIT_ID="$(git rev-parse --short=7 HEAD)"
gcloud builds submit --tag="${REGION}-docker.pkg.dev/${PROJECT_ID}/my-repository/hello-cloudbuild:${COMMIT_ID}" .

#######################################################
## Task 4 Create the Continuous Integration (CI) pipeline
#######################################################
## Gen 1 GitHub App repository binding:
##   1. On GitHub: selecting repositories in GitHub App connection
##   2. On GCP: registering repos into “Cloud Build GitHub App” UI list

echo
echo "${BLUE_TEXT}${BOLD_TEXT}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}           NOW MANUAL STEPS                  ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Click the url to connect GitHub repos hello-cloudbuild-app and hello-cloudbuild-env:${RESET_FORMAT}"
echo "  Using region $REGION"
echo "  https://console.cloud.google.com/cloud-build/triggers?project=$PROJECT_ID"
echo

answer=""
echo "${YELLOW_TEXT}${BOLD_TEXT}Ready to proceed?${RESET_FORMAT}"
while true; do
  printf " (y/n): "
  read answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    break
  fi
  ## move cursor up one line and clear it
  echo -ne "\033[1A\033[2K"
done

# -----------------------------
# CI Trigger (app repo)
# -----------------------------
echo "👉  Creating CI trigger (1st-gen) hello-cloudbuild..."
## https://docs.cloud.google.com/sdk/gcloud/reference/builds/triggers/create/github
gcloud builds triggers create github \
    --name="hello-cloudbuild" \
    --service-account="projects/$PROJECT_ID/serviceAccounts/${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
    --repo-owner="$GITHUB_USERNAME" \
    --repo-name="hello-cloudbuild-app" \
    --branch-pattern=".*" \
    --build-config="cloudbuild.yaml" \
    --region="$REGION" \
    --description="GSP1077 Continuous integration (CI) pipeline"
gcloud builds triggers list --region=$REGION 

cd ~/hello-cloudbuild-app
git add .
git commit -m "Type Any Commit Message here"
git push google master

#######################################################
## Task 5 Accessing GitHub from a build via SSH keys
#######################################################
## In this step use the Secret Manager with Cloud Build to access private GitHub repositories.

cd ~
mkdir workingdir
cd workingdir

## Create a new GitHub SSH key
## This step creates two files, id_github and id_github.pub
ssh-keygen -t rsa -b 4096 -N '' -f id_github -C "${USER_EMAIL}"

gcloud secrets create ssh_key_secret --replication-policy="automatic"
gcloud secrets versions add ssh_key_secret --data-file=id_github

GITHUB_TOKEN=$(gh auth token)
SSH_KEY_CONTENT=$(cat ~/workingdir/id_github.pub)

gh api --method POST -H "Accept: application/vnd.github.v3+json" \
  /repos/${GITHUB_USERNAME}/hello-cloudbuild-env/keys \
  -f title="SSH_KEY" \
  -f key="$SSH_KEY_CONTENT" \
  -F read_only=false

rm id_github*

## Grant the service account permission to access Secret Manager
gcloud projects add-iam-policy-binding ${PROJECT_NUMBER} \
--member=serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com \
--role=roles/secretmanager.secretAccessor

#######################################################
## Task 6. Create the test environment and CD pipeline
#######################################################

## Grant Cloud Build access to GKE
cd ~
gcloud projects add-iam-policy-binding ${PROJECT_NUMBER} \
--member=serviceAccount:${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com \
--role=roles/container.developer

mkdir hello-cloudbuild-env
gcloud storage cp -r gs://spls/gsp1077/gke-gitops-tutorial-cloudbuild/* hello-cloudbuild-env

cd hello-cloudbuild-env
sed -i "s/us-central1/$REGION/g" cloudbuild.yaml
sed -i "s/us-central1/$REGION/g" cloudbuild-delivery.yaml
sed -i "s/us-central1/$REGION/g" cloudbuild-trigger-cd.yaml
sed -i "s/us-central1/$REGION/g" kubernetes.yaml.tpl

ssh-keyscan -t rsa github.com > known_hosts.github
chmod +x known_hosts.github

git init
git config credential.helper gcloud.sh
git remote add google https://github.com/${GITHUB_USERNAME}/hello-cloudbuild-env
git branch -m master
git add . && git commit -m "GSP1077 Initial commit"
git push google master

git checkout -b production
rm cloudbuild.yaml
curl -L \
  -o cloudbuild.yaml \
  https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/refs/heads/main/Google%20Kubernetes%20Engine%20Pipeline%20using%20Cloud%20Build/env-cloudbuild.yaml

sed -i "s/REGION-/$REGION/g" cloudbuild.yaml
sed -i "s/GITHUB-USERNAME/${GITHUB_USERNAME}/g" cloudbuild.yaml

git add .
git commit -m "GSP1077 Create cloudbuild.yaml for deployment"
git checkout -b candidate
git push google production
git push google candidate

# -----------------------------
# CD Trigger (env repo)
# -----------------------------
echo "👉  Creating CD trigger (1st-gen) hello-cloudbuild-deploy..."
gcloud builds triggers create github \
    --name="hello-cloudbuild-deploy" \
    --service-account="projects/$PROJECT_ID/serviceAccounts/${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
    --repo-owner="$GITHUB_USERNAME" \
    --repo-name="hello-cloudbuild-env" \
    --branch-pattern="^candidate$" \
    --build-config="cloudbuild.yaml" \
    --region="$REGION" \
    --description="GSP1077 Test environment and CD pipeline"
gcloud builds repositories list --region="$REGION"
gcloud builds triggers list --region=$REGION 

## Task 6.12 In your hello-cloudbuild-app directory, create a file named known_hosts.github, 
##   add the public SSH key to this file and provide the necessary permission to the file
cd ~/hello-cloudbuild-app
ssh-keyscan -t rsa github.com > known_hosts.github
chmod +x known_hosts.github
git add .
git commit -m "GSP1077 Adding known_host file"
git push google master

## Download and modify ./Google Kubernetes Engine Pipeline using Cloud Build/app-cloudbuild.yaml
rm cloudbuild.yaml
curl -L \
  -o cloudbuild.yaml \
  https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/refs/heads/main/Google%20Kubernetes%20Engine%20Pipeline%20using%20Cloud%20Build/app-cloudbuild.yaml
sed -i "s/REGION/$REGION/g" cloudbuild.yaml
sed -i "s/GITHUB-USERNAME/${GITHUB_USERNAME}/g" cloudbuild.yaml

git add cloudbuild.yaml
git commit -m "GSP1077 Trigger CD pipeline"
git push google master

#######################################################
## Task 7. Review Cloud Build pipeline
#######################################################

#######################################################
## Task 8. Test the complete pipeline
#######################################################

EXTERNAL_IP=""
while [ -z "$EXTERNAL_IP" ]; do
  EXTERNAL_IP=$(kubectl get service hello-cloudbuild \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
  if [ -z "$EXTERNAL_IP" ]; then
    echo "Waiting for service hello-cloudbuild external IP..."
    sleep 5
  fi
done

echo
echo "${BLUE_TEXT}${BOLD_TEXT}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}           NOW MANUAL STEPS                  ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${RESET_FORMAT}"
echo
echo "Click on the endpoint for the hello-cloudbuild service. You should see \"Hello World!\".
echo "  http://$EXTERNAL_IP"
echo

answer=""
echo "${YELLOW_TEXT}${BOLD_TEXT}Ready to proceed?${RESET_FORMAT}"
while true; do
  printf " (y/n): "
  read answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    break
  fi
  ## move cursor up one line and clear it
  echo -ne "\033[1A\033[2K"
done

echo "${YELLOW_TEXT}${BOLD_TEXT}👉  Task 8. Test the complete pipeline${RESET_FORMAT}"

## Task 8.3, Replace "Hello World" with "Hello Cloud Build", both in the application and in the unit test
cd ~/hello-cloudbuild-app
sed -i 's/Hello World/Hello Cloud Build/g' app.py
sed -i 's/Hello World/Hello Cloud Build/g' test_app.py

## Task 8.4, Commit and push the change to GitHub repositories
git add app.py test_app.py
git commit -m "GCP1077 Task 8.4, Hello Cloud Build"
git push google master

echo
echo "${BLUE_TEXT}${BOLD_TEXT}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}           NOW MANUAL STEPS                  ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${RESET_FORMAT}"
echo
echo "Waite a few minutes, reload the application in your browser. You should see \"Hello Cloud Build!\".
echo "  http://$EXTERNAL_IP"
echo

answer=""
echo "${YELLOW_TEXT}${BOLD_TEXT}Ready to proceed?${RESET_FORMAT}"
while true; do
  printf " (y/n): "
  read answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    break
  fi
  ## move cursor up one line and clear it
  echo -ne "\033[1A\033[2K"
done

#######################################################
## Task 9. Test the rollback
#######################################################

# --- End of script ---
