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

# Header Section
echo "${BG_MAGENTA}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BG_MAGENTA}${BOLD}        WELCOME TO DR ABHISHEK CLOUD TUTORIAL           ${RESET}"
echo "${BG_MAGENTA}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${CYAN}${BOLD}          Expert Tutorial by Dr. Abhishek              ${RESET}"
echo "${YELLOW}For more GKE tutorials, visit: https://www.youtube.com/@drabhishek.5460${RESET}"
echo
echo "${BLUE}${BOLD}⚡ Initializing GKE Cluster Setup...${RESET}"
echo

# User Input Section
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ CONFIGURATION PARAMETERS ▬▬▬▬▬▬▬▬▬${RESET}"
read -p "${YELLOW}${BOLD}Enter CLUSTER_NAME (e.g., monitoring-cluster): ${RESET}" CLUSTER_NAME
read -p "${YELLOW}${BOLD}Enter ZONE (e.g., us-central1-a): ${RESET}" ZONE
read -p "${YELLOW}${BOLD}Enter NAMESPACE (e.g., gmp-test): ${RESET}" NAMESPACE
read -p "${YELLOW}${BOLD}Enter REPO_NAME (e.g., hello-repo): ${RESET}" REPO_NAME
read -p "${YELLOW}${BOLD}Enter INTERVAL for monitoring (e.g., 30s): ${RESET}" INTERVAL
read -p "${YELLOW}${BOLD}Enter SERVICE_NAME (e.g., hello-service): ${RESET}" SERVICE_NAME

# Export all variables
export CLUSTER_NAME ZONE NAMESPACE REPO_NAME INTERVAL SERVICE_NAME
export REGION="${ZONE%-*}"
export PROJECT_ID=$(gcloud config get-value project)

echo
echo "${CYAN}${BOLD}Configuration Summary:${RESET}"
echo "${WHITE}Cluster Name: ${BOLD}$CLUSTER_NAME${RESET}"
echo "${WHITE}Zone: ${BOLD}$ZONE${RESET}"
echo "${WHITE}Region: ${BOLD}$REGION${RESET}"
echo "${WHITE}Namespace: ${BOLD}$NAMESPACE${RESET}"
echo "${WHITE}Repository: ${BOLD}$REPO_NAME${RESET}"
echo "${WHITE}Monitoring Interval: ${BOLD}$INTERVAL${RESET}"
echo "${WHITE}Service Name: ${BOLD}$SERVICE_NAME${RESET}"
echo

# Cluster Creation
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ CLUSTER CREATION ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Setting compute zone...${RESET}"
gcloud config set compute/zone $ZONE

echo "${YELLOW}Creating GKE cluster with autoscaling...${RESET}"
gcloud container clusters create $CLUSTER_NAME \
  --release-channel regular \
  --cluster-version latest \
  --num-nodes 3 \
  --min-nodes 2 \
  --max-nodes 6 \
  --enable-autoscaling \
  --no-enable-ip-alias

echo "${YELLOW}Enabling Managed Prometheus...${RESET}"
gcloud container clusters update $CLUSTER_NAME \
  --enable-managed-prometheus \
  --zone $ZONE
echo "${GREEN}✅ Cluster created and configured successfully!${RESET}"
echo

# Namespace Setup
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ NAMESPACE SETUP ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Creating namespace...${RESET}"
kubectl create ns $NAMESPACE
echo "${GREEN}✅ Namespace $NAMESPACE created!${RESET}"
echo

# Prometheus Application Deployment
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ PROMETHEUS SETUP ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Deploying Prometheus test application...${RESET}"
cat > prometheus-app.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus-test
  labels:
    app: prometheus-test
spec:
  selector:
    matchLabels:
      app: prometheus-test
  replicas: 3
  template:
    metadata:
      labels:
        app: prometheus-test
    spec:
      nodeSelector:
        kubernetes.io/os: linux
        kubernetes.io/arch: amd64
      containers:
      - image: nilebox/prometheus-example-app:latest
        name: prometheus-test
        ports:
        - name: metrics
          containerPort: 1234
        command:
        - "/main"
        - "--process-metrics"
        - "--go-metrics"
EOF

kubectl -n $NAMESPACE apply -f prometheus-app.yaml
echo "${GREEN}✅ Prometheus test application deployed!${RESET}"

echo "${YELLOW}Configuring Pod Monitoring...${RESET}"
cat > pod-monitoring.yaml <<EOF
apiVersion: monitoring.googleapis.com/v1alpha1
kind: PodMonitoring
metadata:
  name: prometheus-test
  labels:
    app.kubernetes.io/name: prometheus-test
spec:
  selector:
    matchLabels:
      app: prometheus-test
  endpoints:
  - port: metrics
    interval: $INTERVAL
EOF

kubectl -n $NAMESPACE apply -f pod-monitoring.yaml
echo "${GREEN}✅ Pod monitoring configured with ${INTERVAL} interval!${RESET}"
echo

# Hello Application Deployment
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ HELLO APPLICATION DEPLOYMENT ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Setting up hello application...${RESET}"
gsutil cp -r gs://spls/gsp510/hello-app/ .
cd ~/hello-app

echo "${YELLOW}Deploying initial version...${RESET}"
kubectl -n $NAMESPACE apply -f manifests/helloweb-deployment.yaml
echo "${GREEN}✅ Initial deployment complete!${RESET}"

echo "${YELLOW}Updating deployment configuration...${RESET}"
cat > manifests/helloweb-deployment.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: helloweb
  labels:
    app: hello
spec:
  selector:
    matchLabels:
      app: hello
      tier: web
  template:
    metadata:
      labels:
        app: hello
        tier: web
    spec:
      containers:
      - name: hello-app
        image: us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 200m
EOF

kubectl delete deployments helloweb -n $NAMESPACE
kubectl -n $NAMESPACE apply -f manifests/helloweb-deployment.yaml
echo "${GREEN}✅ Deployment updated!${RESET}"
echo

# Application Update
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ APPLICATION UPDATE ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Building and pushing new version...${RESET}"
cat > main.go <<EOF
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	// register hello function to handle all requests
	mux := http.NewServeMux()
	mux.HandleFunc("/", hello)

	// use PORT environment variable, or default to 8080
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	// start the web server on port and accept requests
	log.Printf("Server listening on port %s", port)
	log.Fatal(http.ListenAndServe(":"+port, mux))
}

// hello responds to the request with a plain-text "Hello, world" message.
func hello(w http.ResponseWriter, r *http.Request) {
	log.Printf("Serving request: %s", r.URL.Path)
	host, _ := os.Hostname()
	fmt.Fprintf(w, "Hello, world!\n")
	fmt.Fprintf(w, "Version: 2.0.0\n")
	fmt.Fprintf(w, "Hostname: %s\n", host)
}
EOF

gcloud auth configure-docker $REGION-docker.pkg.dev --quiet
docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/hello-app:v2 .
docker push $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/hello-app:v2

echo "${YELLOW}Updating deployment with new image...${RESET}"
kubectl set image deployment/helloweb -n $NAMESPACE hello-app=$REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/hello-app:v2

echo "${YELLOW}Exposing service...${RESET}"
kubectl expose deployment helloweb -n $NAMESPACE --name=$SERVICE_NAME --type=LoadBalancer --port 8080 --target-port 8080
echo "${GREEN}✅ Application updated and service exposed!${RESET}"
echo

# Monitoring Configuration
echo "${GREEN}${BOLD}▬▬▬▬▬▬▬▬▬ MONITORING CONFIGURATION ▬▬▬▬▬▬▬▬▬${RESET}"
echo "${YELLOW}Creating logging metric...${RESET}"
gcloud logging metrics create pod-image-errors \
  --description="Pod image errors monitoring" \
  --log-filter="resource.type=\"k8s_pod\" severity=WARNING"

echo "${YELLOW}Creating alert policy...${RESET}"
cat > awesome.json <<EOF_END
{
  "displayName": "Pod Error Alert",
  "userLabels": {},
  "conditions": [
    {
      "displayName": "Kubernetes Pod - logging/user/pod-image-errors",
      "conditionThreshold": {
        "filter": "resource.type = \"k8s_pod\" AND metric.type = \"logging.googleapis.com/user/pod-image-errors\"",
        "aggregations": [
          {
            "alignmentPeriod": "600s",
            "crossSeriesReducer": "REDUCE_SUM",
            "perSeriesAligner": "ALIGN_COUNT"
          }
        ],
        "comparison": "COMPARISON_GT",
        "duration": "0s",
        "trigger": {
          "count": 1
        },
        "thresholdValue": 0
      }
    }
  ],
  "alertStrategy": {
    "autoClose": "604800s"
  },
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": []
}
EOF_END

gcloud alpha monitoring policies create --policy-from-file="awesome.json"
echo "${GREEN}✅ Monitoring and alerting configured!${RESET}"
echo

# Completion Message
echo "${BG_GREEN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
echo "${BG_GREEN}${BOLD}         LAB COMPLETE!             ${RESET}"
echo "${BG_GREEN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo
echo "${RED}${BOLD}🙏 Thank you for following Dr. Abhishek's tutorial!${RESET}"
echo "${YELLOW}${BOLD}📺 Subscribe for more GKE content:${RESET}"
echo "${BLUE}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
echo "${MAGENTA}${BOLD}🚀 Happy monitoring with GKE and Prometheus!${RESET}"
