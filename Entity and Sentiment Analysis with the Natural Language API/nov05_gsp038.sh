#!/bin/bash
## Created by nov05, 2026-05-11 

# Modern Color Definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

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

###################################################################
## Task 1. Create an API key
###################################################################

gcloud services enable apikeys.googleapis.com
gcloud alpha services api-keys create \
  --display-name="nlp-analysis-key"
export KEY_STRING=$(gcloud alpha services api-keys list \
  --format="value(name)" \
  --filter="displayName=nlp-analysis-key")
export API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_STRING \
  --format="value(keyString)")

###################################################################
## Task 2. Make an entity analysis request
###################################################################
###################################################################
## Task 3. Call the Natural Language API
###################################################################
###################################################################
## Task 4. Sentiment analysis with the Natural Language API
###################################################################
###################################################################
## Task 5. Analyzing entity sentiment
###################################################################
###################################################################
## Task 6. Analyzing syntax and parts of speech
###################################################################
## Task 7. Multilingual natural language processing
###################################################################


## Prepare Analysis Script
cat > nlp_analysis.sh <<'EOL'
#!/bin/bash

## Retrieve API Key
KEY_STRING=$(gcloud alpha services api-keys list \
  --format="value(name)" \
  --filter="displayName=nlp-analysis-key")
API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_STRING \
  --format="value(keyString)")
echo -e "🔹  API Key: $API_KEY"

## Create NLP Request
cat > request.json <<EOF
{
  "document":{
    "type":"PLAIN_TEXT",
    "content":"Joanne Rowling, who writes under the pen names J. K. Rowling and Robert Galbraith, is a British novelist and screenwriter who wrote the Harry Potter fantasy series."
  },
  "encodingType":"UTF8"
}
EOF
echo -e "🔹  Sample text prepared for analysis"

## Make API Request
echo -e "🔹  Analyzing text with NLP API..."
curl "https://language.googleapis.com/v1/documents:analyzeEntities?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @request.json > result.json

## Display result
echo -e "👉  Analysis result:"
cat result.json
EOL

# Copy the script into /tmp dir
gcloud compute scp nlp_analysis.sh linux-instance:/tmp \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet

# Run the cript
gcloud compute ssh linux-instance \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet \
  --command="chmod +x /tmp/nlp_analysis.sh && /tmp/nlp_analysis.sh"

