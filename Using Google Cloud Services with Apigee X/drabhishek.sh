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

# Step 1: Enable required Google Cloud services
echo "${YELLOW}${BOLD}Enabling Required Google Cloud Services${RESET}"
gcloud services enable language.googleapis.com pubsub.googleapis.com logging.googleapis.com

# Step 2: Create a service account for Apigee access
echo "${CYAN}${BOLD}Creating Apigee Service Account${RESET}"
gcloud iam service-accounts create apigee-gc-service-access \
  --display-name "Apigee GC Service Access" \
  --project="$DEVSHELL_PROJECT_ID"

sleep 15

# Step 3: Assign Pub/Sub publisher role to the service account
echo "${MAGENTA}${BOLD}Assigning Pub/Sub Publisher Role${RESET}"
gcloud projects add-iam-policy-binding "$DEVSHELL_PROJECT_ID" \
  --member="serviceAccount:apigee-gc-service-access@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/pubsub.publisher"

# Step 4: Assign Logging Writer role to the service account
echo "${BLUE}${BOLD}Assigning Logging Writer Role${RESET}"
gcloud projects add-iam-policy-binding "$DEVSHELL_PROJECT_ID" \
  --member="serviceAccount:apigee-gc-service-access@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/logging.logWriter"

# Step 5: Monitor Apigee instance status
echo "${GREEN}${BOLD}Monitoring Apigee Instance Status${RESET}"
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

# Step 6: Create a Pub/Sub topic
echo "${CYAN}${BOLD}Creating Pub/Sub Topic: apigee-services-v1-delivery-reviews${RESET}"
gcloud pubsub topics create apigee-services-v1-delivery-reviews --project="$DEVSHELL_PROJECT_ID"

echo

# Step 7: Display final instructions
echo "${YELLOW}${BOLD}Final Instructions${RESET}"
echo
echo -e "${BLUE}${BOLD}Go to this link to create an Apigee proxy: ${RESET}""https://console.cloud.google.com/apigee/proxy-create?project=$DEVSHELL_PROJECT_ID"
echo
echo -e "${CYAN}${BOLD}Copy this service account: ${RESET}""apigee-gc-service-access@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com"
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

echo -e "\n"

# YouTube channel promotion
echo "${CYAN}${BOLD}Don't forget to subscribe to Dr. Abhishek Cloud Tutorial:${RESET}"
echo "${BLUE}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo

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

cd || exit
