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
gcloud services enable apikeys.googleapis.com
gcloud alpha services api-keys create \
  --display-name="speech-to-text-key"
export API_KEY=$(gcloud alpha services api-keys get-key-string \
  $(gcloud alpha services api-keys list \
      --filter="displayName=speech-to-text-key" \
      --format="value(name)") \
  --format="value(keyString)")
  
cat << 'EOF'

###################################################################
## Task 2. Create your Speech-to-Text API request
###################################################################

EOF
# Create request.json file
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
echo 
echo "👉 Check request.json:"
cat request.json

cat << 'EOF'

###################################################################
## Task 3. Call the Speech-to-Text API
###################################################################

EOF
# Make the API call and display response
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
  "https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json
echo 
echo "👉 Check result.json:"
cat result.json
