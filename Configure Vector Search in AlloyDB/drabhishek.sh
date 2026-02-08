#!/bin/bash

# ==============================
# 🎉 WELCOME MESSAGE
# ==============================
clear
echo "=============================================="
echo "🚀 Welcome to Dr Abhishek Tutorials"
echo "📌 Subscribe for more Cloud & AI Labs:"
echo "👉 https://www.youtube.com/@drabhishek.5460/videos"
echo "=============================================="
sleep 2

# ==============================
# 🔄 SPINNER FUNCTION
# ==============================
spinner() {
  local pid=$!
  local delay=0.1
  local spinstr='|/-\'
  while ps a | awk '{print $1}' | grep -q "$pid"; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

# ==============================
# 📌 AUTO-DETECT PROJECT
# ==============================
echo "🔍 Detecting GCP Project..."
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)") & spinner
echo "✅ Project ID: $PROJECT_ID"
echo "✅ Project Number: $PROJECT_NUMBER"

# ==============================
# 🧑 USER INPUT
# ==============================
read -p "🌍 Enter AlloyDB region (e.g. us-central1): " REGION

# ==============================
# 🔒 FIXED LAB RESOURCES
# ==============================
CLUSTER=patent-cluster
INSTANCE=patent-instance
DB=postgres
USER=postgres

echo "----------------------------------------------"
echo "📘 Cluster  : $CLUSTER"
echo "📘 Instance : $INSTANCE"
echo "📘 Region   : $REGION"
echo "----------------------------------------------"

# ==============================
# 🔗 CONNECT TO ALLOYDB
# ==============================
echo "🔌 Connecting to AlloyDB..."
gcloud alloydb instances connect $INSTANCE \
  --cluster=$CLUSTER \
  --region=$REGION \
  --project=$PROJECT_ID \
  --user=$USER \
  --database=$DB & spinner

# ==============================
# 🧠 SQL COMMANDS
# ==============================
echo "🧠 Running SQL setup..."

cat <<EOF
CREATE EXTENSION IF NOT EXISTS vector;

GRANT EXECUTE ON FUNCTION embedding TO postgres;

CREATE TABLE IF NOT EXISTS patents_data (
  id VARCHAR(25),
  type VARCHAR(25),
  number VARCHAR(20),
  country VARCHAR(2),
  date VARCHAR(20),
  abstract VARCHAR(300000),
  title VARCHAR(100000),
  kind VARCHAR(5),
  num_claims BIGINT,
  filename VARCHAR(100),
  withdrawn BIGINT,
  abstract_embeddings vector(3072)
);

SELECT embedding(
  'text-embedding-004',
  'AlloyDB is a managed, cloud-hosted SQL database service.'
);

UPDATE patents_data
SET abstract_embeddings = embedding('text-embedding-004', abstract);
EOF

# ==============================
# 🔐 IAM PERMISSION
# ==============================
echo "🔐 Granting Vertex AI permission..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:service-$PROJECT_NUMBER@gcp-sa-alloydb.iam.gserviceaccount.com" \
  --role="roles/aiplatform.user" & spinner

# ==============================
# ✅ FINAL MESSAGE
# ==============================
echo ""
echo "=============================================="
echo "✅ AlloyDB Vector Embedding Setup Completed!"
echo "🔥 Lab executed successfully"
echo "🙏 Thanks for learning with Dr Abhishek Tutorials"
echo "🔔 Don't forget to subscribe:"
echo "👉 https://www.youtube.com/@drabhishek.5460/videos"
echo "=============================================="

