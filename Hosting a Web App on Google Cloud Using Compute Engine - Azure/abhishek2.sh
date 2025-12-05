#!/bin/bash

# Define text formatting variables
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

# Welcome Banner
echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}       DR. ABHISHEK'S MICROSERVICES OPTIMIZATION LAB P2     ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}optimize the microservices deployment with load balancing${RESET_FORMAT}"
echo "${WHITE_TEXT}and implements auto-scaling and CDN configurations${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}=== LOAD BALANCER CONFIGURATION ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}🌐 Getting load balancer IP address...${RESET_FORMAT}"
cd ~/monolith-to-microservices/react-app/
gcloud compute forwarding-rules list --global

echo "${YELLOW_TEXT}${BOLD_TEXT}📝 Updating frontend environment variables...${RESET_FORMAT}"
export EXTERNAL_IP_FANCY=$(gcloud compute forwarding-rules describe fancy-http-rule --global --format="value(IPAddress)")

cd monolith-to-microservices/react-app
cat > .env <<EOF
REACT_APP_ORDERS_URL=http://$EXTERNAL_IP_FANCY/api/orders
REACT_APP_PRODUCTS_URL=http://$EXTERNAL_IP_FANCY/api/products
EOF

echo "${GREEN_TEXT}${BOLD_TEXT}=== FRONTEND UPDATE ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}🔨 Rebuilding frontend application...${RESET_FORMAT}"
npm install && npm run-script build

echo "${YELLOW_TEXT}${BOLD_TEXT}📤 Uploading updated frontend files...${RESET_FORMAT}"
cd ~
rm -rf monolith-to-microservices/*/node_modules
gsutil -m cp -r monolith-to-microservices gs://fancy-store-$DEVSHELL_PROJECT_ID/

echo "${GREEN_TEXT}${BOLD_TEXT}=== INSTANCE GROUP UPDATES ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}🔄 Rolling update for frontend instance group...${RESET_FORMAT}"
gcloud compute instance-groups managed rolling-action replace fancy-fe-mig \
    --zone=$ZONE \
    --max-unavailable 100%

echo "${GREEN_TEXT}${BOLD_TEXT}=== AUTO-SCALING CONFIGURATION ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}📈 Configuring auto-scaling for frontend...${RESET_FORMAT}"
gcloud compute instance-groups managed set-autoscaling \
  fancy-fe-mig \
  --zone=$ZONE \
  --max-num-replicas 2 \
  --target-load-balancing-utilization 0.60

echo "${YELLOW_TEXT}${BOLD_TEXT}📈 Configuring auto-scaling for backend...${RESET_FORMAT}"
gcloud compute instance-groups managed set-autoscaling \
  fancy-be-mig \
  --zone=$ZONE \
  --max-num-replicas 2 \
  --target-load-balancing-utilization 0.60

echo "${GREEN_TEXT}${BOLD_TEXT}=== CDN ENABLEMENT ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}🚀 Enabling CDN for frontend service...${RESET_FORMAT}"
gcloud compute backend-services update fancy-fe-frontend \
    --enable-cdn --global

echo "${GREEN_TEXT}${BOLD_TEXT}=== INSTANCE UPGRADE ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}💪 Upgrading frontend machine type...${RESET_FORMAT}"
gcloud compute instances set-machine-type frontend \
  --zone=$ZONE \
  --machine-type e2-small

echo "${YELLOW_TEXT}${BOLD_TEXT}📋 Creating new instance template...${RESET_FORMAT}"
gcloud compute instance-templates create fancy-fe-new \
    --region=$REGION \
    --source-instance=frontend \
    --source-instance-zone=$ZONE

echo "${YELLOW_TEXT}${BOLD_TEXT}🔄 Rolling update with new template...${RESET_FORMAT}"
gcloud compute instance-groups managed rolling-action start-update fancy-fe-mig \
  --zone=$ZONE \
  --version template=fancy-fe-new

echo "${GREEN_TEXT}${BOLD_TEXT}=== FRONTEND CODE UPDATE ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}📝 Applying frontend code changes...${RESET_FORMAT}"
cd ~/monolith-to-microservices/react-app/src/pages/Home
mv index.js.new index.js

echo "${YELLOW_TEXT}${BOLD_TEXT}🔍 Verifying code changes...${RESET_FORMAT}"
cat ~/monolith-to-microservices/react-app/src/pages/Home/index.js

echo "${YELLOW_TEXT}${BOLD_TEXT}🔨 Rebuilding frontend with new changes...${RESET_FORMAT}"
cd ~/monolith-to-microservices/react-app
npm install && npm run-script build

echo "${YELLOW_TEXT}${BOLD_TEXT}📤 Uploading updated application...${RESET_FORMAT}"
cd ~
rm -rf monolith-to-microservices/*/node_modules
gsutil -m cp -r monolith-to-microservices gs://fancy-store-$DEVSHELL_PROJECT_ID/

echo "${YELLOW_TEXT}${BOLD_TEXT}🔄 Final rolling update...${RESET_FORMAT}"
gcloud compute instance-groups managed rolling-action replace fancy-fe-mig \
  --zone=$ZONE \
  --max-unavailable=100%

# Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}       MICROSERVICES OPTIMIZATION COMPLETED SUCCESSFULLY  ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💡 For more cloud tutorials and labs:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}Subscribe to Dr. Abhishek's YouTube Channel${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo
