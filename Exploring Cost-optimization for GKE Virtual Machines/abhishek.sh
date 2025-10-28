#!/bin/bash

# Define color variables for better output
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

# Welcome Banner for Dr. Abhishek Cloud Tutorials
echo
echo "${BLUE_TEXT}${BOLD_TEXT}╔══════════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}║                                                              ║${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}║    🎯 WELCOME TO DR. ABHISHEK CLOUD TUTORIALS 🎯           ║${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}║                                                              ║${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}║           Google Kubernetes Engine Management Lab            ║${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}║                                                              ║${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}╚══════════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}              GKE CLUSTER MANAGEMENT & SCALING                  ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

# Step 1: Fetch zone and region
echo "${BOLD}${YELLOW}Step 1: Fetching project configuration...${RESET}"
ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
PROJECT_ID=$(gcloud config get-value project)

echo "${GREEN_TEXT}✓ Zone: $ZONE${RESET_FORMAT}"
echo "${GREEN_TEXT}✓ Region: $REGION${RESET_FORMAT}"
echo "${GREEN_TEXT}✓ Project ID: $PROJECT_ID${RESET_FORMAT}"
echo

# Step 2: Get cluster credentials
echo "${BOLD}${CYAN}Step 2: Configuring cluster credentials...${RESET}"
gcloud container clusters get-credentials hello-demo-cluster --zone $ZONE
echo "${GREEN_TEXT}✓ Cluster credentials configured successfully${RESET_FORMAT}"
echo

# Step 3: Scale deployment
echo "${BOLD}${GREEN}Step 3: Scaling hello-server deployment...${RESET}"
kubectl scale deployment hello-server --replicas=2
echo "${GREEN_TEXT}✓ Deployment scaled to 2 replicas${RESET_FORMAT}"
echo

# Step 4: Resize cluster nodes
echo "${BOLD}${BLUE}Step 4: Resizing cluster node pool...${RESET}"
gcloud container clusters resize hello-demo-cluster --node-pool my-node-pool \
    --num-nodes 3 --zone $ZONE --quiet
echo "${GREEN_TEXT}✓ Node pool resized to 3 nodes${RESET_FORMAT}"
echo

# Step 5: Create larger node pool
echo "${BOLD}${MAGENTA}Step 5: Creating larger node pool...${RESET}"
gcloud container node-pools create larger-pool \
  --cluster=hello-demo-cluster \
  --machine-type=e2-standard-2 \
  --num-nodes=1 \
  --zone=$ZONE
echo "${GREEN_TEXT}✓ Larger node pool created (e2-standard-2)${RESET_FORMAT}"
echo

# Step 6: Cordon old nodes
echo "${BOLD}${RED}Step 6: Cordoning old node pool nodes...${RESET}"
for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=my-node-pool -o=name); do
  kubectl cordon "$node";
  echo "${YELLOW}  Cordoned: $node${RESET_FORMAT}"
done
echo "${GREEN_TEXT}✓ All old nodes cordoned${RESET_FORMAT}"
echo

# Step 7: Drain old nodes
echo "${BOLD}${YELLOW}Step 7: Draining old node pool nodes...${RESET}"
for node in $(kubectl get nodes -l cloud.google.com/gke-nodepool=my-node-pool -o=name); do
  kubectl drain --force --ignore-daemonsets --delete-emptydir-data --grace-period=10 "$node";
  echo "${YELLOW}  Drained: $node${RESET_FORMAT}"
done
echo "${GREEN_TEXT}✓ All old nodes drained${RESET_FORMAT}"
echo

# Step 8: Delete old node pool
echo "${BOLD}${CYAN}Step 8: Deleting old node pool...${RESET}"
gcloud container node-pools delete my-node-pool --cluster hello-demo-cluster --zone $ZONE --quiet 
echo "${GREEN_TEXT}✓ Old node pool deleted${RESET_FORMAT}"
echo

# Step 9: Create regional cluster
echo "${BOLD}${GREEN}Step 9: Creating regional cluster...${RESET}"
gcloud container clusters create regional-demo --region=$REGION --num-nodes=1
echo "${GREEN_TEXT}✓ Regional cluster created${RESET_FORMAT}"
echo

# Step 10: Create first pod
echo "${BOLD}${BLUE}Step 10: Deploying pod-1 with network multitool...${RESET}"
cat << EOF > pod-1.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-1
  labels:
    security: demo
spec:
  containers:
  - name: container-1
    image: wbitt/network-multitool
EOF

kubectl apply -f pod-1.yaml
echo "${GREEN_TEXT}✓ pod-1 deployed successfully${RESET_FORMAT}"
echo

# Step 11: Create second pod with anti-affinity
echo "${BOLD}${MAGENTA}Step 11: Deploying pod-2 with anti-affinity rules...${RESET}"
cat << EOF > pod-2.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-2
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: security
            operator: In
            values:
            - demo
        topologyKey: "kubernetes.io/hostname"
  containers:
  - name: container-2
    image: us-docker.pkg.dev/google-samples/containers/gke/hello-app:1.0
EOF

kubectl apply -f pod-2.yaml
echo "${GREEN_TEXT}✓ pod-2 deployed with anti-affinity rules${RESET_FORMAT}"
echo

# Step 12: Verification
echo "${BOLD}${CYAN}Step 12: Verifying deployments...${RESET}"
echo "${YELLOW}Current pods:${RESET_FORMAT}"
kubectl get pods -o wide
echo
echo "${YELLOW}Current nodes:${RESET_FORMAT}"
kubectl get nodes
echo

# Cleanup temporary files
echo "${BOLD}${RED}Cleaning up temporary files...${RESET}"
rm -f pod-1.yaml pod-2.yaml
echo "${GREEN_TEXT}✓ Temporary files cleaned up${RESET_FORMAT}"
echo

# Final Completion Message
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}╔══════════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║                                                              ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║         🎉 GKE MANAGEMENT LAB COMPLETED! 🎉                 ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║                                                              ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║    Cluster Scaling, Node Pool Migration & Pod Deployment    ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║                                                              ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}╚══════════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}Lab Summary:${RESET_FORMAT}"
echo "${GREEN_TEXT}✓ Scaled deployment to 2 replicas${RESET_FORMAT}"
echo "${GREEN_TEXT}✓ Resized node pool to 3 nodes${RESET_FORMAT}"
echo "${GREEN_TEXT}✓ Created larger node pool (e2-standard-2)${RESET_FORMAT}"
echo "${GREEN_TEXT}✓ Migrated from old node pool to new one${RESET_FORMAT}"
echo "${GREEN_TEXT}✓ Created regional cluster${RESET_FORMAT}"
echo "${GREEN_TEXT}✓ Deployed pods with anti-affinity rules${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}For more Kubernetes and cloud engineering tutorials:${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}   📚 Visit: https://www.youtube.com/@drabhishek.5460/${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Like, Share, and Subscribe for more GKE and cloud content! 🚀${RESET_FORMAT}"
echo
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}              EXECUTION COMPLETED!                    ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo
