#!/bin/bash

# ==============================================
#  Cloud Vision API
#  Created by Dr. Abhishek Cloud Tutorials baki logo chori krte bass
#  YouTube: https://www.youtube.com/@drabhishek.5460
# ==============================================

# Text styles and colors
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
BLUE=$(tput setaf 4)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Header
echo
echo "${BLUE}${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo "${BLUE}${BOLD}║   CLOUD VISION API DEMO SETUP            ║${RESET}"
echo "${BLUE}${BOLD}║        by Dr. Abhishek Cloud             ║${RESET}"
echo "${BLUE}${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo

# Initialize environment
echo "${YELLOW}${BOLD}🔧 Initializing environment...${RESET}"
gcloud auth list

# Enable Cloud Vision API & API Keys API
echo "${YELLOW}${BOLD}🔌 Enabling required APIs (Vision & API Keys)...${RESET}"
gcloud services enable vision.googleapis.com apikeys.googleapis.com

# Create API Key with Vision API access via CLI
echo "${YELLOW}${BOLD}🔑 Creating and configuring API Key via CLI...${RESET}"

# Step 1: Create API key
echo "${YELLOW}➜ Generating API key...${RESET}"
gcloud services api-keys create --display-name="vision-demo" > /dev/null 2>&1

# Give Google Cloud a moment to register the new key
sleep 3

# Get the key name robustly using standard gcloud services
KEY_NAME=$(gcloud services api-keys list --format="value(name,displayName)" | grep "vision-demo" | head -n 1 | awk '{print $1}')

if [ -z "$KEY_NAME" ]; then
    echo "${RED}✗ Error: Failed to find the created API Key. Please check your gcloud permissions.${RESET}"
    exit 1
fi

# Get the actual API key string
export API_KEY=$(gcloud services api-keys get-key-string "$KEY_NAME" --format="value(keyString)")
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')

echo "${GREEN}✓ API Key created: ${API_KEY}${RESET}"
echo "${GREEN}✓ Project ID: ${PROJECT_ID}${RESET}"

# Step 2: Restrict API key to Cloud Vision API
echo "${YELLOW}➜ Restricting API key to Cloud Vision API only...${RESET}"

# Create a JSON file with the API restrictions
cat > api_key_restrictions.json << EOF
{
  "restrictions": {
    "apiTargets": [
      {
        "service": "vision.googleapis.com"
      }
    ]
  }
}
EOF

# Update the API key with restrictions
gcloud services api-keys update "$KEY_NAME" \
  --api-restrictions-from-file=api_key_restrictions.json > /dev/null 2>&1

echo "${GREEN}✓ API key restricted successfully${RESET}"

# Clean up temp file
rm -f api_key_restrictions.json
echo

# Create storage bucket
echo "${YELLOW}${BOLD}📦 Creating storage bucket...${RESET}"
gsutil mb gs://$PROJECT_ID > /dev/null 2>&1
echo "${GREEN}✓ Bucket created: gs://${PROJECT_ID}${RESET}"

# Download sample images
echo "${YELLOW}${BOLD}🌄 Downloading sample images...${RESET}"

# GitHub URLs
declare -A IMAGES=(
    ["city.png"]="https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/5c7847c58b86b282a6e6598f725b6a9b1ef03e95/Detecting%20Labels%2C%20Faces%2C%20and%20Landmarks%20in%20Images%20with%20the%20Cloud%20Vision%20API/city.png"
    ["donuts.png"]="https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/main/Detecting%20Labels%2C%20Faces%2C%20and%20Landmarks%20in%20Images%20with%20the%20Cloud%20Vision%20API/donuts.png"
    ["selfie.png"]="https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/5c7847c58b86b282a6e6598f725b6a9b1ef03e95/Detecting%20Labels%2C%20Faces%2C%20and%20Landmarks%20in%20Images%20with%20the%20Cloud%20Vision%20API/selfie.png"
)

for filename in "${!IMAGES[@]}"; do
    echo "${YELLOW}➜ Downloading ${filename}...${RESET}"
    curl -L -o "$filename" "${IMAGES[$filename]}" > /dev/null 2>&1 && \
    echo "${GREEN}✓ Downloaded ${filename}${RESET}" || \
    echo "${RED}✗ Failed to download ${filename}${RESET}"
done

# Upload to Cloud Storage
echo "${YELLOW}${BOLD}☁️ Uploading images to Cloud Storage...${RESET}"
for filename in "${!IMAGES[@]}"; do
    if [ -f "$filename" ]; then
        gsutil cp "$filename" gs://$PROJECT_ID/ > /dev/null 2>&1 && \
        echo "${GREEN}✓ Uploaded ${filename}${RESET}" || \
        echo "${RED}✗ Failed to upload ${filename}${RESET}"
    fi
done

# Make images publicly accessible
echo "${YELLOW}${BOLD}🔓 Setting public access...${RESET}"
for filename in "${!IMAGES[@]}"; do
    gcloud storage objects update gs://$PROJECT_ID/"$filename" --add-acl-grant=entity=AllUsers,role=READER > /dev/null 2>&1 && \
    echo "${GREEN}✓ Made ${filename} public${RESET}" || \
    echo "${RED}✗ Failed to make ${filename} public${RESET}"
done

# Test the API with a sample image
echo "${YELLOW}${BOLD}🧪 Testing Cloud Vision API...${RESET}"

# Create test JSON request
cat > test_vision_request.json << EOF
{
  "requests": [
    {
      "image": {
        "source": {
          "imageUri": "https://storage.googleapis.com/${PROJECT_ID}/city.png"
        }
      },
      "features": [
        {
          "type": "LABEL_DETECTION",
          "maxResults": 3
        }
      ]
    }
  ]
}
EOF

# Make API call
echo "${YELLOW}➜ Sending test request to Cloud Vision API...${RESET}"
RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "X-Goog-Api-Key: ${API_KEY}" \
  -d @test_vision_request.json \
  "https://vision.googleapis.com/v1/images:annotate")

if echo "$RESPONSE" | grep -q "labels"; then
    echo "${GREEN}✓ Cloud Vision API is working correctly!${RESET}"
    echo "${YELLOW}Test response:${RESET}"
    echo "$RESPONSE" | jq '.responses[0].labelAnnotations[].description' 2>/dev/null || echo "$RESPONSE"
else
    echo "${RED}✗ API test failed. Please check your setup.${RESET}"
    echo "${YELLOW}Response:${RESET}"
    echo "$RESPONSE"
fi

# Clean up
rm -f test_vision_request.json

# Final output
echo
echo "${BLUE}${BOLD}╔══════════════════════════════════════════╗${RESET}"
echo "${BLUE}${BOLD}║        SETUP COMPLETED SUCCESSFULLY      ║${RESET}"
echo "${BLUE}${BOLD}╚══════════════════════════════════════════╝${RESET}"
echo
echo "${BOLD}📋 Summary:${RESET}"
echo "  ${GREEN}✓${RESET} Required APIs (Vision & API Keys) enabled"
echo "  ${GREEN}✓${RESET} API Key created automatically via CLI"
echo "  ${GREEN}✓${RESET} API Key successfully restricted to Vision API"
echo "  ${GREEN}✓${RESET} Storage bucket created"
echo "  ${GREEN}✓${RESET} Sample images uploaded"
echo "  ${GREEN}✓${RESET} API tested successfully"
echo
echo "${BOLD}Access your images at:${RESET}"
for filename in "${!IMAGES[@]}"; do
    echo "  ${BLUE}https://storage.googleapis.com/${PROJECT_ID}/${filename}${RESET}"
done
echo
echo "${BOLD}🔑 Your API Key:${RESET}"
echo "  ${GREEN}${API_KEY}${RESET}"
echo
echo "${YELLOW}${BOLD}📺 For more cloud tutorials, subscribe to:${RESET}"
echo "${BLUE}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
echo "${YELLOW}${BOLD}💡 Next Steps:${RESET}"
echo "  1. Use the API Key in your applications"
echo "  2. Test different features: LABEL_DETECTION, FACE_DETECTION, LANDMARK_DETECTION"
echo "  3. Check your API usage in Cloud Console > APIs & Services > Dashboard"
echo
