ro: Building Blocks Cloud Run functions II/abhishek.sh
+128
Original file line number	Diff line number	Diff line change
@@ -0,0 +1,128 @@
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
echo -e "${GREEN}${BOLD}First deployment complete!${RESET}"
echo -e "\n"  # Adding one blank line
# Second Cloud Function - Pub/Sub Trigger (Go)
echo -e "${CYAN}${BOLD}Configuring second Cloud Function (Pub/Sub Trigger - Go)...${RESET}"
read -p "Enter region for second function (e.g., us-central1): " REGION2
read -p "Enter Cloud Function name (e.g., cf-pubsub-go): " FUNCTION_NAME2
# Step 4: Create source code for the second Cloud Function
echo -e "${YELLOW}${BOLD}Creating sample Go Pub/Sub function...${RESET}"
mkdir -p cloud-function-pubsub-go
cat > cloud-function-pubsub-go/main.go <<EOF
package p
import (
	"context"
	"log"
)
// PubSubMessage is the payload of a Pub/Sub event.
type PubSubMessage struct {
	Data []byte `json:"data"`
}
// HelloPubSub consumes a Pub/Sub message.
func HelloPubSub(ctx context.Context, m PubSubMessage) error {
	log.Printf("Hello, %s!", string(m.Data))
	return nil
}
EOF
# Create go.mod file for Pub/Sub function
cat > cloud-function-pubsub-go/go.mod <<EOF
module cloudfunction
go 1.21
EOF
# Step 5: Deploy the second Cloud Function (2nd Gen)
echo -e "${BLUE}${BOLD}Deploying Cloud Function: ${FUNCTION_NAME2}...${RESET}"
gcloud functions deploy ${FUNCTION_NAME2} \
  --gen2 \
  --runtime=go121 \
  --region=${REGION2} \
  --source=cloud-function-pubsub-go \
  --entry-point=HelloPubSub \
  --trigger-topic=cf-pubsub \
  --max-instances=5
echo -e "${GREEN}${BOLD}Second deployment complete!${RESET}"
echo -e "\n"  # Adding one blank line
# Remove unwanted files from home directory
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
echo -e "${GREEN}${BOLD}Script execution completed successfully!${RESET}"
