#!/bin/bash
# Enhanced Color Definitions with Professional Formatting
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'
clear


echo
echo "${CYAN_TEXT}${BOLD_TEXT}==============================================${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}   Dr. Abhishek Cloud Lab Setup - VM Creation   ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==============================================${RESET_FORMAT}"
echo

# Get Zone Input with Validation
while true; do
    read -p "${YELLOW_TEXT}${BOLD_TEXT}🌍 Enter the Compute Zone (e.g., us-central1-a): ${RESET_FORMAT}" ZONE
    if [[ -n "$ZONE" ]]; then
        export ZONE
        break
    else
        echo "${RED_TEXT}Zone cannot be empty. Please try again.${RESET_FORMAT}"
    fi
done

# VM Creation Section
echo
echo "${BLUE_TEXT}${BOLD_TEXT}🖥️  Creating VM Instance 'cloud-lab-vm' in zone: ${WHITE_TEXT}$ZONE${RESET_FORMAT}"
echo "${CYAN_TEXT}This may take 1-2 minutes. Please wait...${RESET_FORMAT}"
echo

gcloud compute instances create cloud-lab-vm \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE \
    --machine-type=e2-medium \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
    --metadata=enable-oslogin=true \
    --maintenance-policy=MIGRATE \
    --provisioning-model=STANDARD \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,\
https://www.googleapis.com/auth/logging.write,\
https://www.googleapis.com/auth/monitoring.write,\
https://www.googleapis.com/auth/servicecontrol,\
https://www.googleapis.com/auth/service.management.readonly,\
https://www.googleapis.com/auth/trace.append \
    --tags=http-server \
    --create-disk=auto-delete=yes,boot=yes,device-name=cloud-lab-vm,\
image=projects/centos-cloud/global/images/centos-7-v20231010,mode=rw,size=20,\
type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --labels=goog-ec-src=vm_add-gcloud \
    --reservation-affinity=any

# Status Check
echo
echo "${GREEN_TEXT}${BOLD_TEXT}✅ VM Creation Command Executed Successfully${RESET_FORMAT}"
echo "${YELLOW_TEXT}⏳ Waiting for VM to become ready (approx. 30 seconds)...${RESET_FORMAT}"
echo

for i in {1..30}; do
    echo -ne "${CYAN_TEXT}⏳ ${i}/30 seconds elapsed\r${RESET_FORMAT}"
    sleep 1
done
echo

# SSH Configuration Section
echo
echo "${BLUE_TEXT}${BOLD_TEXT}🔧 Configuring Google Cloud SDK on the VM${RESET_FORMAT}"
echo "${CYAN_TEXT}This will install necessary packages and configure the environment${RESET_FORMAT}"
echo

gcloud compute ssh cloud-lab-vm \
    --project=$DEVSHELL_PROJECT_ID \
    --zone=$ZONE \
    --quiet \
    --command="\
sudo tee -a /etc/yum.repos.d/google-cloud-sdk.repo << EOM
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOM

echo '${GREEN_TEXT}Installing Google Cloud SDK...${RESET_FORMAT}'
sudo yum install google-cloud-sdk -y

echo '${GREEN_TEXT}Initializing gcloud environment...${RESET_FORMAT}'
gcloud init --console-only
"

# Completion Message
echo
echo "${CYAN_TEXT}${BOLD_TEXT}=============================================="
echo "          🎉 Lab Setup Complete!          "
echo "==============================================${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Successfully created and configured your cloud VM instance${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}Continue your cloud learning journey with:${RESET_FORMAT}"
echo "${BLUE_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460/${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}💡 Pro Tip: Check out our GCP certification playlist!${RESET_FORMAT}"
echo
