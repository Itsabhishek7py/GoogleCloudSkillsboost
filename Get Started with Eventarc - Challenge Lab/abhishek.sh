#!/bin/bash

# Enhanced Color Definitions
BLACK=$'\033[0;90m'
RED=$'\033[0;91m'
GREEN=$'\033[0;92m'
YELLOW=$'\033[0;93m'
BLUE=$'\033[0;94m'
MAGENTA=$'\033[0;95m'
CYAN=$'\033[0;96m'
WHITE=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET=$'\033[0m'
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'

# Header Section
echo "${CYAN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${CYAN}${BOLD}         HELLO GUYS WELCOME TO MY CHANNEL         ${RESET}"
echo "${CYAN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${MAGENTA}${BOLD}          Expert Tutorial by Dr. Abhishek              ${RESET}"
echo "${YELLOW}For more GCP tutorials, visit: ${UNDERLINE}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
echo "${BLUE}${BOLD}⚡ Initializing Event-Driven Architecture Setup...${RESET}"
echo

# User Input Section
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ INPUT PARAMETERS ▬▬▬▬▬▬▬▬▬${RESET}"
read -p "${YELLOW}${BOLD}Enter the location (e.g., us-central1): ${RESET}" LOCATION
export LOCATION
echo
echo "${CYAN}Configuration Parameters:${RESET}"
echo "${WHITE}Location: ${BOLD}$LOCATION${RESET}"
echo

# Service Enablement
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ ENABLING SERVICES ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Enabling required Google Cloud services...${RESET}"
gcloud services enable run.googleapis.com
gcloud services enable eventarc.googleapis.com
echo "${GREEN}✅ Services enabled successfully!${RESET}"
echo

# Pub/Sub Setup
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ PUB/SUB CONFIGURATION ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Creating Pub/Sub topic and subscription...${RESET}"
gcloud pubsub topics create "$DEVSHELL_PROJECT_ID-topic"
gcloud pubsub subscriptions create --topic "$DEVSHELL_PROJECT_ID-topic" "$DEVSHELL_PROJECT_ID-topic-sub"
echo "${GREEN}✅ Pub/Sub resources created successfully!${RESET}"
echo

# Cloud Run Deployment
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ CLOUD RUN DEPLOYMENT ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Deploying Cloud Run service...${RESET}"
gcloud run deploy pubsub-events \
  --image=gcr.io/cloudrun/hello \
  --platform=managed \
  --region="$LOCATION" \
  --allow-unauthenticated
echo "${GREEN}✅ Cloud Run service deployed successfully!${RESET}"
echo

# Eventarc Trigger Setup
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ EVENTARC CONFIGURATION ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Creating Eventarc trigger for Pub/Sub messages...${RESET}"
gcloud eventarc triggers create pubsub-events-trigger \
  --location="$LOCATION" \
  --destination-run-service=pubsub-events \
  --destination-run-region="$LOCATION" \
  --transport-topic="$DEVSHELL_PROJECT_ID-topic" \
  --event-filters="type=google.cloud.pubsub.topic.v1.messagePublished"
echo "${GREEN}✅ Eventarc trigger created successfully!${RESET}"
echo

# Test Message
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ TESTING THE SETUP ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Sending test message to Pub/Sub topic...${RESET}"
gcloud pubsub topics publish "$DEVSHELL_PROJECT_ID-topic" \
  --message="Test message from Dr. Abhishek's tutorial"
echo "${GREEN}✅ Test message sent successfully!${RESET}"
echo

# Completion Message
echo "${GREEN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${GREEN}${BOLD}          TUTORIAL COMPLETED SUCCESSFULLY!               ${RESET}"
echo "${GREEN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${RED}${BOLD}🙏 Thank you for following Dr. Abhishek's tutorial!${RESET}"
echo "${YELLOW}${BOLD}📺 Subscribe for more GCP content:${RESET}"
echo "${BLUE}${UNDERLINE}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
echo "${MAGENTA}${BOLD}🚀 Happy building event-driven architectures on GCP!${RESET}"
