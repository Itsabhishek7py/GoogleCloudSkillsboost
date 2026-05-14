#!/bin/bash

# Color definitions using tput
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

# Clear screen and display header
clear
echo "${YELLOW}${BOLD}============================================${RESET}"
echo "${YELLOW}${BOLD}   DR. ABHISHEK'S GKE MULTI-TENANCY LAB     ${RESET}"
echo "${YELLOW}${BOLD}============================================${RESET}"
echo "${BLUE}YouTube Channel: https://www.youtube.com/@drabhishek.5460${RESET}"
echo "${CYAN}Video Tutorials: https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo

# Get zone input from user
echo "${CYAN}${BOLD}Please enter your preferred zone (e.g., us-central1-a):${RESET}"
read ZONE
export ZONE
echo "${GREEN}✓ Zone set to: ${ZONE}${RESET}"
echo

# Start execution
echo "${YELLOW}${BOLD}Starting${RESET} ${GREEN}${BOLD}Execution${RESET}"
echo "${BLUE}For tutorial videos, visit: https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo

# Copy files from GCS
echo "${CYAN}${BOLD}Copying lab files from Google Cloud Storage...${RESET}"
gsutil -m cp -r gs://spls/gsp766/gke-qwiklab ~
echo "${GREEN}✓ Files copied successfully${RESET}"

# Change directory and configure cluster
cd ~/gke-qwiklab
echo "${CYAN}${BOLD}Configuring GKE cluster access...${RESET}"
gcloud config set compute/zone ${ZONE} && gcloud container clusters get-credentials multi-tenant-cluster
echo "${GREEN}✓ Cluster access configured${RESET}"

# Create namespaces
echo "${CYAN}${BOLD}Creating team namespaces...${RESET}"
kubectl create namespace team-a && \
kubectl create namespace team-b
echo "${GREEN}✓ Namespaces created${RESET}"

# Deploy pods in both namespaces
echo "${CYAN}${BOLD}Deploying initial pods...${RESET}"
kubectl run app-server --image=centos --namespace=team-a -- sleep infinity && \
kubectl run app-server --image=centos --namespace=team-b -- sleep infinity
echo "${GREEN}✓ Pods deployed${RESET}"

# Describe pod in team-a
echo "${CYAN}${BOLD}Verifying pod in team-a...${RESET}"
kubectl describe pod app-server --namespace=team-a
echo "${GREEN}✓ Pod verification complete${RESET}"

# Set context to team-a
echo "${CYAN}${BOLD}Setting context to team-a...${RESET}"
kubectl config set-context --current --namespace=team-a
echo "${GREEN}✓ Context set${RESET}"

# Add IAM policy binding
echo "${CYAN}${BOLD}Configuring IAM permissions...${RESET}"
gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
--member=serviceAccount:team-a-dev@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com  \
--role=roles/container.clusterViewer
echo "${GREEN}✓ IAM permissions configured${RESET}"

# Create roles and bindings
echo "${CYAN}${BOLD}Setting up RBAC...${RESET}"
kubectl create role pod-reader \
--resource=pods --verb=watch --verb=get --verb=list

kubectl create -f developer-role.yaml

kubectl create rolebinding team-a-developers \
--role=developer --user=team-a-dev@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
echo "${GREEN}✓ RBAC configured${RESET}"

# Create service account key
echo "${CYAN}${BOLD}Creating service account key...${RESET}"
gcloud iam service-accounts keys create /tmp/key.json --iam-account team-a-dev@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com
echo "${GREEN}✓ Service account key created${RESET}"

# Get cluster credentials again
echo "${CYAN}${BOLD}Refreshing cluster credentials...${RESET}"
gcloud container clusters get-credentials multi-tenant-cluster --zone ${ZONE} --project ${GOOGLE_CLOUD_PROJECT}
echo "${GREEN}✓ Credentials refreshed${RESET}"

# Resource quota setup
echo "${CYAN}${BOLD}Configuring resource quotas...${RESET}"
kubectl create quota test-quota \
--hard=count/pods=2,count/services.loadbalancers=1 --namespace=team-a

kubectl run app-server-2 --image=centos --namespace=team-a -- sleep infinity

kubectl run app-server-3 --image=centos --namespace=team-a -- sleep infinity

sleep 20

kubectl get quota test-quota --namespace=team-a -o yaml | \
  sed 's/count\/pods: "2"/count\/pods: "6"/' | \
  kubectl apply -f -

kubectl create -f cpu-mem-quota.yaml

kubectl create -f cpu-mem-demo-pod.yaml --namespace=team-a

kubectl describe quota cpu-mem-quota --namespace=team-a
echo "${GREEN}✓ Resource quotas configured${RESET}"

# Configure usage metering
echo "${CYAN}${BOLD}Setting up usage metering...${RESET}"
gcloud container clusters \
  update multi-tenant-cluster --zone ${ZONE} \
  --resource-usage-bigquery-dataset cluster_dataset

export GCP_BILLING_EXPORT_TABLE_FULL_PATH=${GOOGLE_CLOUD_PROJECT}.billing_dataset.gcp_billing_export_v1_xxxx
export USAGE_METERING_DATASET_ID=cluster_dataset
export COST_BREAKDOWN_TABLE_ID=usage_metering_cost_breakdown

export USAGE_METERING_QUERY_TEMPLATE=~/gke-qwiklab/usage_metering_query_template.sql
export USAGE_METERING_QUERY=cost_breakdown_query.sql
export USAGE_METERING_START_DATE=2020-10-26

sed \
-e "s/\${fullGCPBillingExportTableID}/$GCP_BILLING_EXPORT_TABLE_FULL_PATH/" \
-e "s/\${projectID}/$GOOGLE_CLOUD_PROJECT/" \
-e "s/\${datasetID}/$USAGE_METERING_DATASET_ID/" \
-e "s/\${startDate}/$USAGE_METERING_START_DATE/" \
"$USAGE_METERING_QUERY_TEMPLATE" \
> "$USAGE_METERING_QUERY"

bq query \
--project_id=$GOOGLE_CLOUD_PROJECT \
--use_legacy_sql=false \
--destination_table=$USAGE_METERING_DATASET_ID.$COST_BREAKDOWN_TABLE_ID \
--schedule='every 24 hours' \
--display_name="GKE Usage Metering Cost Breakdown Scheduled Query" \
--replace=true \
"$(cat $USAGE_METERING_QUERY)"
echo "${GREEN}✓ Usage metering configured${RESET}"

# Completion message
echo
echo "${RED}${BOLD}Congratulations${RESET} ${WHITE}${BOLD}for${RESET} ${GREEN}${BOLD}Completing the Lab!${RESET}"
echo
echo "${MAGENTA}${BOLD}For more cloud tutorials:${RESET}"
echo "${BLUE}${BOLD}Subscribe to Dr. Abhishek's YouTube Channel:${RESET}"
echo "${CYAN}https://www.youtube.com/@drabhishek.5460${RESET}"
echo "${BLUE}${BOLD}Video Tutorials:${RESET}"
echo "${CYAN}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
