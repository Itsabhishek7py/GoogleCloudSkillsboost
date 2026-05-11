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
  --display-name="nlp-analysis-key"
# export KEY_STRING=$(gcloud alpha services api-keys list \
#   --format="value(name)" \
#   --filter="displayName=nlp-analysis-key")
# export API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_STRING \
#   --format="value(keyString)")

cat << 'EOF'

###################################################################
## Task 2. Make an entity analysis request
###################################################################

EOF

## Create NLP Request file
rm -f request.json
cat > request.json <<'EOF'
{
  "document":{
    "type":"PLAIN_TEXT",
    "content":"Joanne Rowling, who writes under the pen names J. K. Rowling and Robert Galbraith, is a British novelist and screenwriter who wrote the Harry Potter fantasy series."
  },
  "encodingType":"UTF8"
}
EOF

## Prepare script for the task
rm -f task.sh
cat > task.sh <<'EOF'
#!/bin/bash

## Retrieve and store API Key 
export API_KEY=$(gcloud alpha services api-keys get-key-string \
  $(gcloud alpha services api-keys list \
      --filter="displayName=nlp-analysis-key" \
      --format="value(name)") \
  --format="value(keyString)")
echo "$API_KEY" > ~/api_key.txt
chmod 600 ~/api_key.txt

echo -e "\n👉  Analysis request:"
cat request.json

###################################################################
## Task 3. Call the Natural Language API
###################################################################

echo -e "\n👉  Analysis result:"
curl "https://language.googleapis.com/v1/documents:analyzeEntities?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @request.json

## Clean up 
rm -f task.sh request.json
EOF

# Copy the script into $HOME dir
gcloud compute scp $SCRIPT_NAME task.sh request.json linux-instance:~ \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet
# Run the cript
gcloud compute ssh linux-instance \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet \
  --command="chmod +x task.sh && ./task.sh"

cat << 'EOF'

###################################################################
## Task 4. Sentiment analysis with the Natural Language API
###################################################################

EOF

rm -f request.json
cat > request.json <<'EOF'
{
  "document":{
    "type":"PLAIN_TEXT",
    "content":"Harry Potter is the best book. I think everyone should read it."
  },
  "encodingType": "UTF8"
}
EOF

rm -f task.sh
cat > task.sh <<'EOF'
#!/bin/bash
export API_KEY=$(< ~/api_key.txt)
echo -e "\n👉  Analysis request:"
cat request.json
echo -e "\n👉  Analysis result:"
curl "https://language.googleapis.com/v1/documents:analyzeSentiment?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @request.json
rm -f task.sh request.json
EOF

gcloud compute scp task.sh request.json linux-instance:~ \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet
gcloud compute ssh linux-instance \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet \
  --command="chmod +x task.sh && ./task.sh"

cat << 'EOF'

###################################################################
## Task 5. Analyzing entity sentiment
###################################################################

EOF

rm -f request.json
cat > request.json <<'EOF'
{
  "document":{
    "type":"PLAIN_TEXT",
    "content":"I liked the sushi but the service was terrible."
  },
  "encodingType": "UTF8"
}
EOF

rm -f task.sh
cat > task.sh <<'EOF'
#!/bin/bash
export API_KEY=$(< ~/api_key.txt)
echo -e "\n👉  Analysis request:"
cat request.json
echo -e "\n👉  Analysis result:"
curl "https://language.googleapis.com/v1/documents:analyzeEntitySentiment?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @request.json
cat result.json
rm -f task.sh request.json
EOF

gcloud compute scp task.sh request.json linux-instance:~ \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet
gcloud compute ssh linux-instance \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet \
  --command="chmod +x task.sh && ./task.sh"
  
cat << 'EOF'

###################################################################
## Task 6. Analyzing syntax and parts of speech
###################################################################

EOF

rm -f request.json
cat > request.json <<'EOF'
{
  "document":{
    "type":"PLAIN_TEXT",
    "content": "Joanne Rowling is a British novelist, screenwriter and film producer."
  },
  "encodingType": "UTF8"
}
EOF

rm -f task.sh
cat > task.sh <<'EOF'
#!/bin/bash
export API_KEY=$(< ~/api_key.txt)
echo -e "\n👉  Analysis request:"
cat request.json
echo -e "\n👉  Analysis result:"
curl "https://language.googleapis.com/v1/documents:analyzeSyntax?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @request.json
cat result.json
rm -f task.sh request.json
EOF

gcloud compute scp task.sh request.json linux-instance:~ \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet
gcloud compute ssh linux-instance \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet \
  --command="chmod +x task.sh && ./task.sh"
  
cat << 'EOF'

###################################################################
## Task 7. Multilingual natural language processing
###################################################################

EOF

rm -f request.json
cat > request.json <<'EOF'
{
  "document":{
    "type":"PLAIN_TEXT",
    "content":"日本のグーグルのオフィスは、東京の六本木ヒルズにあります"
  }
}
EOF

rm -f task.sh
cat > task.sh <<'EOF'
#!/bin/bash
export API_KEY=$(< ~/api_key.txt)
echo -e "\n👉  Analysis request:"
cat request.json
echo -e "\n👉  Analysis result:"
curl "https://language.googleapis.com/v1/documents:analyzeEntities?key=${API_KEY}" \
  -s -X POST -H "Content-Type: application/json" --data-binary @request.json
## Keep the files for lab checks
# rm -f task.sh request.json
EOF

gcloud compute scp task.sh request.json linux-instance:~ \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet
gcloud compute ssh linux-instance \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet \
  --command="chmod +x task.sh && ./task.sh"
