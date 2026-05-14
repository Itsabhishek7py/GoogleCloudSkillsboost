#!/bin/bash
## Created by nov05, 2026-05-13

# cat >> ~/.bashrc <<'EOF'
## Get project id, project number, region, zone
export PROJECT_ID=$(gcloud config get-value project)
export PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID \
  --format='value(projectNumber)')
export REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
# export BUCKET="$PROJECT_ID-bucket"
# gcloud config set project $(gcloud projects list --format='value(PROJECT_ID)' --filter='qwiklabs-gcp')
gcloud config set project $PROJECT_ID  
gcloud config set compute/region $REGION
echo
echo "🔹  Project ID: $PROJECT_ID"
echo "🔹  Project number: $PROJECT_NUMBER"
echo "🔹  Region: $REGION"
echo "🔹  Zone: $ZONE"
echo "🔹  User: $USER"
# echo "🔹  Bukect: $BUCKET"
echo
# EOF
# source ~/.bashrc

## Task 1. Lab setup

gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE
## This will enable the necessary Service APIs, and it will also 
## generate a terraform/terraform.tfvars file with the following keys.
make setup-project
cat terraform/terraform.tfvars
make tf-apply

## Task 2. Validation

gcloud compute ssh gke-demo-bastion
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
echo "export USE_GKE_GCLOUD_AUTH_PLUGIN=True" >> ~/.bashrc
source ~/.bashrc
gcloud container clusters get-credentials gke-demo-cluster --zone placeholder

## Task 3. Installing the hello server

kubectl apply -f ./manifests/hello-app/
kubectl get pods

## Task 4. Confirming default access to the hello server

kubectl logs --tail 10 -f $(kubectl get pods -oname -l app=hello)
kubectl logs --tail 10 -f $(kubectl get pods -oname -l app=not-hello)

## Task 5. Restricting access with a Network Policy

kubectl apply -f ./manifests/network-policy.yaml
kubectl logs --tail 10 -f $(kubectl get pods -oname -l app=not-hello)

## Task 6. Restricting namespaces with Network Policies

kubectl delete -f ./manifests/network-policy.yaml
kubectl create -f ./manifests/network-policy-namespaced.yaml
kubectl logs --tail 10 -f $(kubectl get pods -oname -l app=hello)
kubectl -n hello-apps apply -f ./manifests/hello-app/hello-client.yaml

## Task 7. Validation

kubectl logs --tail 10 -f -n hello-apps $(kubectl get pods -oname -l app=hello -n hello-apps)

## Task 8. Teardown

exit
make teardown

## Task 9. Troubleshooting in your own environment

echo -e "\n✅  All done\n"
