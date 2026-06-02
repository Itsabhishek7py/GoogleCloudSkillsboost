#!/bin/bash

BLACK_TEXT=$'\033[0;90m' 
RED_TEXT=$'\033[0;91m' 
GREEN_TEXT=$'\033[0;92m' 
YELLOW_TEXT=$'\033[0;93m' 
ORANGE_TEXT=$'\033[38;5;208m'
CYAN_TEXT=$'\033[0;96m' 
WHITE_TEXT=$'\033[0;97m' 
BOLD_TEXT=$'\033[1m' 
RESET_FORMAT=$'\033[0m'

clear

# Spinner function
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
echo "${ORANGE_TEXT}${BOLD_TEXT}         WELCOME TO DR. ABHISHEK'S CLOUD LAB SETUP${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo
echo "${ORANGE_TEXT}${BOLD_TEXT}🔔 PLEASE SUBSCRIBE TO DR. ABHISHEK'S CHANNEL:${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}📺 https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

# ========================= ZONE CONFIGURATION =========================

echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ ZONE CONFIGURATION ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"

read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter the ZONE (e.g. us-central1-a): ${RESET_FORMAT}" ZONE

if [[ -z "$ZONE" ]]; then
    echo "${RED_TEXT}${BOLD_TEXT}Error: Zone cannot be empty.${RESET_FORMAT}"
    exit 1
fi

REGION=${ZONE%-*}

gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

echo
echo "${CYAN_TEXT}Selected Zone: ${WHITE_TEXT}${BOLD_TEXT}$ZONE${RESET_FORMAT}"
echo "${CYAN_TEXT}Derived Region: ${WHITE_TEXT}${BOLD_TEXT}$REGION${RESET_FORMAT}"
echo

# ========================= WEB SERVER SETUP =========================

echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ WEB SERVER SETUP ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"

create_web_server() {
    local server_name=$1

    echo "${CYAN_TEXT}Creating ${server_name}...${RESET_FORMAT}"

    gcloud compute instances create $server_name \
      --zone=$ZONE \
      --tags=network-lb-tag \
      --machine-type=e2-small \
      --image-family=debian-11 \
      --image-project=debian-cloud \
      --metadata=startup-script="#!/bin/bash
apt-get update
apt-get install apache2 -y
service apache2 restart
echo '<h3>Web Server: $server_name</h3>' > /var/www/html/index.html" &

    local pid=$!
    spinner $pid
    wait $pid

    echo "${GREEN_TEXT}${server_name} created successfully.${RESET_FORMAT}"
    echo
}

create_web_server www1
create_web_server www2
create_web_server www3

# ========================= FIREWALL =========================

echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ FIREWALL SETUP ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"

echo "${CYAN_TEXT}Creating firewall rule...${RESET_FORMAT}"

gcloud compute firewall-rules create www-firewall-network-lb \
    --target-tags network-lb-tag \
    --allow tcp:80 &

pid=$!
spinner $pid
wait $pid

echo "${GREEN_TEXT}Firewall rule created.${RESET_FORMAT}"
echo

# ========================= VERIFY INSTANCES =========================

echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ VERIFY INSTANCES ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"

gcloud compute instances list

echo
echo "${YELLOW_TEXT}Waiting for startup scripts to finish...${RESET_FORMAT}"
sleep 30

# ========================= NETWORK LOAD BALANCER =========================

echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ NETWORK LOAD BALANCER ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"

echo "${CYAN_TEXT}Reserving IP address...${RESET_FORMAT}"
gcloud compute addresses create network-lb-ip-1 \
    --region=$REGION &
pid=$!
spinner $pid
wait $pid

echo "${CYAN_TEXT}Creating health check...${RESET_FORMAT}"
gcloud compute http-health-checks create basic-check &
pid=$!
spinner $pid
wait $pid

echo "${CYAN_TEXT}Creating target pool...${RESET_FORMAT}"
gcloud compute target-pools create www-pool \
    --region=$REGION \
    --http-health-check basic-check &
pid=$!
spinner $pid
wait $pid

echo "${CYAN_TEXT}Adding instances to target pool...${RESET_FORMAT}"
gcloud compute target-pools add-instances www-pool \
    --instances www1,www2,www3 &
pid=$!
spinner $pid
wait $pid

echo "${CYAN_TEXT}Creating forwarding rule...${RESET_FORMAT}"
gcloud compute forwarding-rules create www-rule \
    --region=$REGION \
    --ports=80 \
    --address=network-lb-ip-1 \
    --target-pool=www-pool &
pid=$!
spinner $pid
wait $pid

echo
echo "${YELLOW_TEXT}Waiting for health checks...${RESET_FORMAT}"
sleep 30

IPADDRESS=$(gcloud compute forwarding-rules describe www-rule \
    --region=$REGION \
    --format="get(IPAddress)")

echo
echo "${GREEN_TEXT}${BOLD_TEXT}LOAD BALANCER CREATED SUCCESSFULLY${RESET_FORMAT}"
echo "${CYAN_TEXT}Load Balancer IP:${RESET_FORMAT} ${WHITE_TEXT}${BOLD_TEXT}$IPADDRESS${RESET_FORMAT}"
echo

# ========================= TEST LOAD BALANCER =========================

echo "${GREEN_TEXT}${BOLD_TEXT}▬▬▬▬▬▬▬▬▬ TESTING LOAD BALANCER ▬▬▬▬▬▬▬▬▬${RESET_FORMAT}"

for i in {1..10}
do
    curl -s http://$IPADDRESS
    echo
done

echo
echo "${ORANGE_TEXT}${BOLD_TEXT}=========================================================${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}          LAB COMPLETED SUCCESSFULLY!${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}=========================================================${RESET_FORMAT}"
echo
echo "${ORANGE_TEXT}${BOLD_TEXT}🔴 PLEASE SUBSCRIBE TO DR. ABHISHEK'S CHANNEL:${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}📺 https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}=========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}⭐ Don't forget to Like, Share and Subscribe for more amazing content!${RESET_FORMAT}"
