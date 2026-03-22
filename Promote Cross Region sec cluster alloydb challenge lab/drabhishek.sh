#!/bin/bash
set -e

echo "=============================================="
echo " Welcome to Dr Abhishek Tutorial"
echo " Subscribe: https://www.youtube.com/@drabhishek.5460"
echo "=============================================="
echo ""

echo "Enter REGION_1 (example: us-central1)"
read REGION_1

echo "Enter REGION_2 (example: europe-west1)"
read REGION_2

export REGION_1
export REGION_2

PROJECT_ID=$(gcloud config get-value project)
NETWORK="default"

echo "Using REGION_1=$REGION_1"
echo "Using REGION_2=$REGION_2"
echo "Project=$PROJECT_ID"

gcloud services enable alloydb.googleapis.com

# -----------------------------
# Task 1: Primary Cluster
# -----------------------------
gcloud alloydb clusters create alloydb-primary-cluster \
  --password=password \
  --region=$REGION_1 \
  --network=$NETWORK \
  --database-version=POSTGRES_14 \
  --cluster-type=PRIMARY

gcloud alloydb instances create alloydb-primary-instance \
  --cluster=alloydb-primary-cluster \
  --region=$REGION_1 \
  --instance-type=PRIMARY \
  --cpu-count=2 \
  --memory-size=16GB \
  --database-flags=alloydb.enable_pgaudit=on

gcloud alloydb clusters update alloydb-primary-cluster \
  --region=$REGION_1 \
  --continuous-backup-recovery-window-days=7

# -----------------------------
# Task 2: Secondary Cluster
# -----------------------------
gcloud alloydb clusters create alloydb-secondary-cluster \
  --region=$REGION_2 \
  --cluster-type=SECONDARY \
  --primary-cluster=projects/$PROJECT_ID/locations/$REGION_1/clusters/alloydb-primary-cluster

gcloud alloydb instances create alloydb-secondary-instance \
  --cluster=alloydb-secondary-cluster \
  --region=$REGION_2 \
  --instance-type=SECONDARY \
  --cpu-count=2 \
  --memory-size=16GB

# -----------------------------
# Task 3: Read Pool
# -----------------------------
gcloud alloydb instances create alloydb-read-pool-instance \
  --cluster=alloydb-secondary-cluster \
  --region=$REGION_2 \
  --instance-type=READ_POOL \
  --cpu-count=2 \
  --memory-size=16GB \
  --read-pool-node-count=1

# -----------------------------
# Task 4: Promote Secondary
# -----------------------------
gcloud alloydb clusters promote alloydb-secondary-cluster \
  --region=$REGION_2

# -----------------------------
# Verify
# -----------------------------
echo "Primary cluster status:"
gcloud alloydb clusters describe alloydb-primary-cluster --region=$REGION_1 | grep clusterType

echo "Secondary cluster status:"
gcloud alloydb clusters describe alloydb-secondary-cluster --region=$REGION_2 | grep clusterType

echo "DONE - Two independent primaries created"
