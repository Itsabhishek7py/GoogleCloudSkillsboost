#!/bin/bash
## Created by nov05, 2026-05-11  

## Get project id, project number, region, zone
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID \
  --format='value(projectNumber)')
export REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
gcloud config set compute/region $REGION
echo
echo "🔹  Project ID: $PROJECT_ID"
echo "🔹  Project number: $PROJECT_NUMBER"
echo "🔹  Region: $REGION"
echo "🔹  Zone: $ZONE"
echo

#######################################################
## Task 1. Create an API key
#######################################################

export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value core/project)

gcloud iam service-accounts create my-natlang-sa \
  --display-name "my natural language service account"

## ⚠️ Even though the service account was created, IAM sometimes has a short propagation delay 
##   before it becomes visible for key creation in tightly controlled lab environments (like Qwiklabs).
SA="my-natlang-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"
echo "🔹  Waiting for service account to be ready..."
until gcloud iam service-accounts describe "$SA" >/dev/null 2>&1
do
  echo "🔹  Service account is not ready yet... retrying in 5s"
  sleep 5
done
echo "🔹  Service account $SA is ready!"

gcloud iam service-accounts keys create ~/key.json \
  --iam-account="$SA"  

export GOOGLE_APPLICATION_CREDENTIALS="$HOME/key.json"

#######################################################
## Task 2. Make an entity analysis request
#######################################################

REMOTE_CMD=$(cat <<'EOF'
gcloud ml language analyze-entities \
  --content='Michelangelo Caravaggio, Italian painter, is known for "The Calling of Saint Matthew".' \
  > result.json
EOF
)
gcloud compute ssh \
  --zone "$ZONE" "linux-instance" \
  --project "$DEVSHELL_PROJECT_ID" \
  --quiet \
  --command "$REMOTE_CMD"

echo "✅  ALL DONE"

## Pretty print JSON
gcloud compute ssh \
  --zone "$ZONE" "linux-instance" \
  --project "$DEVSHELL_PROJECT_ID" \
  --quiet \
  --command "jq . result.json"
