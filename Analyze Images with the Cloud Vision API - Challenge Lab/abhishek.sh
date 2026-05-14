#!/bin/bash


BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
RESET=$'\033[0m'

# Text Colors
BLACK=$'\033[0;90m'
RED=$'\033[0;91m'
GREEN=$'\033[0;92m'
YELLOW=$'\033[0;93m'
BLUE=$'\033[0;94m'
MAGENTA=$'\033[0;95m'
CYAN=$'\033[0;96m'
WHITE=$'\033[0;97m'

# Background Colors
BG_RED=$'\033[41m'
BG_GREEN=$'\033[42m'
BG_YELLOW=$'\033[43m'

# ======================
#  SCRIPT HEADER
# ======================
clear
echo "${BLUE}${BOLD}============================================${RESET}"
echo "${BLUE}${BOLD}        WELCOME TO DR ABHISHEK CLOUD TUTORIALS        ${RESET}"
echo "${BLUE}${BOLD}============================================${RESET}"
echo ""
echo "${CYAN}${BOLD}⚡ Expertly crafted by Dr. Abhishek Cloud${RESET}"
echo "${YELLOW}${BOLD}📺 YouTube: ${UNDERLINE}https://www.youtube.com/@DrAbhishekCloud${RESET}"
echo ""

# ======================
#  API KEY CREATION
# ======================
echo "${MAGENTA}${BOLD}🔑 STEP 1: Creating API Key...${RESET}"
gcloud alpha services api-keys create --display-name="vision-lab-key" || {
    echo "${RED}${BOLD}❌ Error: Failed to create API key${RESET}"
    exit 1
}

KEY_NAME=$(gcloud alpha services api-keys list --format="value(name)" --filter "displayName=vision-lab-key")
export API_KEY=$(gcloud alpha services api-keys get-key-string $KEY_NAME --format="value(keyString)")
export PROJECT_ID=$(gcloud config get-value project)

echo "${GREEN}${BOLD}✔ Success: API Key created${RESET}"
echo "${WHITE}Key Value: ${YELLOW}$API_KEY${RESET}"
echo ""

# ======================
#  IMAGE PROCESSING
# ======================
echo "${MAGENTA}${BOLD}🖼️ STEP 2: Setting Image Permissions...${RESET}"
gsutil acl ch -u allUsers:R gs://$PROJECT_ID-bucket/manif-des-sans-papiers.jpg || {
    echo "${RED}${BOLD}❌ Error: Failed to set image permissions${RESET}"
    exit 1
}
echo "${GREEN}${BOLD}✔ Success: Image made publicly readable${RESET}"
echo ""

# ======================
#  TEXT DETECTION
# ======================
echo "${MAGENTA}${BOLD}📝 STEP 3: Performing TEXT_DETECTION...${RESET}"
cat > request.json <<EOF
{
  "requests": [
      {
        "image": {
          "source": {
              "gcsImageUri": "gs://$PROJECT_ID-bucket/manif-des-sans-papiers.jpg"
          }
        },
        "features": [
          {
            "type": "TEXT_DETECTION",
            "maxResults": 10
          }
        ]
      }
  ]
}
EOF

curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
https://vision.googleapis.com/v1/images:annotate?key=${API_KEY} -o text-response.json || {
    echo "${RED}${BOLD}❌ Error: Text detection failed${RESET}"
    exit 1
}

gsutil cp text-response.json gs://$PROJECT_ID-bucket/ || {
    echo "${RED}${BOLD}❌ Error: Failed to upload text response${RESET}"
    exit 1
}

echo "${GREEN}${BOLD}✔ Success: Text detection completed${RESET}"
echo "${WHITE}Results saved to: ${YELLOW}gs://$PROJECT_ID-bucket/text-response.json${RESET}"
echo ""

# ======================
#  LANDMARK DETECTION
# ======================
echo "${MAGENTA}${BOLD}🏛️ STEP 4: Performing LANDMARK_DETECTION...${RESET}"
cat > request.json <<EOF
{
  "requests": [
      {
        "image": {
          "source": {
              "gcsImageUri": "gs://$PROJECT_ID-bucket/manif-des-sans-papiers.jpg"
          }
        },
        "features": [
          {
            "type": "LANDMARK_DETECTION",
            "maxResults": 10
          }
        ]
      }
  ]
}
EOF

curl -s -X POST -H "Content-Type: application/json" --data-binary @request.json \
https://vision.googleapis.com/v1/images:annotate?key=${API_KEY} -o landmark-response.json || {
    echo "${RED}${BOLD}❌ Error: Landmark detection failed${RESET}"
    exit 1
}

gsutil cp landmark-response.json gs://$PROJECT_ID-bucket/ || {
    echo "${RED}${BOLD}❌ Error: Failed to upload landmark response${RESET}"
    exit 1
}

echo "${GREEN}${BOLD}✔ Success: Landmark detection completed${RESET}"
echo "${WHITE}Results saved to: ${YELLOW}gs://$PROJECT_ID-bucket/landmark-response.json${RESET}"
echo ""

# ======================
#  COMPLETION MESSAGE
# ======================
echo "${BG_GREEN}${BLACK}${BOLD}============================================${RESET}"
echo "${BG_GREEN}${BLACK}${BOLD}        LAB EXECUTED SUCCESSFULLY!         ${RESET}"
echo "${BG_GREEN}${BLACK}${BOLD}============================================${RESET}"
echo ""
echo "${WHITE}${BOLD}🔍 Access your detection results:${RESET}"
echo "${YELLOW}https://console.cloud.google.com/storage/browser/$PROJECT_ID-bucket${RESET}"
echo ""
echo "${CYAN}${BOLD}💡 For more Google Cloud labs and tutorials:${RESET}"
echo "${YELLOW}${BOLD}👉 ${UNDERLINE}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo "${GREEN}${BOLD}🔔 Don't forget to subscribe!${RESET}"
