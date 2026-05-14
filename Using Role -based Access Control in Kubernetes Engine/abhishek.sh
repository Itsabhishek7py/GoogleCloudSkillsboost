#!/bin/bash

# Define color variables
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BG_BLACK=$(tput setab 0)
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)
BG_MAGENTA=$(tput setab 5)
BG_CYAN=$(tput setab 6)
BG_WHITE=$(tput setab 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

echo "${CYAN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${CYAN}${BOLD}       Welcome to Dr. Abhishek Cloud Tutorials!           ${RESET}"
echo "${CYAN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}${BOLD}Please like, share and subscribe to the channel for more:${RESET}"
echo "${BLUE}${BOLD}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo

# Fetch zone and region
echo "${YELLOW}${BOLD}Fetching GCP configuration...${RESET}"
ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
PROJECT_ID=$(gcloud config get-value project)

echo "${GREEN}${BOLD}Current Configuration:${RESET}"
echo "Project ID: ${BLUE}$PROJECT_ID${RESET}"
echo "Region: ${BLUE}$REGION${RESET}"
echo "Zone: ${BLUE}$ZONE${RESET}"
echo

# Set GCP region and zone
echo "${YELLOW}${BOLD}Setting GCP configuration...${RESET}"
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# Define instance and cluster variables
INSTANCE_NAME="gke-tutorial-admin"
CLUSTER_NAME="rbac-demo-cluster"
RBAC_MANIFEST_PATH="./manifests/rbac.yaml"

# Task 1: Configure admin instance
echo "${MAGENTA}${BOLD}Starting Task 1: Configuring admin instance...${RESET}"
gcloud compute ssh $INSTANCE_NAME --zone $ZONE --quiet --command "
  sudo apt-get update &&
  sudo apt-get install -y google-cloud-sdk-gke-gcloud-auth-plugin &&
  echo 'source ~/.bashrc' >> ~/.bash_profile &&
  source ~/.bash_profile &&
  gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE &&
  kubectl apply -f $RBAC_MANIFEST_PATH
"
echo "${GREEN}${BOLD}Task 1 completed successfully!${RESET}"
echo

# Task 2: Configure owner instance
INSTANCE_NAME2="gke-tutorial-owner"
echo "${MAGENTA}${BOLD}Starting Task 2: Configuring owner instance...${RESET}"
gcloud compute ssh $INSTANCE_NAME2 --zone $ZONE --command '
  sudo apt-get install -y google-cloud-sdk-gke-gcloud-auth-plugin &&
  echo "export USE_GKE_GCLOUD_AUTH_PLUGIN=True" >> ~/.bashrc &&
  source ~/.bashrc &&
  gcloud container clusters get-credentials '"$CLUSTER_NAME"' --zone '"$ZONE"' &&
  kubectl create -n dev -f ./manifests/hello-server.yaml &&
  kubectl create -n prod -f ./manifests/hello-server.yaml &&
  kubectl create -n test -f ./manifests/hello-server.yaml
'
echo "${GREEN}${BOLD}Task 2 completed successfully!${RESET}"
echo

# Task 3: Pod labeler configuration
echo "${MAGENTA}${BOLD}Starting Task 3: Pod labeler configuration...${RESET}"
gcloud compute ssh $INSTANCE_NAME --zone $ZONE --command "kubectl apply -f manifests/pod-labeler.yaml"

gcloud compute ssh "$INSTANCE_NAME" --zone "$ZONE" --command '
  kubectl get pod -o yaml -l app=pod-labeler &&
  kubectl apply -f manifests/pod-labeler-fix-1.yaml &&
  kubectl get deployment pod-labeler -o yaml &&
  kubectl get pods -l app=pod-labeler &&
  kubectl logs -l app=pod-labeler &&
  kubectl get rolebinding pod-labeler -o yaml &&
  kubectl get role pod-labeler -o yaml &&
  kubectl get rolebinding pod-labeler -oyaml &&
  kubectl get role pod-labeler -oyaml &&
  kubectl apply -f manifests/pod-labeler-fix-2.yaml
'

gcloud compute ssh "$INSTANCE_NAME" --zone "$ZONE" --command '
  kubectl get rolebinding pod-labeler -oyaml &&
  kubectl get role pod-labeler -oyaml &&
  kubectl apply -f manifests/pod-labeler-fix-2.yaml
'
echo "${GREEN}${BOLD}Task 3 completed successfully!${RESET}"
echo

echo "${CYAN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${CYAN}${BOLD}           GKE RBAC Lab Completed Successfully!           ${RESET}"
echo "${CYAN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${GREEN}${BOLD}Thanks for using this lab! Don't forget to:${RESET}"
echo "${YELLOW}${BOLD}👍 Like   🔄 Share   🔔 Subscribe${RESET}"
echo "${BLUE}${BOLD}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo
