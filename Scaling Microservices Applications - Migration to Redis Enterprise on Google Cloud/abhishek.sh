#!/bin/bash

# Welcome message
echo "=================================================="
echo "Welcome to Dr. Abhishek Cloud Tutorial!"
echo "Subscribe to the channel: https://www.youtube.com/@drabhishek.5460/videos"
echo "=================================================="
echo ""

# Set region and zone
echo "Setting up region and zone..."
export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

echo "Region: $REGION"
echo "Zone: $ZONE"
echo ""

# Get project details
echo "Getting project information..."
PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

echo "Project ID: $PROJECT_ID"
echo "Project Number: $PROJECT_NUMBER"
echo ""

# Clone repository and setup Terraform
echo "Cloning repository and setting up Terraform..."
git clone https://github.com/Redislabs-Solution-Architects/gcp-microservices-demo-qwiklabs.git
pushd gcp-microservices-demo-qwiklabs

cat <<EOF > terraform.tfvars
gcp_project_id = "$(gcloud config list project --format='value(core.project)')"
gcp_region = "$REGION"
EOF

terraform init

echo "Applying Terraform configuration..."
terraform apply -auto-approve

# Export Redis endpoints
export REDIS_DEST=$(terraform output db_private_endpoint | tr -d '"')
export REDIS_DEST_PASS=$(terraform output db_password | tr -d '"')
export REDIS_ENDPOINT="${REDIS_DEST},user=default,password=${REDIS_DEST_PASS}"

echo "Redis Destination: $REDIS_DEST"
echo ""

# Configure kubectl
echo "Configuring kubectl..."
gcloud container clusters get-credentials \
$(terraform output -raw gke_cluster_name) \
--region $(terraform output -raw region)

# Get external frontend service
echo "Frontend external service:"
kubectl get service frontend-external -n redis

echo ""
echo "=================================================="
echo "TASK 2: Migrating to Redis Cloud"
echo "=================================================="

# Set namespace
kubectl config set-context --current --namespace=redis

echo "Current cartservice environment:"
kubectl get deployment cartservice -o jsonpath='{.spec.template.spec.containers[0].env}' | jq

# Create redis credentials secret
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: redis-creds
type: Opaque
stringData:
  REDIS_SOURCE: redis://redis-cart:6379
  REDIS_DEST: redis://${REDIS_DEST}
  REDIS_DEST_PASS: ${REDIS_DEST_PASS}
EOF

echo "Secret created successfully"

# Apply redis migrator job
kubectl apply -f https://raw.githubusercontent.com/Redislabs-Solution-Architects/gcp-microservices-demo-qwiklabs/main/util/redis-migrator-job.yaml

echo "Redis migrator job applied"

echo "Current cartservice environment after migrator:"
kubectl get deployment cartservice -o jsonpath='{.spec.template.spec.containers[0].env}' | jq

# Patch deployment to use Redis Cloud
kubectl patch deployment cartservice --patch '{"spec":{"template":{"spec":{"containers":[{"name":"server","env":[{"name":"REDIS_ADDR","value":"'$REDIS_ENDPOINT'"}]}]}}}}'

echo "Cartservice patched to use Redis Cloud"

echo "Updated cartservice environment:"
kubectl get deployment cartservice -o jsonpath='{.spec.template.spec.containers[0].env}' | jq

echo ""
echo "=================================================="
echo "TASK 3: Testing rollback to local Redis"
echo "=================================================="

# Rollback to local Redis
kubectl patch deployment cartservice --patch '{"spec":{"template":{"spec":{"containers":[{"name":"server","env":[{"name":"REDIS_ADDR","value":"redis-cart:6379"}]}]}}}}'

echo "Rolled back to local Redis"

echo "Current cartservice environment after rollback:"
kubectl get deployment cartservice -o jsonpath='{.spec.template.spec.containers[0].env}' | jq

echo ""
echo "=================================================="
echo "TASK 4: Final migration to Redis Cloud"
echo "=================================================="

# Final migration to Redis Cloud
kubectl patch deployment cartservice --patch '{"spec":{"template":{"spec":{"containers":[{"name":"server","env":[{"name":"REDIS_ADDR","value":"'$REDIS_ENDPOINT'"}]}]}}}}'

echo "Final migration to Redis Cloud completed"

echo "Current cartservice environment:"
kubectl get deployment cartservice -o jsonpath='{.spec.template.spec.containers[0].env}' | jq

# Delete local Redis deployment
kubectl delete deploy redis-cart

echo "Local Redis deployment deleted"

echo ""
echo "=================================================="
echo "Tutorial completed successfully!"
echo "Thank you for following Dr. Abhishek Cloud Tutorial!"
echo "Don't forget to subscribe: https://www.youtube.com/@drabhishek.5460/videos"
echo "=================================================="

popd
