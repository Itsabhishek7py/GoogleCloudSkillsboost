#!/bin/bash

# Enhanced color scheme
CYAN_BOLD=$'\033[1;36m'
PURPLE_BOLD=$'\033[1;35m'
GREEN_BOLD=$'\033[1;32m'
YELLOW_BOLD=$'\033[1;33m'
RED_BOLD=$'\033[1;31m'
BLUE_BOLD=$'\033[1;34m'
ORANGE_BOLD=$'\033[1;38;5;208m'
WHITE_BOLD=$'\033[1;37m'
RESET_FORMAT=$'\033[0m'

# Clear the screen
clear

echo
echo "${BLUE_BOLD}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${BLUE_BOLD}          🚀 Welcome to Dr. Abhishek's Cloud Lab         ${RESET_FORMAT}"
echo "${BLUE_BOLD}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo

# User input with emoji
read -p "$(echo -e ${PURPLE_BOLD}🌍 Enter the zone: ${RESET_FORMAT}) " ZONE
export ZONE

# Bucket creation
echo
echo "${GREEN_BOLD}🪣 Creating storage bucket in your project...${RESET_FORMAT}"
echo "${CYAN_BOLD}This bucket will store the startup script${RESET_FORMAT}"
echo
gsutil mb gs://$DEVSHELL_PROJECT_ID

# Script copy
echo
echo "${GREEN_BOLD}📤 Copying startup script to storage bucket...${RESET_FORMAT}"
echo "${CYAN_BOLD}Like the video${RESET_FORMAT}"
echo
gsutil cp gs://sureskills-ql/challenge-labs/ch01-startup-script/install-web.sh gs://$DEVSHELL_PROJECT_ID


echo
echo "${GREEN_BOLD}🖥️ Creating Compute Engine instance...${RESET_FORMAT}"
echo "${CYAN_BOLD}This instance will run the startup script to set up a web server${RESET_FORMAT}"
echo
gcloud compute instances create dr-abhishek-vm \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE \
    --machine-type=n1-standard-1 \
    --tags=http-server \
    --metadata startup-script-url=gs://$DEVSHELL_PROJECT_ID/install-web.sh

# Firewall setup
echo
echo "${GREEN_BOLD}🔥 Setting up firewall rule for HTTP traffic...${RESET_FORMAT}"
echo "${CYAN_BOLD}This will enable web access on port 80${RESET_FORMAT}"
echo
gcloud compute firewall-rules create allow-http \
    --allow=tcp:80 \
    --description="Subscribe to Dr Abhishek" \
    --direction=INGRESS \
    --target-tags=http-server

echo
echo "${GREEN_BOLD}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_BOLD}          🎉 Cloud Lab Completed Successfully!          ${RESET_FORMAT}"
echo "${GREEN_BOLD}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo -e "${YELLOW_BOLD}📺 Subscribe to my Channel:${RESET_FORMAT} ${BLUE_BOLD}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo -e "${PURPLE_BOLD}📷 Follow on Instagram:${RESET_FORMAT} ${ORANGE_BOLD}https://www.instagram.com/drabhishek.5460/${RESET_FORMAT}"
echo
