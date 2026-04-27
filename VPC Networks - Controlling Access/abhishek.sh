#!/bin/bash

# ================== STYLING ==================
CYAN=$'\033[0;96m'
GREEN=$'\033[0;92m'
YELLOW=$'\033[0;93m'
RED=$'\033[0;91m'
BOLD=$'\033[1m'
RESET=$'\033[0m'

clear

# ================== INTRO ==================
echo "${CYAN}${BOLD}=========================================================${RESET}"
echo "${CYAN}${BOLD}     🚀 Welcome Back! This is Dr Abhishek 🔥${RESET}"
echo "${CYAN}${BOLD}      Google Cloud Lab - Full Guide 😎${RESET}"
echo "${CYAN}${BOLD}=========================================================${RESET}"
echo

# ================== INPUT ==================
echo -e "${YELLOW}${BOLD}👉 Enter your ZONE (example: us-central1-a): ${RESET}"
read ZONE

REGION=${ZONE%-*}
echo -e "${GREEN}✔ Region Detected: ${REGION}${RESET}"

PROJECT_ID=$(gcloud config get-value project)
echo -e "${GREEN}✔ Project ID: ${PROJECT_ID}${RESET}"
echo

# ================== STARTUP SCRIPTS ==================
cat << 'EOF' > blue-startup.sh
#!/bin/bash
apt-get update
apt-get install nginx-light -y
echo "<h1>🚀 Blue Server Ready!</h1>" > /var/www/html/index.nginx-debian.html
EOF

cat << 'EOF' > green-startup.sh
#!/bin/bash
apt-get update
apt-get install nginx-light -y
echo "<h1>🌱 Green Server Ready!</h1>" > /var/www/html/index.nginx-debian.html
EOF

# ================== CREATE INSTANCES ==================
echo -e "${YELLOW}⚡ Creating BLUE server...${RESET}"
gcloud compute instances create blue \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --tags=web-server \
    --metadata-from-file=startup-script=blue-startup.sh

echo -e "${YELLOW}⚡ Creating GREEN server...${RESET}"
gcloud compute instances create green \
    --zone=$ZONE \
    --machine-type=e2-micro \
    --metadata-from-file=startup-script=green-startup.sh

# ================== FIREWALL ==================
echo -e "${YELLOW}🔥 Creating Firewall Rule...${RESET}"
gcloud compute firewall-rules create allow-http-web-server \
    --network=default \
    --action=allow \
    --direction=ingress \
    --rules=tcp:80,icmp \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web-server

# ================== TEST VM ==================
echo -e "${YELLOW}🧪 Creating test VM...${RESET}"
gcloud compute instances create test-vm \
    --zone=$ZONE \
    --machine-type=e2-micro

# ================== SERVICE ACCOUNT ==================
echo -e "${YELLOW}🔐 Creating Service Account...${RESET}"
gcloud iam service-accounts create Network-admin \
    --display-name="Network-admin"

SA_EMAIL="Network-admin@${PROJECT_ID}.iam.gserviceaccount.com"

echo -e "${YELLOW}🔑 Assigning Network Admin Role...${RESET}"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/compute.networkAdmin" > /dev/null 2>&1

echo -e "${YELLOW}📁 Generating credentials.json...${RESET}"
gcloud iam service-accounts keys create credentials.json \
    --iam-account=${SA_EMAIL}

# ================== PAUSE ==================
echo
echo "${RED}${BOLD}⚠️ ACTION REQUIRED${RESET}"
echo "👉 Click 'Check my progress' in lab now!"
read -p "Press ENTER after completing checkpoints..."

# ================== ROLE SWITCH ==================
echo -e "${YELLOW}🔄 Switching Roles...${RESET}"

gcloud projects remove-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/compute.networkAdmin" > /dev/null 2>&1

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/compute.securityAdmin" > /dev/null 2>&1

sleep 10

# ================== CLEANUP ==================
echo -e "${YELLOW}🧹 Cleaning Up Firewall...${RESET}"
gcloud compute firewall-rules delete allow-http-web-server --quiet

rm blue-startup.sh green-startup.sh

# ================== END ==================
echo
echo "${GREEN}${BOLD}=========================================================${RESET}"
echo "${GREEN}${BOLD}        🎉 LAB COMPLETED SUCCESSFULLY! 🎉${RESET}"
echo "${GREEN}${BOLD}=========================================================${RESET}"
echo
echo "${CYAN}👉 Follow Dr Abhishek for more 🔥${RESET}"
