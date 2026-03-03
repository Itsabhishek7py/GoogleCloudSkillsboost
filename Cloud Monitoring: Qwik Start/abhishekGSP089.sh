#!/bin/bash

# Define color variables
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'

# Define text formatting variables
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# Welcome message
echo "${BLUE_TEXT}${BOLD_TEXT}===============================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}        WELCOME TO DR ABHISHEK TUTORIALS      ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}===============================================${RESET_FORMAT}"
echo

echo "${BLUE_TEXT}${BOLD_TEXT}        LIKE THE VIDEO & SUBSCRIBE NOW...              ${RESET_FORMAT}"
echo

# Prompt user for Zone
echo "${YELLOW_TEXT}${BOLD_TEXT}Please enter your GCP Zone:${RESET_FORMAT}"
read -r ZONE
export ZONE

echo "${CYAN_TEXT}${BOLD_TEXT}Creating a new VM instance... Please wait.${RESET_FORMAT}"

# Create VM instance
gcloud compute instances create lamp-1-vm \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE \
    --machine-type=e2-small \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata=enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --tags=http-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=lamp-1-vm,image=projects/debian-cloud/global/images/debian-12-bookworm-v20240709,mode=rw,size=10,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any

echo "${YELLOW_TEXT}${BOLD_TEXT}Creating firewall rule to allow HTTP traffic...${RESET_FORMAT}"

gcloud compute firewall-rules create allow-http \
    --project=$DEVSHELL_PROJECT_ID \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

sleep 10

echo "${MAGENTA_TEXT}${BOLD_TEXT}Generating SSH keys...${RESET_FORMAT}"

gcloud compute config-ssh --project "$DEVSHELL_PROJECT_ID" --quiet

echo "${CYAN_TEXT}${BOLD_TEXT}Installing Apache and PHP on the VM...${RESET_FORMAT}"

gcloud compute ssh lamp-1-vm --project "$DEVSHELL_PROJECT_ID" --zone $ZONE --command "sudo apt-get update && sudo apt-get install apache2 php -y && sudo systemctl restart apache2"

sleep 10

echo "${GREEN_TEXT}${BOLD_TEXT}Fetching Instance ID...${RESET_FORMAT}"

INSTANCE_ID="$(gcloud compute instances describe lamp-1-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --format='value(id)')"

echo "${BLUE_TEXT}${BOLD_TEXT}Setting up Uptime Monitoring...${RESET_FORMAT}"

gcloud monitoring uptime create lamp-uptime-check \
  --resource-type="gce-instance" \
  --resource-labels=project_id=$DEVSHELL_PROJECT_ID,instance_id=$INSTANCE_ID,zone=$ZONE

echo "${YELLOW_TEXT}${BOLD_TEXT}Creating Email Notification Channel...${RESET_FORMAT}"

read -p "Enter your Email Address: " USER_EMAIL

cat > email-channel.json <<EOF
{
  "type": "email",
  "displayName": "DrAbhishekAlerts",
  "description": "Dr Abhishek Lab Alerts",
  "labels": {
    "email_address": "$USER_EMAIL"
  }
}
EOF

gcloud beta monitoring channels create --channel-content-from-file=email-channel.json

echo "${CYAN_TEXT}${BOLD_TEXT}Fetching Notification Channel ID...${RESET_FORMAT}"

channel_id=$(gcloud beta monitoring channels list --format="value(name)" | head -n 1)

echo "${MAGENTA_TEXT}${BOLD_TEXT}Creating Alert Policy...${RESET_FORMAT}"

cat > alert-policy.json <<EOF
{
  "displayName": "Inbound Traffic Alert",
  "conditions": [
    {
      "displayName": "VM Network Traffic",
      "conditionThreshold": {
        "filter": "resource.type=\"gce_instance\" AND metric.type=\"agent.googleapis.com/interface/traffic\"",
        "comparison": "COMPARISON_GT",
        "thresholdValue": 500,
        "duration": "60s",
        "trigger": { "count": 1 }
      }
    }
  ],
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": ["$channel_id"]
}
EOF

gcloud alpha monitoring policies create --policy-from-file=alert-policy.json

echo
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}              LAB COMPLETED SUCCESSFULLY!              ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"

echo
echo "${BLUE_TEXT}${BOLD_TEXT}🎉 Welcome to Dr Abhishek Tutorials! 🎉${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}If this helped you, please 👍 LIKE the video and 🔔 SUBSCRIBE to the channel!${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${UNDERLINE_TEXT}Watch more labs & tutorials here:${RESET_FORMAT}"
echo "${CYAN_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo
