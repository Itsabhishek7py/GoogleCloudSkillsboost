#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    echo -ne "${CYAN}Loading${NC} "
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    echo -ne "\b\b\b\b\b\b"
    echo -e "${GREEN}Done!${NC}"
    echo
}

echo
echo -e "${YELLOW}--------------------------------------------------------"
echo -e "${GREEN}🎓  Welcome to Dr Abhishek's Cloud Tutorials! ☁️"
echo -e "${CYAN}Subscribe to the channel: https://www.youtube.com/@drabhishek.5460/videos"
echo -e "${YELLOW}--------------------------------------------------------${NC}"

(sleep 3) & spinner

#######################################################
## Task 1. Initialize your lab
#######################################################

## Get project id, project number, region
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
export REGION=$(gcloud compute project-info describe \
    --format="value(commonInstanceMetadata.items[google-compute-default-region])")
gcloud config set compute/region $REGION
echo "Project ID: $PROJECT_ID"
echo "Project number: $PROJECT_NUMBER"
echo "Region: $REGION"
echo

gcloud services enable container.googleapis.com \
    cloudbuild.googleapis.com \
    secretmanager.googleapis.com \
    containeranalysis.googleapis.com

gcloud artifacts repositories create my-repository \
  --repository-format=docker \
  --location=$REGION

gcloud container clusters create hello-cloudbuild --num-nodes 1 --region $REGION

curl -sS https://webi.sh/gh | sh 
gh auth login 
gh api user -q ".login"
GITHUB_USERNAME=$(gh api user -q ".login")
git config --global user.name "${GITHUB_USERNAME}"
# git config --global user.email "you@example.com" 
git config --global user.email "${USER_EMAIL}"  # e.g. student-03-758816dbe52c@qwiklabs.net
echo "GitHub username: $GITHUB_USERNAME"
echo "User email: $USER_EMAIL"


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
## Task 3
#######################################################

cd ~/hello-cloudbuild-app
COMMIT_ID="$(git rev-parse --short=7 HEAD)"
gcloud builds submit --tag="${REGION}-docker.pkg.dev/${PROJECT_ID}/my-repository/hello-cloudbuild:${COMMIT_ID}" .

#######################################################
## Task 4 Create the Continuous Integration (CI) pipeline
#######################################################

# -----------------------------
# CI Trigger (app repo)
# -----------------------------
echo "👉  Creating CI trigger..."
gcloud builds triggers create github \
  --name="hello-cloudbuild" \
  --repo-name="hello-cloudbuild-app" \
  --repo-owner="$GITHUB_USERNAME" \
  --branch-pattern=".*" \
  --build-config="cloudbuild.yaml" \
  --included-files="**" \
  --region="$REGION"
gcloud builds triggers list --region=$REGION 

cd ~/hello-cloudbuild-app
git add .
git commit -m "Type Any Commit Message here"
git push google master

#######################################################
## Task 5 Accessing GitHub from a build via SSH keys
#######################################################

cd ~
mkdir workingdir
cd workingdir

## Create a new GitHub SSH key
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
git add . && git commit -m "initial commit"
git push google master

git checkout -b production
rm cloudbuild.yaml

curl -LO raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/refs/heads/main/Google%20Kubernetes%20Engine%20Pipeline%20using%20Cloud%20Build/env-cloudbuild.yaml
mv env-cloudbuild.yaml cloudbuild.yaml

sed -i "s/REGION-/$REGION/g" cloudbuild.yaml
sed -i "s/GITHUB-USERNAME/${GITHUB_USERNAME}/g" cloudbuild.yaml

git add .
git commit -m "Create cloudbuild.yaml for deployment"
git checkout -b candidate
git push google production
git push google candidate

# -----------------------------
# CD Trigger (env repo)
# -----------------------------
echo "👉  Creating CD trigger..."
gcloud builds triggers create github \
  --name="hello-cloudbuild-deploy" \
  --repo-name="hello-cloudbuild-env" \
  --repo-owner="$GITHUB_USERNAME" \
  --branch-pattern="^candidate$" \
  --build-config="cloudbuild.yaml" \
  --included-files="**" \
  --region="$REGION"
gcloud builds triggers list --region=$REGION 

cd ~/hello-cloudbuild-app
ssh-keyscan -t rsa github.com > known_hosts.github
chmod +x known_hosts.github
git add .
git commit -m "Adding known_host file."
git push google master

rm cloudbuild.yaml

curl -LO raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/refs/heads/main/Google%20Kubernetes%20Engine%20Pipeline%20using%20Cloud%20Build/app-cloudbuild.yaml
mv app-cloudbuild.yaml cloudbuild.yaml

sed -i "s/REGION/$REGION/g" cloudbuild.yaml
sed -i "s/GITHUB-USERNAME/${GITHUB_USERNAME}/g" cloudbuild.yaml

git add cloudbuild.yaml
git commit -m "Trigger CD pipeline"
git push google master
# --- End Original Script ---

# Final Message
echo -e "${GREEN}✅  Lab is now Completed!"
echo -e "${CYAN}🙏  Thanks for using Dr Abhishek's Cloud Tutorials!"
echo -e "${YELLOW}👉  Subscribe here: ${NC}https://www.youtube.com/@drabhishek.5460/videos"
