#!/bin/bash

# Colors for terminal output
RESET="\033[0m"
BOLD="\033[1m"
CYAN="\033[36m"
YELLOW="\033[33m"
BLUE="\033[34m"
GREEN="\033[32m"

# Welcome Header
echo -e "${BOLD}${CYAN}==============================================${RESET}"
echo -e "${BOLD}${GREEN}Welcome to Dr. Abhishek Cloud Tutorials!${RESET}"
echo -e "${BOLD}${CYAN}Subscribe to the channel:${RESET} https://www.youtube.com/@drabhishek.5460/videos"
echo -e "${BOLD}${CYAN}==============================================${RESET}"

echo -e "${GREEN}${BOLD}Starting Execution${RESET}"

# Step 1: Set environment variables
echo -e "${CYAN}${BOLD}Setting environment variables...${RESET}"
export PROJECT_ID=$(gcloud config get-value project)

# First Cloud Function - HTTP Trigger (Go)
echo -e "${CYAN}${BOLD}Configuring first Cloud Function (HTTP Trigger - Go)...${RESET}"
read -p "Enter region for first function (e.g., us-central1): " REGION1
read -p "Enter Cloud Function name (e.g., cf-http-go): " FUNCTION_NAME1

# Step 2: Create source code for the first Cloud Function
echo -e "${YELLOW}${BOLD}Creating sample Go HTTP function...${RESET}"
mkdir -p cloud-function-http-go
cat > cloud-function-http-go/main.go <<EOF
package p

import (
	"net/http"
)

func HelloHTTP(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello from Go HTTP Cloud Function!"))
}
EOF

# Create go.mod file for HTTP function
cat > cloud-function-http-go/go.mod <<EOF
module cloudfunction

go 1.21
EOF

# Step 3: Deploy the first Cloud Function (2nd Gen)
echo -e "${BLUE}${BOLD}Deploying Cloud Function: ${FUNCTION_NAME1}...${RESET}"
gcloud functions deploy ${FUNCTION_NAME1} \
  --gen2 \
  --runtime=go121 \
  --region=${REGION1} \
  --source=cloud-function-http-go \
  --entry-point=HelloHTTP \
  --trigger-http \
  --max-instances=5 \
  --allow-unauthenticated
## Copy KArlo aakhir tum bhi to mere bete ho :D
echo -e "${GREEN}${BOLD}First deployment complete!${RESET}"
echo -e "\n"

# Second Cloud Function - Cloud Storage Trigger (Go)
echo -e "${CYAN}${BOLD}Configuring second Cloud Function (Cloud Storage Trigger - Go)...${RESET}"
read -p "Enter region for second function (e.g., us-west1): " REGION2
read -p "Enter Cloud Function name (e.g., cf-gcs): " FUNCTION_NAME2

# Step 4: Create source code for the second Cloud Function
echo -e "${YELLOW}${BOLD}Creating sample Go Cloud Storage function...${RESET}"
mkdir -p cloud-function-gcs-go
cat > cloud-function-gcs-go/main.go <<EOF
package p

import (
	"context"
	"log"

	"cloud.google.com/go/functions/metadata"
)

type GCSEvent struct {
	Bucket         string \`json:"bucket"\`
	Name           string \`json:"name"\`
	Metageneration string \`json:"metageneration"\`
	ResourceState  string \`json:"resourceState"\`
}

func HelloGCS(ctx context.Context, e GCSEvent) error {
	meta, err := metadata.FromContext(ctx)
	if err != nil {
		return err
	}
	log.Printf("Event ID: %v\\n", meta.EventID)
	log.Printf("Event type: %v\\n", meta.EventType)
	log.Printf("Bucket: %v\\n", e.Bucket)
	log.Printf("File: %v\\n", e.Name)
	log.Printf("Metageneration: %v\\n", e.Metageneration)
	log.Printf("ResourceState: %v\\n", e.ResourceState)
	return nil
}
EOF

# Create go.mod file
cat > cloud-function-gcs-go/go.mod <<EOF
module cloudfunction

go 1.21

require cloud.google.com/go/functions v1.15.1
EOF

# Step 5: Deploy the second Cloud Function (2nd Gen)
BUCKET_NAME="${PROJECT_ID}-bucket"
SERVICE_ACCOUNT="Cloud Run functions demo account"

echo -e "${BLUE}${BOLD}Deploying Cloud Function: ${FUNCTION_NAME2}...${RESET}"
gcloud functions deploy ${FUNCTION_NAME2} \
  --gen2 \
  --runtime=go121 \
  --region=${REGION2} \
  --source=cloud-function-gcs-go \
  --entry-point=HelloGCS \
  --trigger-event-filters="type=google.cloud.storage.object.v1.finalized" \
  --trigger-event-filters="bucket=${BUCKET_NAME}" \
  --service-account="${SERVICE_ACCOUNT}" \
  --max-instances=5

echo -e "${GREEN}${BOLD}Second deployment complete!${RESET}"
echo -e "\n"

# Cleanup step: Remove temporary files from home directory
cd ~
remove_files() {
  for file in *; do
    if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
      if [[ -f "$file" ]]; then
        rm "$file"
        echo "File removed: $file"
      fi
    fi
  done
}
remove_files

echo -e "${GREEN}${BOLD}Lab  completed successfully!${RESET}"
