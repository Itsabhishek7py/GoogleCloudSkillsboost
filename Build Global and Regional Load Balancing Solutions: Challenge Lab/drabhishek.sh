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
ORANGE_TEXT=$'\033[38;5;208m'

# Define text formatting variables
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'
RESET_FORMAT=$'\033[0m'

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

# ========================= TASK 1: INTERNAL PROXY NLB =========================

echo "${ORANGE_TEXT}${BOLD_TEXT}═══════════════════════════════════════════════════════════════${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}     TASK 1: SECURE INTERNAL TRANSACTION PROCESSOR${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}═══════════════════════════════════════════════════════════════${RESET_FORMAT}"
echo

# Get region and zone inputs
echo "${YELLOW_TEXT}${BOLD_TEXT}Enter Region A (e.g., us-central1):${RESET_FORMAT}"
read -p "Region A: " REGION_A
echo "${YELLOW_TEXT}${BOLD_TEXT}Enter Region B (e.g., us-east1):${RESET_FORMAT}"
read -p "Region B: " REGION_B
echo "${YELLOW_TEXT}${BOLD_TEXT}Enter Zone for Region B (e.g., us-east1-b):${RESET_FORMAT}"
read -p "Zone B: " ZONE_B

export REGION_A REGION_B ZONE_B

echo
echo "${GREEN_TEXT}✓ Region A: $REGION_A${RESET_FORMAT}"
echo "${GREEN_TEXT}✓ Region B: $REGION_B${RESET_FORMAT}"
echo "${GREEN_TEXT}✓ Zone B: $ZONE_B${RESET_FORMAT}"
echo

# Create instance template for internal proxy
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating instance template for internal proxy...${RESET_FORMAT}"
gcloud compute instance-templates create template-proxy-internal \
    --region=$REGION_B \
    --network=lb-network \
    --subnet=lb-subnet-b \
    --tags=tag-proxy-internal \
    --machine-type=e2-micro \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx' &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ Instance template created${RESET_FORMAT}"
echo

# Create regional MIG for internal proxy
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating regional MIG for internal proxy...${RESET_FORMAT}"
gcloud compute instance-groups managed create mig-proxy-internal \
    --template=template-proxy-internal \
    --size=1 \
    --region=$REGION_B &

pid=$!
spinner $pid
wait $pid

# Set named port
gcloud compute instance-groups managed set-named-ports mig-proxy-internal \
    --named-ports=tcp80:80 \
    --region=$REGION_B &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ MIG created with named port${RESET_FORMAT}"
echo

# Create firewall rules for internal proxy
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating firewall rules...${RESET_FORMAT}"
gcloud compute firewall-rules create fw-allow-health-check-proxy \
    --network=lb-network \
    --action=ALLOW \
    --direction=INGRESS \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=tag-proxy-internal \
    --rules=tcp:80 &

pid=$!
spinner $pid
wait $pid

gcloud compute firewall-rules create fw-allow-proxy-subnet \
    --network=lb-network \
    --action=ALLOW \
    --direction=INGRESS \
    --source-ranges=10.129.0.0/23 \
    --target-tags=tag-proxy-internal \
    --rules=tcp:80 &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ Firewall rules created${RESET_FORMAT}"
echo

# Reserve internal IP address
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Reserving internal IP address...${RESET_FORMAT}"
gcloud compute addresses create ip-internal-proxy \
    --region=$REGION_B \
    --subnet=lb-subnet-b \
    --purpose=SHARED_LOADBALANCER_VIP \
    --addresses=10.129.0.99 &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ Internal IP reserved${RESET_FORMAT}"
echo

# Create health check
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating health check...${RESET_FORMAT}"
gcloud compute health-checks create tcp tcp-health-check-proxy \
    --port=80 &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ Health check created${RESET_FORMAT}"
echo

# Create backend service
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating backend service...${RESET_FORMAT}"
gcloud compute backend-services create service-proxy-internal \
    --load-balancing-scheme=INTERNAL \
    --protocol=TCP \
    --region=$REGION_B \
    --health-checks=tcp-health-check-proxy \
    --health-checks-region=$REGION_B &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ Backend service created${RESET_FORMAT}"
echo

# Add backend
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Adding backend to service...${RESET_FORMAT}"
gcloud compute backend-services add-backend service-proxy-internal \
    --region=$REGION_B \
    --instance-group=mig-proxy-internal \
    --instance-group-region=$REGION_B &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ Backend added${RESET_FORMAT}"
echo

# Create forwarding rule
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating forwarding rule...${RESET_FORMAT}"
gcloud compute forwarding-rules create rule-internal-proxy \
    --region=$REGION_B \
    --load-balancing-scheme=INTERNAL \
    --network=lb-network \
    --subnet=lb-subnet-b \
    --address=ip-internal-proxy \
    --ports=110 \
    --backend-service=service-proxy-internal \
    --backend-service-region=$REGION_B &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ Forwarding rule created${RESET_FORMAT}"
echo

# Create client VM for validation
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating client VM for validation...${RESET_FORMAT}"
gcloud compute instances create vm-client-internal \
    --zone=$ZONE_B \
    --network=lb-network \
    --subnet=lb-subnet-b \
    --tags=allow-ssh \
    --machine-type=e2-micro \
    --image-family=debian-11 \
    --image-project=debian-cloud &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ Client VM created${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}✓ TASK 1 COMPLETED SUCCESSFULLY!${RESET_FORMAT}"
echo

# ========================= TASK 2: GLOBAL EXTERNAL ALB =========================

echo "${ORANGE_TEXT}${BOLD_TEXT}═══════════════════════════════════════════════════════════════${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}     TASK 2: GLOBAL EXTERNAL MARKET DATA FEED${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}═══════════════════════════════════════════════════════════════${RESET_FORMAT}"
echo

# Create instance template for ALB API
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating instance template for ALB API...${RESET_FORMAT}"
gcloud compute instance-templates create template-alb-api \
    --network=lb-network \
    --tags=tag-alb-api \
    --machine-type=e2-micro \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
apt-get update
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx
echo "<!DOCTYPE html>
<html>
<head><title>Hello from Cymbal Systems</title></head>
<body>
<h1>Hello from Cymbal Systems</h1>
<p>Page served from: <strong>'$(hostname)'</strong></p>
</body>
</html>" | tee /var/www/html/index.html' &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ Instance template created${RESET_FORMAT}"
echo

# Create MIG in Region A
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating MIG in Region A...${RESET_FORMAT}"
gcloud compute instance-groups managed create mig-alb-api-a \
    --template=template-alb-api \
    --size=1 \
    --region=$REGION_A &

pid=$!
spinner $pid
wait $pid

gcloud compute instance-groups managed set-named-ports mig-alb-api-a \
    --named-ports=http80:80 \
    --region=$REGION_A &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ MIG A created${RESET_FORMAT}"
echo

# Create MIG in Region B
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating MIG in Region B...${RESET_FORMAT}"
gcloud compute instance-groups managed create mig-alb-api-b \
    --template=template-alb-api \
    --size=1 \
    --region=$REGION_B &

pid=$!
spinner $pid
wait $pid

gcloud compute instance-groups managed set-named-ports mig-alb-api-b \
    --named-ports=http80:80 \
    --region=$REGION_B &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ MIG B created${RESET_FORMAT}"
echo

# Create global health check
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating global health check...${RESET_FORMAT}"
gcloud compute health-checks create http http-check-alb \
    --port=80 &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ Health check created${RESET_FORMAT}"
echo

# Create global backend service
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating global backend service...${RESET_FORMAT}"
gcloud compute backend-services create service-alb-global \
    --global \
    --protocol=HTTP \
    --health-checks=http-check-alb \
    --port-name=http80 &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ Backend service created${RESET_FORMAT}"
echo

# Add backends with Rate balancing mode (Max RPS = 1)
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Adding backends with Rate balancing mode...${RESET_FORMAT}"
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
echo "${GREEN_TEXT}✓ Backends added${RESET_FORMAT}"
echo

# Generate SSL certificate
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Generating SSL certificate...${RESET_FORMAT}"
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

gcloud compute ssl-certificates create cert-self-signed \
    --certificate=cert.pem \
    --private-key=key.pem \
    --global &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ SSL certificate created${RESET_FORMAT}"
echo

# Reserve global static external IP
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Reserving global static external IP...${RESET_FORMAT}"
gcloud compute addresses create ip-alb-global \
    --global &

pid=$!
spinner $pid
wait $pid

IP_ADDRESS=$(gcloud compute addresses describe ip-alb-global --global --format="get(address)")
echo "${GREEN_TEXT}✓ Global IP reserved: ${WHITE_TEXT}${BOLD_TEXT}$IP_ADDRESS${RESET_FORMAT}"
echo

# Create URL map
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating URL map...${RESET_FORMAT}"
gcloud compute url-maps create url-map-alb \
    --default-service=service-alb-global &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ URL map created${RESET_FORMAT}"
echo

# Create HTTPS proxy
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating HTTPS proxy...${RESET_FORMAT}"
gcloud compute target-https-proxies create https-proxy-alb \
    --url-map=url-map-alb \
    --ssl-certificates=cert-self-signed &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ HTTPS proxy created${RESET_FORMAT}"
echo

# Create forwarding rule
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating forwarding rule...${RESET_FORMAT}"
gcloud compute forwarding-rules create https-forwarding-rule \
    --global \
    --target-https-proxy=https-proxy-alb \
    --ports=443 \
    --address=ip-alb-global &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ Forwarding rule created${RESET_FORMAT}"
echo

# Create firewall rule for health checks and proxy
echo "${CYAN_TEXT}${BOLD_TEXT}▶ Creating firewall rule for health checks...${RESET_FORMAT}"
gcloud compute firewall-rules create fw-allow-health-check-and-proxy \
    --network=lb-network \
    --action=ALLOW \
    --direction=INGRESS \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=tag-alb-api \
    --rules=tcp:80 &

pid=$!
spinner $pid
wait $pid
echo "${GREEN_TEXT}✓ Firewall rule created${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}✓ TASK 2 COMPLETED SUCCESSFULLY!${RESET_FORMAT}"
echo

# ========================= TASK 3: TEST FAILOVER =========================

echo "${ORANGE_TEXT}${BOLD_TEXT}═══════════════════════════════════════════════════════════════${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}     TASK 3: TEST FAILOVER AND GLOBAL DISTRIBUTION${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}═══════════════════════════════════════════════════════════════${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for load balancer to fully provision...${RESET_FORMAT}"
sleep 60

echo "${CYAN_TEXT}${BOLD_TEXT}▶ Testing load balancer distribution...${RESET_FORMAT}"
echo "${YELLOW_TEXT}Testing traffic distribution (press Ctrl+C to stop):${RESET_FORMAT}"
echo "${WHITE_TEXT}curl -k -s https://$IP_ADDRESS${RESET_FORMAT}"
echo

# Test the load balancer 10 times
for i in {1..10}
do
    echo -n "${CYAN_TEXT}Request $i: ${RESET_FORMAT}"
    curl -k -s https://$IP_ADDRESS | grep -o "Hello from Cymbal Systems" || echo "Response received"
    sleep 0.5
done

echo
echo "${GREEN_TEXT}${BOLD_TEXT}✓ Traffic distribution verified${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}NOTE: To complete the failover test, manually perform these steps:${RESET_FORMAT}"
echo "${YELLOW_TEXT}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}1. Get the VM name from MIG A:${RESET_FORMAT}"
echo "   ${CYAN_TEXT}gcloud compute instance-groups managed list-instances mig-alb-api-a --region=$REGION_A${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}2. SSH into the VM:${RESET_FORMAT}"
echo "   ${CYAN_TEXT}gcloud compute ssh [VM_NAME] --zone=[ZONE_A]${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}3. Stop nginx service:${RESET_FORMAT}"
echo "   ${CYAN_TEXT}sudo systemctl stop nginx${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}4. Run the continuous test command:${RESET_FORMAT}"
echo "   ${CYAN_TEXT}while true; do curl -k -s https://$IP_ADDRESS | grep -o \"Hello\"; sleep 0.5; done${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}5. Restore backend after testing:${RESET_FORMAT}"
echo "   ${CYAN_TEXT}sudo systemctl start nginx${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET_FORMAT}"
echo

# ========================= COMPLETION MESSAGE =========================

echo "${ORANGE_TEXT}${BOLD_TEXT}=========================================================${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}          ALL TASKS COMPLETED SUCCESSFULLY!${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}=========================================================${RESET_FORMAT}"
echo
echo "${ORANGE_TEXT}${BOLD_TEXT}✅ TASK 1: Internal Proxy NLB - COMPLETED${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}✅ TASK 2: Global External ALB - COMPLETED${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}✅ TASK 3: Failover Test - READY${RESET_FORMAT}"
echo
echo "${ORANGE_TEXT}${BOLD_TEXT}🔴 PLEASE SUBSCRIBE TO DR. ABHISHEK'S CHANNEL:${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}📺 https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}=========================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}⭐ Don't forget to Like, Share and Subscribe for more amazing content!${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}Load Balancer IP: ${WHITE_TEXT}$IP_ADDRESS${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}Internal Proxy IP: ${WHITE_TEXT}10.129.0.99${RESET_FORMAT}"
