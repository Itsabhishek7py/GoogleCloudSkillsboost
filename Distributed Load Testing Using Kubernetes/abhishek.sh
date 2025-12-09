#!/bin/bash

# Enhanced Color Definitions
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

clear

# Display Header
echo "${CYAN}${BOLD}================================================${RESET}"
echo "${CYAN}${BOLD}  DR. ABHISHEK'S DISTRIBUTED LOAD TESTING LAB  ${RESET}"
echo "${CYAN}${BOLD}================================================${RESET}"
echo "${BLUE}YouTube Channel: https://www.youtube.com/@drabhishek.5460${RESET}"
echo "${MAGENTA}Video Tutorials: https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo

# Get User Input
echo "${YELLOW}${BOLD}Step 1: Configuration Setup${RESET}"
read -p "Enter your preferred ZONE (e.g., us-central1-a): " ZONE

if [ -z "$ZONE" ]; then
  echo "${RED}Error: Zone cannot be empty${RESET}"
  exit 1
fi

# Set Project and Region
PROJECT=$(gcloud config get-value project)
REGION="${ZONE%-*}"
CLUSTER="gke-load-test"
TARGET="${PROJECT}.appspot.com"

echo "${GREEN}✓ Configuration:${RESET}"
echo "  Project: ${PROJECT}"
echo "  Region: ${REGION}"
echo "  Zone: ${ZONE}"
echo

# Set GCP Configuration
echo "${YELLOW}${BOLD}Step 2: Setting Up GCP Environment${RESET}"
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE
echo "${GREEN}✓ GCP configuration updated${RESET}"
echo

# Download Resources
echo "${YELLOW}${BOLD}Step 3: Downloading Required Resources${RESET}"
if [ -d "distributed-load-testing-using-kubernetes" ]; then
  echo "${YELLOW}✓ Directory already exists, skipping download${RESET}"
else
  gsutil -m cp -r gs://spls/gsp182/distributed-load-testing-using-kubernetes .
fi
echo "${GREEN}✓ Resources downloaded${RESET}"
echo

# Configure Web Application
echo "${YELLOW}${BOLD}Step 4: Configuring Sample Web Application${RESET}"
cd distributed-load-testing-using-kubernetes/sample-webapp/
sed -i "s/python37/python312/g" app.yaml
cd ..
echo "${GREEN}✓ Web application configured${RESET}"
echo

# Build Docker Image
echo "${YELLOW}${BOLD}Step 5: Building Locust Docker Image${RESET}"
gcloud builds submit --tag gcr.io/$PROJECT/locust-tasks:latest docker-image/.
echo "${GREEN}✓ Docker image built and pushed${RESET}"
echo

# Deploy Web Application
echo "${YELLOW}${BOLD}Step 6: Deploying Web Application${RESET}"
gcloud app create --region=$REGION || echo "${YELLOW}App already exists, continuing...${RESET}"
gcloud app deploy sample-webapp/app.yaml --quiet
echo "${GREEN}✓ Web application deployed${RESET}"
echo

# Create GKE Cluster
echo "${YELLOW}${BOLD}Step 7: Creating GKE Cluster${RESET}"
gcloud container clusters create $CLUSTER \
  --zone $ZONE \
  --num-nodes=5 \
  --machine-type=e2-standard-4
echo "${GREEN}✓ GKE cluster created${RESET}"
echo

# Configure Locust Files
echo "${YELLOW}${BOLD}Step 8: Configuring Load Testing Components${RESET}"
sed -i -e "s/\[TARGET_HOST\]/$TARGET/g" kubernetes-config/locust-master-controller.yaml
sed -i -e "s/\[TARGET_HOST\]/$TARGET/g" kubernetes-config/locust-worker-controller.yaml
sed -i -e "s/\[PROJECT_ID\]/$PROJECT/g" kubernetes-config/locust-master-controller.yaml
sed -i -e "s/\[PROJECT_ID\]/$PROJECT/g" kubernetes-config/locust-worker-controller.yaml
echo "${GREEN}✓ Configuration files updated${RESET}"
echo

# Deploy Locust Master
echo "${YELLOW}${BOLD}Step 9: Deploying Locust Master${RESET}"
kubectl apply -f kubernetes-config/locust-master-controller.yaml
kubectl apply -f kubernetes-config/locust-master-service.yaml
echo "${GREEN}✓ Locust master deployed${RESET}"
echo

# Get Master Service Details
echo "${YELLOW}${BOLD}Step 10: Locust Master Service Details${RESET}"
kubectl get svc locust-master
echo
echo "${GREEN}✓ You can access the Locust web interface at the EXTERNAL-IP above on port 8089${RESET}"
echo

# Deploy Locust Workers
echo "${YELLOW}${BOLD}Step 11: Deploying Locust Workers${RESET}"
kubectl apply -f kubernetes-config/locust-worker-controller.yaml
echo "${GREEN}✓ Initial workers deployed${RESET}"
echo

# Scale Workers
echo "${YELLOW}${BOLD}Step 12: Scaling Workers${RESET}"
kubectl scale deployment/locust-worker --replicas=20
echo "${GREEN}✓ Scaled to 20 workers${RESET}"
echo
echo "${YELLOW}You can monitor worker status with: kubectl get pods -l app=locust-worker${RESET}"
echo

# Completion Message
echo "${MAGENTA}${BOLD}================================================${RESET}"
echo "${MAGENTA}${BOLD}  LOAD TESTING ENVIRONMENT READY!             ${RESET}"
echo "${MAGENTA}${BOLD}================================================${RESET}"
echo
echo "${GREEN}${BOLD}Next Steps:${RESET}"
echo "1. Access the Locust web interface using the EXTERNAL-IP"
echo "2. Configure your load test parameters"
echo "3. Start the test and monitor results"
echo
echo "${CYAN}${BOLD}To clean up resources when done:${RESET}"
echo "1. Delete the GKE cluster: gcloud container clusters delete $CLUSTER --zone $ZONE"
echo "2. Delete the App Engine application: gcloud app services delete default"
echo
echo "${BLUE}${BOLD}For more performance testing tutorials:${RESET}"
echo "${WHITE}Subscribe to Dr. Abhishek's YouTube Channel:${RESET}"
echo "${CYAN}https://www.youtube.com/@drabhishek.5460${RESET}"
echo "${WHITE}Video Tutorials:${RESET}"
echo "${CYAN}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
