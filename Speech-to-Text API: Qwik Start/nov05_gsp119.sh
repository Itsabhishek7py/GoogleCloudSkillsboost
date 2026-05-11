#!/bin/bash


# Export API key as environment variable
export API_KEY=$API_KEY
success "API key set as environment variable"

# Task 2: Create Speech-to-Text API request
display_task "TASK 2" "Create your Speech-to-Text API request"

# Create request.json file
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

# Make the API call and display response
echo "${YELLOW_TEXT}${BOLD_TEXT}API Response:${RESET_FORMAT}"
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}"
echo ""

# Save response to result.json
echo "${CYAN_TEXT}${BOLD_TEXT}Saving response to result.json...${RESET_FORMAT}"
curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
"https://speech.googleapis.com/v1/speech:recognize?key=${API_KEY}" > result.json

# Verify result.json creation
if [ ! -f "result.json" ]; then
    error_handler "Failed to save response to result.json"
else
    success "Response saved to result.json successfully"
    echo "${GREEN_TEXT}${BOLD_TEXT}Content of result.json:${RESET_FORMAT}"
    cat result.json
fi
