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
echo "🔹  User: $USER"
echo

cat << 'EOF'

###################################################################
## Task 1. Create an API key
###################################################################

EOF
gcloud services enable \
  speech.googleapis.com \
  apikeys.googleapis.com
  
gcloud alpha services api-keys create \
  --display-name="speech-to-text-key"
  
gcloud services api-keys update \
  $(gcloud services api-keys list \
      --filter="displayName=speech-to-text-key" \
      --format="value(name)" \
      --limit=1) \
  --location=global \
  --api-target=service=speech.googleapis.com
  
export API_KEY=$(gcloud alpha services api-keys get-key-string \
  $(gcloud alpha services api-keys list \
      --filter="displayName=speech-to-text-key" \
      --format="value(name)" \
      --limit=1) \
  --format="value(keyString)")
  
cat << 'EOF'

###################################################################
## Task 2. Create your Speech-to-Text API request
###################################################################

EOF
rm -f request.json
cat > request.json << 'EOL'
{
  "config": {
      "encoding":"FLAC",
      "languageCode": "en-US"
  },
  "audio": {
      "uri":"gs://cloud-samples-tests/speech/brooklyn.flac"
  }
}
EOL

cat << 'EOF'

###################################################################
## Task 3. Call the Speech-to-Text API
###################################################################

EOF
## Prepare script for the task
rm -f task.sh
cat > task.sh <<'EOF'
#!/bin/bash

## Retrieve API Key 
export API_KEY=$(gcloud alpha services api-keys get-key-string \
  $(gcloud alpha services api-keys list \
      --filter="displayName=nlp-analysis-key" \
      --format="value(name)" \
      --limit=1) \
  --format="value(keyString)")
# echo "$API_KEY" > ~/api_key.txt
# chmod 600 ~/api_key.txt

echo -e "\n👉  Check request.json:"
cat request.json

echo -e "\n👉  Check result.json:"
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
  "https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json
cat result.json

## Clean up. Keep request.json, result.json for the lab checks.
rm -f task.sh 
EOF

echo
echo "✅ All done"
