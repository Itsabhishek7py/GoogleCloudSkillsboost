#!/bin/bash

# Clear the terminal
clear

# Define color variables
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BG_BLACK=$(tput setab 0)
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)
BG_MAGENTA=$(tput setab 5)
BG_CYAN=$(tput setab 6)
BG_WHITE=$(tput setab 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

# Array of color codes excluding black and white
TEXT_COLORS=("$RED" "$GREEN" "$YELLOW" "$BLUE" "$MAGENTA" "$CYAN")
BG_COLORS=("$BG_RED" "$BG_GREEN" "$BG_YELLOW" "$BG_BLUE" "$BG_MAGENTA" "$BG_CYAN")

# Pick random colors
RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_COLOR=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

#----------------------------------------------------start--------------------------------------------------#

echo "${RANDOM_BG_COLOR}${RANDOM_TEXT_COLOR}${BOLD}Starting Execution${RESET}"

# Check if DEVSHELL_PROJECT_ID is set
if [[ -z "$DEVSHELL_PROJECT_ID" ]]; then
    echo "${RED}${BOLD}Error: DEVSHELL_PROJECT_ID is not set${RESET}"
    echo "Please run this script in Google Cloud Shell or set the DEVSHELL_PROJECT_ID variable"
    exit 1
fi

echo "${YELLOW}${BOLD}Project ID: $DEVSHELL_PROJECT_ID${RESET}"

# Step 0: Get the default compute region
echo "${GREEN}${BOLD}Retrieving Default Compute Region${RESET}"
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])" \
--project="$DEVSHELL_PROJECT_ID")

echo "${GREEN}Detected Region: $REGION${RESET}"

# Step 1: Enable the Geocoding Backend API
echo "${CYAN}${BOLD}Enabling the Geocoding Backend API${RESET}"
gcloud services enable geocoding-backend.googleapis.com --project="$DEVSHELL_PROJECT_ID"

# Step 2: Clone the training data analyst repository
echo "${YELLOW}${BOLD}Cloning the training data analyst repository${RESET}"
if [[ ! -d "training-data-analyst" ]]; then
    git clone --depth 1 https://github.com/GoogleCloudPlatform/training-data-analyst
else
    echo "${GREEN}Repository already exists, skipping clone${RESET}"
fi

# Step 3: Create a symbolic link for the Apigee directory
echo "${CYAN}${BOLD}Creating a symbolic link for the Apigee directory${RESET}"
if [[ ! -L "develop-apis-apigee" ]]; then
    ln -s ~/training-data-analyst/quests/develop-apis-apigee ~/develop-apis-apigee
else
    echo "${GREEN}Symbolic link already exists${RESET}"
fi

# Step 4: Navigate to the rest-backend directory
echo "${GREEN}${BOLD}Navigating to the rest-backend directory${RESET}"
cd ~/develop-apis-apigee/rest-backend || { echo "${RED}Failed to navigate to rest-backend directory${RESET}"; exit 1; }

# Step 5: Update the configuration file
echo "${YELLOW}${BOLD}Updating the configuration file to use the ${REGION} region${RESET}"
if [[ -f "config.sh" ]]; then
    sed -i.bak "s/us-west1/$REGION/g" config.sh
    echo "${GREEN}Configuration file updated successfully${RESET}"
else
    echo "${RED}config.sh file not found${RESET}"
fi

# Step 6: Display and execute the init-project.sh script
echo "${CYAN}${BOLD}Displaying and executing the init-project.sh script${RESET}"
if [[ -f "init-project.sh" ]]; then
    cat init-project.sh
    chmod +x init-project.sh
    ./init-project.sh
else
    echo "${RED}init-project.sh file not found${RESET}"
fi

# Step 7: Display and execute the init-service.sh script
echo "${GREEN}${BOLD}Displaying and executing the init-service.sh script${RESET}"
if [[ -f "init-service.sh" ]]; then
    cat init-service.sh
    chmod +x init-service.sh
    ./init-service.sh
else
    echo "${RED}init-service.sh file not found${RESET}"
fi

# Step 8: Display and execute the deploy.sh script
echo "${YELLOW}${BOLD}Displaying and executing the deploy.sh script${RESET}"
if [[ -f "deploy.sh" ]]; then
    cat deploy.sh
    chmod +x deploy.sh
    ./deploy.sh
else
    echo "${RED}deploy.sh file not found${RESET}"
fi

# Step 9: Export the REST backend host URL
echo "${CYAN}${BOLD}Exporting the REST backend host URL${RESET}"
export RESTHOST=$(gcloud run services describe simplebank-rest --platform managed --region "$REGION" --format 'value(status.url)' --project="$DEVSHELL_PROJECT_ID")
if [[ -n "$RESTHOST" ]]; then
    echo "export RESTHOST=${RESTHOST}" >> ~/.bashrc
    echo "${GREEN}REST Host: $RESTHOST${RESET}"
else
    echo "${RED}Failed to retrieve REST host URL${RESET}"
fi

# Step 10: Check the REST service status
echo "${GREEN}${BOLD}Checking the REST service status${RESET}"
if [[ -n "$RESTHOST" ]]; then
    curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" -X GET "${RESTHOST}/_status"
    echo
else
    echo "${RED}RESTHOST is not set, cannot check status${RESET}"
fi

# Step 11: Add a customer record to the REST service
echo "${YELLOW}${BOLD}Adding a customer record to the REST service${RESET}"
if [[ -n "$RESTHOST" ]]; then
    curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" -H "Content-Type: application/json" -X POST "${RESTHOST}/customers" -d '{"lastName": "Diallo", "firstName": "Temeka", "email": "temeka@example.com"}'
    echo
else
    echo "${RED}RESTHOST is not set, cannot add customer${RESET}"
fi

# Step 12: Retrieve customer details
echo "${CYAN}${BOLD}Retrieving customer details${RESET}"
if [[ -n "$RESTHOST" ]]; then
    curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" -X GET "${RESTHOST}/customers/temeka@example.com"
    echo
else
    echo "${RED}RESTHOST is not set, cannot retrieve customer details${RESET}"
fi

# Step 13: Import sample data into Firestore
echo "${GREEN}${BOLD}Importing sample data into Firestore${RESET}"
gcloud firestore import gs://cloud-training/api-dev-quest/firestore/example-data --project="$DEVSHELL_PROJECT_ID"

# Step 14: List all ATMs using the REST service
echo "${YELLOW}${BOLD}Listing all ATMs using the REST service${RESET}"
if [[ -n "$RESTHOST" ]]; then
    curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" -X GET "${RESTHOST}/atms"
    echo
else
    echo "${RED}RESTHOST is not set, cannot list ATMs${RESET}"
fi

# Step 15: Retrieve a specific ATM's details
echo "${CYAN}${BOLD}Retrieving a specific ATM's details${RESET}"
if [[ -n "$RESTHOST" ]]; then
    curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" -X GET "${RESTHOST}/atms/spruce-goose"
    echo
else
    echo "${RED}RESTHOST is not set, cannot retrieve ATM details${RESET}"
fi

# Step 16: Create a service account for Apigee internal access
echo "${GREEN}${BOLD}Creating a service account for Apigee internal access${RESET}"
gcloud iam service-accounts create apigee-internal-access \
--display-name="Service account for internal access by Apigee proxies" \
--project="$DEVSHELL_PROJECT_ID"

# Step 17: Add IAM policy binding to the REST service
echo "${YELLOW}${BOLD}Adding IAM policy binding to the REST service${RESET}"
gcloud run services add-iam-policy-binding simplebank-rest \
--member="serviceAccount:apigee-internal-access@${DEVSHELL_PROJECT_ID}.iam.gserviceaccount.com" \
--role=roles/run.invoker --region="$REGION" \
--project="$DEVSHELL_PROJECT_ID"

# Step 18: Get the REST service URL
echo "${CYAN}${BOLD}Getting the REST service URL${RESET}"
REST_SERVICE_URL=$(gcloud run services describe simplebank-rest --platform managed --region "$REGION" --format 'value(status.url)' --project="$DEVSHELL_PROJECT_ID")
echo "${GREEN}REST Service URL: $REST_SERVICE_URL${RESET}"

# Step 19: Create an API key for the Geocoding API
echo "${GREEN}${BOLD}Creating an API key for the Geocoding API${RESET}"
API_KEY=$(gcloud alpha services api-keys create --project="$DEVSHELL_PROJECT_ID" --display-name="Geocoding API key for Apigee" --api-target=service=geocoding_backend --format "value(keyString)" 2>/dev/null || echo "API_KEY_CREATION_FAILED")

if [[ "$API_KEY" != "API_KEY_CREATION_FAILED" && -n "$API_KEY" ]]; then
    echo "export API_KEY=${API_KEY}" >> ~/.bashrc
    echo "${GREEN}API Key created successfully${RESET}"
    echo "API_KEY=${API_KEY}"
else
    echo "${RED}Failed to create API key. This command might require additional permissions.${RESET}"
    echo "${YELLOW}You may need to create the API key manually from the Google Cloud Console.${RESET}"
    API_KEY="MANUAL_SETUP_REQUIRED"
fi

# Step 20: Monitor runtime instance and attach environment
echo "${YELLOW}${BOLD}Monitoring runtime instance and attaching environment${RESET}"
export INSTANCE_NAME=eval-instance
export ENV_NAME=eval
export PREV_INSTANCE_STATE=""

echo "Waiting for runtime instance ${INSTANCE_NAME} to be active"
while : ; do
    export INSTANCE_STATE=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -X GET "https://apigee.googleapis.com/v1/organizations/${GOOGLE_CLOUD_PROJECT}/instances/${INSTANCE_NAME}" | \
        jq -r "select(.state != null) | .state")
    
    [[ "${INSTANCE_STATE}" == "${PREV_INSTANCE_STATE}" ]] || (echo; echo "INSTANCE_STATE=${INSTANCE_STATE}")
    export PREV_INSTANCE_STATE=${INSTANCE_STATE}
    [[ "${INSTANCE_STATE}" != "ACTIVE" ]] || break
    echo -n "."
    sleep 5
done

echo
echo "Instance created, waiting for environment ${ENV_NAME} to be attached to instance"

while : ; do
    export ATTACHMENT_DONE=$(curl -s -H "Authorization: Bearer $(gcloud auth print-access-token)" \
        -X GET "https://apigee.googleapis.com/v1/organizations/${GOOGLE_CLOUD_PROJECT}/instances/${INSTANCE_NAME}/attachments" | \
        jq -r "select(.attachments != null) | .attachments[] | select(.environment == \"${ENV_NAME}\") | .environment")
    
    [[ "${ATTACHMENT_DONE}" != "${ENV_NAME}" ]] || break
    echo -n "."
    sleep 5
done

echo "***ORG IS READY TO USE***"

echo

# Provide the Apigee proxy creation URL
echo -e "${BLUE}${BOLD}Go to this link to create an Apigee proxy: ${RESET}""https://console.cloud.google.com/apigee/proxy-create?project=$DEVSHELL_PROJECT_ID"

echo

# Display backend URL and service account details
BACKEND_URL=$(gcloud run services describe simplebank-rest --platform managed --region "$REGION" --format='value(status.url)' --project="$DEVSHELL_PROJECT_ID")
echo -e "${YELLOW}${BOLD}Backend URL: ${RESET}""$BACKEND_URL"

echo

echo -e "${CYAN}${BOLD}Copy this service account: ${RESET}""apigee-internal-access@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com"

echo

echo -e "${GREEN}${BOLD}Copy this API KEY: ${RESET}""apikey=${API_KEY}"

echo

# Function to display a random congratulatory message
random_congrats() {
    local MESSAGES=(
        "${GREEN}Congratulations For Completing The Lab! Keep up the great work!${RESET}"
        "${CYAN}Well done! Your hard work and effort have paid off!${RESET}"
        "${YELLOW}Amazing job! You've successfully completed the lab!${RESET}"
        "${BLUE}Outstanding! Your dedication has brought you success!${RESET}"
        "${MAGENTA}Great work! You're one step closer to mastering this!${RESET}"
        "${RED}Fantastic effort! You've earned this achievement!${RESET}"
        "${CYAN}Congratulations! Your persistence has paid off brilliantly!${RESET}"
        "${GREEN}Bravo! You've completed the lab with flying colors!${RESET}"
        "${YELLOW}Excellent job! Your commitment is inspiring!${RESET}"
        "${BLUE}You did it! Keep striving for more successes like this!${RESET}"
    )

    local RANDOM_INDEX=$((RANDOM % ${#MESSAGES[@]}))
    echo -e "${BOLD}${MESSAGES[$RANDOM_INDEX]}"
}

# Display a random congratulatory message
random_congrats

echo -e "\n"  # Adding one blank line

# YouTube channel promotion
echo "${CYAN}${BOLD}Don't forget to subscribe to Dr. Abhishek Cloud Tutorial:${RESET}"
echo "${BLUE}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo

cd || exit

# Clean up files
remove_files() {
    # Loop through all files in the current directory
    for file in *; do
        # Check if the file name starts with "gsp", "arc", or "shell"
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            # Check if it's a regular file (not a directory)
            if [[ -f "$file" ]]; then
                # Remove the file and echo the file name
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}

remove_files
