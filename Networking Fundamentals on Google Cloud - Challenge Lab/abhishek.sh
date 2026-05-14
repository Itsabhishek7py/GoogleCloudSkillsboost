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
echo "${CYAN}${BOLD}        WELCOME TO DR ABHISHEK CLOUD         ${RESET}"
echo "${CYAN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${MAGENTA}${BOLD}          Expert Tutorial by Dr. Abhishek              ${RESET}"
echo "${YELLOW}For more GCP tutorials, visit: ${UNDERLINE}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
echo "${BLUE}${BOLD}⚡ Initializing Load Balancer Configuration...${RESET}"
echo

# User Input Section
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ REGION CONFIGURATION ▬▬▬▬▬▬▬▬▬${RESET}"
read -p "${BLUE}${BOLD}Enter ZONE (e.g., us-central1-a): ${RESET}" ZONE

# Extract Region from Zone
REGION=$(echo $ZONE | cut -d'-' -f1,2)

# Validate Region Input
if [[ -z "$REGION" ]]; then
  echo "${RED}${BOLD}Error: Could not determine region from zone. Please check your input.${RESET}"
  exit 1
fi

export REGION=$REGION
export ZONE=$ZONE

echo "${CYAN}Selected Region: ${WHITE}${BOLD}$REGION${RESET}"
echo "${CYAN}Selected Zone: ${WHITE}${BOLD}$ZONE${RESET}"
echo

# Web Server Creation
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ WEB SERVER SETUP ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Creating compute instances...${RESET}"

create_web_instance() {
  local instance_name=$1
  echo "${CYAN}Creating instance ${BOLD}$instance_name${RESET}..."
  gcloud compute instances create $instance_name \
    --zone=$ZONE \
    --machine-type=e2-small \
    --tags=network-lb-tag \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
    apt-get update
    apt-get install apache2 -y
    service apache2 restart
    echo "<h3>Web Server: '"$instance_name"'</h3>" | tee /var/www/html/index.html'
  echo "${GREEN}✅ Instance $instance_name created successfully!${RESET}"
  echo
}

create_web_instance "web1"
create_web_instance "web2"
create_web_instance "web3"

# Firewall Configuration
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ FIREWALL SETUP ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Configuring firewall rules...${RESET}"
gcloud compute firewall-rules create www-firewall-network-lb \
  --allow tcp:80 \
  --target-tags network-lb-tag
echo "${GREEN}✅ Firewall rule created successfully!${RESET}"
echo

# Load Balancer Configuration
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬ LOAD BALANCER SETUP ▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Setting up network load balancer...${RESET}"

echo "${CYAN}Creating IP address...${RESET}"
gcloud compute addresses create network-lb-ip-1 --region=$REGION

echo "${CYAN}Creating health check...${RESET}"
gcloud compute http-health-checks create basic-check

echo "${CYAN}Creating target pool...${RESET}"
gcloud compute target-pools create www-pool \
  --region=$REGION \
  --http-health-check basic-check

echo "${CYAN}Adding instances to pool...${RESET}"
gcloud compute target-pools add-instances www-pool \
  --instances web1,web2,web3 \
  --zone=$ZONE

echo "${CYAN}Creating forwarding rule...${RESET}"
gcloud compute forwarding-rules create www-rule \
  --region=$REGION \
  --ports 80 \
  --address network-lb-ip-1 \
  --target-pool www-pool

IPADDRESS=$(gcloud compute forwarding-rules describe www-rule --region=$REGION --format="json" | jq -r .IPAddress)
echo "${GREEN}✅ Network load balancer configured successfully!${RESET}"
echo "${CYAN}Load Balancer IP: ${WHITE}${BOLD}$IPADDRESS${RESET}"
echo

# HTTP Load Balancer Configuration
echo "${GREEN}${BOLD}▬▬▬▬▬ HTTP LOAD BALANCER SETUP ▬▬▬▬▬${RESET}"
echo "${YELLOW}Creating instance template...${RESET}"
gcloud compute instance-templates create lb-backend-template \
  --region=$REGION \
  --network=default \
  --subnet=default \
  --tags=allow-health-check \
  --machine-type=e2-medium \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --metadata=startup-script='#!/bin/bash
    apt-get update
    apt-get install apache2 -y
    a2ensite default-ssl
    a2enmod ssl
    vm_hostname="$(curl -H "Metadata-Flavor:Google" \
    http://169.254.169.254/computeMetadata/v1/instance/name)"
    echo "Page served from: $vm_hostname" | \
    tee /var/www/html/index.html
    systemctl restart apache2'
echo "${GREEN}✅ Instance template created successfully!${RESET}"
echo

echo "${YELLOW}Creating managed instance group...${RESET}"
gcloud compute instance-groups managed create lb-backend-group \
  --template=lb-backend-template \
  --size=2 \
  --zone=$ZONE
echo "${GREEN}✅ Managed instance group created successfully!${RESET}"
echo

echo "${YELLOW}Configuring firewall rules...${RESET}"
gcloud compute firewall-rules create fw-allow-health-check \
  --network=default \
  --action=allow \
  --direction=ingress \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=allow-health-check \
  --rules=tcp:80
echo "${GREEN}✅ Firewall rules configured successfully!${RESET}"
echo

echo "${YELLOW}Setting up HTTP load balancer...${RESET}"
gcloud compute addresses create lb-ipv4-1 --ip-version=IPV4 --global
gcloud compute health-checks create http http-basic-check --port 80
gcloud compute backend-services create web-backend-service \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=http-basic-check \
  --global
gcloud compute backend-services add-backend web-backend-service \
  --instance-group=lb-backend-group \
  --instance-group-zone=$ZONE \
  --global
gcloud compute url-maps create web-map-http --default-service web-backend-service
gcloud compute target-http-proxies create http-lb-proxy --url-map web-map-http
gcloud compute forwarding-rules create http-content-rule \
  --address=lb-ipv4-1 \
  --global \
  --target-http-proxy=http-lb-proxy \
  --ports=80
echo "${GREEN}✅ HTTP load balancer configured successfully!${RESET}"
echo

# Completion Section
echo "${GREEN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${GREEN}${BOLD}         LAB COMPLETED!                  ${RESET}"
echo "${GREEN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${RED}${BOLD}🙏 Special thanks to Dr. Abhishek for this tutorial!${RESET}"
echo "${YELLOW}${BOLD}📺 Subscribe for more GCP content:${RESET}"
echo "${BLUE}${UNDERLINE}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
echo "${MAGENTA}${BOLD}🚀 Happy cloud computing with Google Cloud!${RESET}"
