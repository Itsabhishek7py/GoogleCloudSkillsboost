#!/bin/bash
## Changed by nov05, 2026-05-14  

# Define color variables
BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

clear


echo "${BLUE}${BOLD}====================================================================${RESET}"
echo "${BLUE}${BOLD}                  Dr. Abhishek Cloud Tutorials                     ${RESET}"
echo "${BLUE}${BOLD}====================================================================${RESET}"
echo
echo "${GREEN}${BOLD}Starting Monolith to Microservices Migration Lab${RESET}"
echo

# Initialize project settings
echo "${CYAN}${BOLD}➤ Configuring Project Settings${RESET}"
## ⚠️ nov05: Regin might be unset.
# export PROJECT_ID=$DEVSHELL_PROJECT_ID
# export ZONE=$(gcloud config get-value compute/zone)
# export REGION=${ZONE%-*}
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID \
  --format='value(projectNumber)')
export REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
gcloud config set compute/region $REGION

echo "${GREEN}✓ Project ID: $PROJECT_ID${RESET}"
echo "${GREEN}✓ Zone: $ZONE | Region: $REGION${RESET}"
echo

# Clone repository and setup
echo "${CYAN}${BOLD}➤ Setting Up Application${RESET}"
cd ~
git clone https://github.com/googlecodelabs/monolith-to-microservices.git
cd ~/monolith-to-microservices
./setup.sh
echo "${GREEN}✓ Application setup completed${RESET}"
echo

# Enable services and create cluster
echo "${CYAN}${BOLD}➤ Configuring Kubernetes Cluster${RESET}"
gcloud services enable container.googleapis.com --project=$PROJECT_ID
gcloud container clusters create fancy-cluster --project=$PROJECT_ID --zone=$ZONE --num-nodes 3 --machine-type=e2-standard-4
echo "${GREEN}✓ Kubernetes cluster created${RESET}"
echo

# Deploy monolith
echo "${CYAN}${BOLD}➤ Deploying Monolith Application${RESET}"
cd ~/monolith-to-microservices
./deploy-monolith.sh
sleep 30
MONOLITH_IP=$(kubectl get service monolith -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "${GREEN}✓ Monolith deployed at: http://$MONOLITH_IP${RESET}"
echo

# Build and deploy orders microservice
echo "${CYAN}${BOLD}➤ Deploying Orders Microservice${RESET}"
cd ~/monolith-to-microservices/microservices/src/orders
gcloud builds submit --tag gcr.io/${PROJECT_ID}/orders:1.0.0 .
kubectl create deployment orders --image=gcr.io/${PROJECT_ID}/orders:1.0.0
kubectl expose deployment orders --type=LoadBalancer --port 80 --target-port 8081
sleep 45
ORDERS_IP=$(kubectl get service orders -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "${GREEN}✓ Orders service deployed at: http://$ORDERS_IP${RESET}"
echo

# Update monolith configuration
echo "${CYAN}${BOLD}➤ Updating Monolith Configuration${RESET}"
cat > ~/monolith-to-microservices/.env.monolith <<EOF
REACT_APP_ORDERS_URL=http://$ORDERS_IP/api/orders
REACT_APP_PRODUCTS_URL=/service/products
EOF

cd ~/monolith-to-microservices/monolith
gcloud builds submit --tag gcr.io/${PROJECT_ID}/monolith:2.0.0 .
kubectl set image deployment/monolith monolith=gcr.io/${PROJECT_ID}/monolith:2.0.0
echo "${GREEN}✓ Monolith updated to version 2.0.0${RESET}"
echo

# Build and deploy products microservice
echo "${CYAN}${BOLD}➤ Deploying Products Microservice${RESET}"
cd ~/monolith-to-microservices/microservices/src/products
gcloud builds submit --tag gcr.io/${PROJECT_ID}/products:1.0.0 .
kubectl create deployment products --image=gcr.io/${PROJECT_ID}/products:1.0.0
kubectl expose deployment products --type=LoadBalancer --port 80 --target-port 8082
sleep 30
PRODUCTS_IP=$(kubectl get service products -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "${GREEN}✓ Products service deployed at: http://$PRODUCTS_IP${RESET}"
echo

# Final monolith update
echo "${CYAN}${BOLD}➤ Finalizing Microservices Integration${RESET}"
cat > ~/monolith-to-microservices/.env.monolith <<EOF
REACT_APP_ORDERS_URL=http://$ORDERS_IP/api/orders
REACT_APP_PRODUCTS_URL=http://$PRODUCTS_IP/api/products
EOF

cd ~/monolith-to-microservices/monolith
gcloud builds submit --tag gcr.io/${PROJECT_ID}/monolith:3.0.0 .
kubectl set image deployment/monolith monolith=gcr.io/${PROJECT_ID}/monolith:3.0.0
echo "${GREEN}✓ Monolith updated to version 3.0.0${RESET}"
echo

# Deploy frontend
echo "${CYAN}${BOLD}➤ Deploying Frontend Service${RESET}"
cd ~/monolith-to-microservices/react-app
cp .env.monolith .env
npm run build

cd ~/monolith-to-microservices/microservices/src/frontend
gcloud builds submit --tag gcr.io/${PROJECT_ID}/frontend:1.0.0 .
kubectl create deployment frontend --image=gcr.io/${PROJECT_ID}/frontend:1.0.0
kubectl expose deployment frontend --type=LoadBalancer --port 80 --target-port 8080
echo "${GREEN}✓ Frontend service deployed${RESET}"
echo

# Completion Message
echo "${BLUE}${BOLD}====================================================================${RESET}"
echo "${BLUE}${BOLD}               LAB COMPLETED SUCCESSFULLY                          ${RESET}"
echo "${BLUE}${BOLD}====================================================================${RESET}"
echo
echo "${GREEN}${BOLD}Thank you for using Dr. Abhishek Cloud Tutorials!${RESET}"
echo
echo "${YELLOW}For more cloud tutorials and labs, visit:${RESET}"
echo "${CYAN}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
