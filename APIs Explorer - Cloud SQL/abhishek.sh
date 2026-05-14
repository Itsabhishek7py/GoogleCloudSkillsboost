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
DIM=$(tput dim)
RESET=$(tput sgr0)

clear

# Display Header
echo
echo "${CYAN}${BOLD}============================================${RESET}"
echo "${CYAN}${BOLD}   DR. ABHISHEK'S CLOUD SQL & BIGQUERY LAB  ${RESET}"
echo "${CYAN}${BOLD}============================================${RESET}"
echo "${BLUE}YouTube Channel: https://www.youtube.com/@drabhishek.5460${RESET}"
echo "${CYAN}Video Tutorials: https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo

# Region Configuration
echo "${BLUE}${BOLD}Step 1: Configuring Cloud Region${RESET}"
echo "${WHITE}Detecting your project's default region...${RESET}"
echo

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

if [ -z "$REGION" ]; then
  echo "${YELLOW}⚠️  No default region detected in project configuration${RESET}"
  echo "${CYAN}Please enter your desired region (e.g., us-central1):${RESET}"
  read -p "${WHITE}Region: ${RESET}" REGION
  export REGION
fi

echo "${GREEN}✓ Region configured: ${REGION}${RESET}"
echo

# Enable SQL Admin API
echo "${BLUE}${BOLD}Step 2: Enabling SQL Admin API${RESET}"
echo "${WHITE}Activating Cloud SQL administration service...${RESET}"
echo

gcloud services enable sqladmin.googleapis.com

echo "${GREEN}✓ SQL Admin API successfully enabled${RESET}"
echo

# Create Cloud SQL Instance
echo "${BLUE}${BOLD}Step 3: Creating Cloud SQL Instance${RESET}"
echo "${YELLOW}This may take several minutes to complete...${RESET}"
echo

gcloud sql instances create my-instance \
  --project=$DEVSHELL_PROJECT_ID \
  --region=$REGION \
  --database-version=MYSQL_5_7 \
  --tier=db-n1-standard-1

echo "${GREEN}✓ Cloud SQL instance 'my-instance' created${RESET}"
echo

# Create MySQL Database
echo "${BLUE}${BOLD}Step 4: Creating MySQL Database${RESET}"
echo

gcloud sql databases create mysql-db \
  --instance=my-instance \
  --project=$DEVSHELL_PROJECT_ID

echo "${GREEN}✓ MySQL database 'mysql-db' created${RESET}"
echo

# Create BigQuery Dataset
echo "${BLUE}${BOLD}Step 5: Setting Up BigQuery Dataset${RESET}"
echo

bq mk --dataset $DEVSHELL_PROJECT_ID:mysql_db

echo "${GREEN}✓ BigQuery dataset 'mysql_db' created${RESET}"
echo

# Create BigQuery Table
echo "${BLUE}${BOLD}Step 6: Creating BigQuery Table Structure${RESET}"
echo

bq query --use_legacy_sql=false \
"CREATE TABLE \`${DEVSHELL_PROJECT_ID}.mysql_db.info\` (
  name STRING,
  age INT64,
  occupation STRING
);"

echo "${GREEN}✓ BigQuery table schema created${RESET}"
echo

# Generate Sample Data
echo "${BLUE}${BOLD}Step 7: Generating Sample Data File${RESET}"
echo

cat > employee_info.csv <<EOF
"Sean",23,"Content Creator"
"Emily",34,"Cloud Engineer"
"Rocky",40,"Event Coordinator"
"Kate",28,"Data Analyst"
"Juan",51,"Program Manager"
"Jennifer",32,"Web Developer"
EOF

echo "${GREEN}✓ Sample data file 'employee_info.csv' generated${RESET}"
echo

# Create Cloud Storage Bucket
echo "${BLUE}${BOLD}Step 8: Creating Cloud Storage Bucket${RESET}"
echo

gsutil mb gs://$DEVSHELL_PROJECT_ID

echo "${GREEN}✓ Storage bucket created${RESET}"
echo

# Upload Data to Cloud Storage
echo "${BLUE}${BOLD}Step 9: Uploading Data to Cloud Storage${RESET}"
echo

gsutil cp employee_info.csv gs://$DEVSHELL_PROJECT_ID/

echo "${GREEN}✓ Data file uploaded to storage${RESET}"
echo

# Configure Service Account Permissions
echo "${BLUE}${BOLD}Step 10: Configuring Service Account Permissions${RESET}"
echo

SERVICE_EMAIL=$(gcloud sql instances describe my-instance \
  --format="value(serviceAccountEmailAddress)")

gsutil iam ch serviceAccount:$SERVICE_EMAIL:roles/storage.admin \
  gs://$DEVSHELL_PROJECT_ID/

echo "${GREEN}✓ Service account permissions configured${RESET}"
echo

# Completion Message
echo "${MAGENTA}${BOLD}============================================${RESET}"
echo "${MAGENTA}${BOLD}   CLOUD SQL & BIGQUERY LAB COMPLETED!     ${RESET}"
echo "${MAGENTA}${BOLD}============================================${RESET}"
echo
echo "${GREEN}${BOLD}Congratulations on completing the lab!${RESET}"
echo
echo "${BLUE}${BOLD}For more cloud tutorials:${RESET}"
echo "${CYAN}Subscribe to Dr. Abhishek's YouTube Channel:${RESET}"
echo "${YELLOW}https://www.youtube.com/@drabhishek.5460${RESET}"
echo "${CYAN}Video Tutorials:${RESET}"
echo "${YELLOW}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
