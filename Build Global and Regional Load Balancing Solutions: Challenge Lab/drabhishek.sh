#!/bin/bash

# Defin ek bandar copy karne  ata a ha usko maja chakaunga badhiya se legally
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
ORANGE_TEXT=$'\033[38;5;208m'
TEAL=$'\033[38;5;50m'

# Define text formatting variables
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'
BLINK_TEXT=$'\033[5m'
NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
REVERSE_TEXT=$'\033[7m'

clear

# Spinner function for visual feedback
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Welcome message
echo "${ORANGE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}      WELCOME TO DR. ABHISHEK'S CLOUD LAB SETUP${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo
echo "${ORANGE_TEXT}${BOLD_TEXT}🔔 PLEASE SUBSCRIBE TO DR. ABHISHEK'S CHANNEL:${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}📺 https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

echo -e "${YELLOW_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ REGION CONFIGURATION ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"
echo -e "${YELLOW_TEXT}Enter Lab Regions${RESET_FORMAT}"
read -p "Enter Region A: " REGION_A
read -p "Enter Region B: " REGION_B

export REGION_A
export REGION_B

echo -e "${GREEN_TEXT}✓ REGION_A = ${WHITE_TEXT}${BOLD_TEXT}$REGION_A${RESET_FORMAT}"
echo -e "${GREEN_TEXT}✓ REGION_B = ${WHITE_TEXT}${BOLD_TEXT}$REGION_B${RESET_FORMAT}"

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ CREATING MANAGED INSTANCE GROUPS ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"

echo -e "${BLUE_TEXT}Creating MIG A...${RESET_FORMAT}"
gcloud compute instance-groups managed create mig-alb-api-a \
    --template=template-alb-api \
    --size=1 \
    --region=$REGION_A &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ MIG A created${RESET_FORMAT}"

echo -e "${BLUE_TEXT}Setting named ports for MIG A...${RESET_FORMAT}"
gcloud compute instance-groups managed set-named-ports mig-alb-api-a \
    --named-ports=http80:80 \
    --region=$REGION_A &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Named ports configured for MIG A${RESET_FORMAT}"

echo -e "${BLUE_TEXT}Creating MIG B...${RESET_FORMAT}"
gcloud compute instance-groups managed create mig-alb-api-b \
    --template=template-alb-api \
    --size=1 \
    --region=$REGION_B &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ MIG B created${RESET_FORMAT}"

echo -e "${BLUE_TEXT}Setting named ports for MIG B...${RESET_FORMAT}"
gcloud compute instance-groups managed set-named-ports mig-alb-api-b \
    --named-ports=http80:80 \
    --region=$REGION_B &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Named ports configured for MIG B${RESET_FORMAT}"

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ CONFIGURING LOAD BALANCER ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"

echo -e "${BLUE_TEXT}Creating Health Check...${RESET_FORMAT}"
gcloud compute health-checks create http http-check-alb \
    --port=80 &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Health check created${RESET_FORMAT}"

echo -e "${BLUE_TEXT}Creating Backend Service...${RESET_FORMAT}"
gcloud compute backend-services create service-alb-global \
    --global \
    --protocol=HTTP \
    --health-checks=http-check-alb \
    --port-name=http80 &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Backend service created${RESET_FORMAT}"

echo -e "${BLUE_TEXT}Adding Backends...${RESET_FORMAT}"
gcloud compute backend-services add-backend service-alb-global \
    --global \
    --instance-group=mig-alb-api-a \
    --instance-group-region=$REGION_A \
    --balancing-mode=RATE \
    --max-rate-per-instance=1 &

pid=$!
spinner $pid
wait $pid

gcloud compute backend-services add-backend service-alb-global \
    --global \
    --instance-group=mig-alb-api-b \
    --instance-group-region=$REGION_B \
    --balancing-mode=RATE \
    --max-rate-per-instance=1 &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Backends added successfully${RESET_FORMAT}"

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ SSL CERTIFICATE SETUP ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"

echo -e "${BLUE_TEXT}Generating SSL Certificate...${RESET_FORMAT}"
openssl genrsa -out key.pem 2048 &

pid=$!
spinner $pid
wait $pid

openssl req -new -x509 \
    -key key.pem \
    -out cert.pem \
    -days 1 \
    -subj "/CN=example.com" &

pid=$!
spinner $pid
wait $pid

echo -e "${BLUE_TEXT}Creating SSL Certificate in GCP...${RESET_FORMAT}"
gcloud compute ssl-certificates create cert-self-signed \
    --certificate=cert.pem \
    --private-key=key.pem \
    --global &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ SSL certificate created${RESET_FORMAT}"

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ FIREWALL & NETWORK SETUP ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"

echo -e "${BLUE_TEXT}Creating Firewall Rule...${RESET_FORMAT}"
gcloud compute firewall-rules create fw-allow-health-check-and-proxy \
    --network=lb-network \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:80 \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=tag-alb-api &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Firewall rule created${RESET_FORMAT}"

echo -e "${BLUE_TEXT}Creating Global IP...${RESET_FORMAT}"
gcloud compute addresses create ip-alb-global \
    --global &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Global IP address reserved${RESET_FORMAT}"

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ FINALIZING LOAD BALANCER ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"

echo -e "${BLUE_TEXT}Creating URL Map...${RESET_FORMAT}"
gcloud compute url-maps create url-map-alb \
    --default-service=service-alb-global &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ URL map created${RESET_FORMAT}"

echo -e "${BLUE_TEXT}Creating HTTPS Proxy...${RESET_FORMAT}"
gcloud compute target-https-proxies create https-proxy-alb \
    --url-map=url-map-alb \
    --ssl-certificates=cert-self-signed &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ HTTPS proxy created${RESET_FORMAT}"

echo -e "${BLUE_TEXT}Creating Forwarding Rule...${RESET_FORMAT}"
gcloud compute forwarding-rules create https-forwarding-rule \
    --global \
    --target-https-proxy=https-proxy-alb \
    --ports=443 \
    --address=ip-alb-global &

pid=$!
spinner $pid
wait $pid
echo -e "${GREEN_TEXT}✓ Forwarding rule created${RESET_FORMAT}"

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ VERIFYING DEPLOYMENT ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"

echo -e "${MAGENTA_TEXT}Checking Backend Health...${RESET_FORMAT}"
gcloud compute backend-services get-health service-alb-global \
    --global

echo -e "${MAGENTA_TEXT}Checking Port Name...${RESET_FORMAT}"
gcloud compute backend-services describe service-alb-global \
    --global \
    --format="get(portName)"

echo
echo "${ORANGE_TEXT}${BOLD_TEXT}=========================================================${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}          LAB COMPLETED SUCCESSFULLY!${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}=========================================================${RESET_FORMAT}"
echo
echo "${ORANGE_TEXT}${BOLD_TEXT}🔴 PLEASE SUBSCRIBE TO DR. ABHISHEK'S CHANNEL:${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}📺 https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}=========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}⭐ Don't forget to Like, Share and Subscribe for more amazing content!${RESET_FORMAT}"
