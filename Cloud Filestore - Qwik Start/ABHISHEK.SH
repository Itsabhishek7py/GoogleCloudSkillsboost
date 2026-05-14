#!/bin/bash

# Define text colors and formatting
BLACK_TEXT=$(tput setaf 0)
RED_TEXT=$(tput setaf 1)
GREEN_TEXT=$(tput setaf 10) # Brighter Green
YELLOW_TEXT=$(tput setaf 3)
BLUE_TEXT=$(tput setaf 4)
MAGENTA_TEXT=$(tput setaf 5)
CYAN_TEXT=$(tput setaf 6)
WHITE_TEXT=$(tput setaf 7)

RESET_FORMAT=$(tput sgr0)
BOLD_TEXT=$(tput bold)
ITALIC_TEXT=$(tput sitm)
UNDERLINE_TEXT=$(tput smul)

# Spinner function
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Function to run command with spinner
run_with_spinner() {
    local command="$1"
    local message="$2"
    
    echo -n "${YELLOW_TEXT}${BOLD_TEXT}$message... ${RESET_FORMAT}"
    (eval "$command" > /dev/null 2>&1) &
    spinner
    echo "${GREEN_TEXT}✓${RESET_FORMAT}"
}

clear # Clear the terminal screen

# --- Script Header ---
echo
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}         HEYA GUYS...         ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}Cloud Tutorial by Dr. Abhishek${RESET_FORMAT}"
echo "${CYAN_TEXT}For more GCP content, visit: ${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo

echo -n "${YELLOW_TEXT}${BOLD_TEXT}Please enter the zone: ${RESET_FORMAT}"
read ZONE
export ZONE

# Enable the required API
run_with_spinner \
    "gcloud services enable file.googleapis.com" \
    "${GREEN_TEXT}${BOLD_TEXT}Enabling the Filestore API"

# Create a Compute Engine instance with Debian 12 (bookworm)
echo "${GREEN_TEXT}${BOLD_TEXT}Creating a Compute Engine instance named 'nfs-client'...${RESET_FORMAT}"
run_with_spinner \
    "gcloud compute instances create nfs-client \
    --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata=enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --tags=http-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=nfs-client,image=projects/debian-cloud/global/images/debian-12-bookworm-v20231010,mode=rw,size=10,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any" \
    "Creating Compute Engine instance"

# Create a Filestore instance
echo "${GREEN_TEXT}${BOLD_TEXT}Creating a Filestore instance named 'nfs-server'...${RESET_FORMAT}"
run_with_spinner \
    "gcloud filestore instances create nfs-server \
    --zone=$ZONE --tier=BASIC_HDD \
    --file-share=name=\"vol1\",capacity=1TB \
    --network=name=\"default\"" \
    "Creating Filestore instance"

# Final message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}      LAB COMPLETED SUCCESSFULLY! ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo
echo "${RED_TEXT}${BOLD_TEXT}Special thanks to Dr. Abhishek for this tutorial!${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}Subscribe to Dr. Abhishek's YouTube channel for more GCP content:${RESET_FORMAT}"
echo "${BLUE_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Happy Cloud Computing!${RESET_FORMAT}"
