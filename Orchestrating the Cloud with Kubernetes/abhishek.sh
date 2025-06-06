#!/bin/bash

# Bright Foreground Colors
BRIGHT_BLACK_TEXT=$'\033[0;90m'
BRIGHT_RED_TEXT=$'\033[0;91m'
BRIGHT_GREEN_TEXT=$'\033[0;92m'
BRIGHT_YELLOW_TEXT=$'\033[0;93m'
BRIGHT_BLUE_TEXT=$'\033[0;94m'
BRIGHT_MAGENTA_TEXT=$'\033[0;95m'
BRIGHT_CYAN_TEXT=$'\033[0;96m'
BRIGHT_WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'

# Spinner function
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Start of the script
echo
echo "${BRIGHT_CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${BRIGHT_CYAN_TEXT}${BOLD_TEXT}        Welcome to Dr. Abhishek's Cloud Tutorials         ${RESET_FORMAT}"
echo "${BRIGHT_CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo

# User input for ZONE
echo "${BRIGHT_YELLOW_TEXT}${BOLD_TEXT}Enter ZONE:${RESET_FORMAT}"
read -p "Zone: " ZONE
export ZONE

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Setting compute zone to $ZONE...${RESET_FORMAT}"
(gcloud config set compute/zone $ZONE) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Creating a GKE cluster named 'io'...${RESET_FORMAT}"
(gcloud container clusters create io) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Copying files from Google Cloud Storage...${RESET_FORMAT}"
(gsutil cp -r gs://spls/gsp021/* .) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Changing directory to 'orchestrate-with-kubernetes/kubernetes'...${RESET_FORMAT}"
(cd orchestrate-with-kubernetes/kubernetes) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Creating an NGINX deployment...${RESET_FORMAT}"
(kubectl create deployment nginx --image=nginx:1.10.0) & spinner

echo
echo "${BRIGHT_YELLOW_TEXT}${BOLD_TEXT}Waiting for 20 seconds...${RESET_FORMAT}"
(sleep 20) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Exposing the NGINX deployment on port 80...${RESET_FORMAT}"
(kubectl expose deployment nginx --port 80 --type LoadBalancer) & spinner

echo
echo "${BRIGHT_YELLOW_TEXT}${BOLD_TEXT}Waiting for 80 seconds...${RESET_FORMAT}"
(sleep 80) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Fetching service details...${RESET_FORMAT}"
(kubectl get services) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Changing back to 'orchestrate-with-kubernetes/kubernetes' directory...${RESET_FORMAT}"
(cd ~/orchestrate-with-kubernetes/kubernetes) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Creating a monolith pod...${RESET_FORMAT}"
(kubectl create -f pods/monolith.yaml) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Creating TLS secrets and NGINX proxy configuration...${RESET_FORMAT}"
(kubectl create secret generic tls-certs --from-file tls/
kubectl create configmap nginx-proxy-conf --from-file nginx/proxy.conf) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Creating a secure monolith pod...${RESET_FORMAT}"
(kubectl create -f pods/secure-monolith.yaml) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Creating a monolith service...${RESET_FORMAT}"
(kubectl create -f services/monolith.yaml) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Creating a firewall rule to allow traffic on port 31000...${RESET_FORMAT}"
(gcloud compute firewall-rules create allow-monolith-nodeport \
  --allow=tcp:31000) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Labeling the secure-monolith pod...${RESET_FORMAT}"
(kubectl label pods secure-monolith 'secure=enabled'
kubectl get pods secure-monolith --show-labels) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Creating the auth deployment and service...${RESET_FORMAT}"
(kubectl create -f deployments/auth.yaml
kubectl create -f services/auth.yaml) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Creating the hello deployment and service...${RESET_FORMAT}"
(kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml) & spinner

echo
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}Creating the frontend configuration and deployment...${RESET_FORMAT}"
(kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml) & spinner

echo

# Completion message
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}              Lab Completed Successfully!               ${RESET_FORMAT}"
echo "${BRIGHT_GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo -e "${BRIGHT_RED_TEXT}${BOLD_TEXT}Subscribe to my Channel:${RESET_FORMAT} ${BRIGHT_BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo
