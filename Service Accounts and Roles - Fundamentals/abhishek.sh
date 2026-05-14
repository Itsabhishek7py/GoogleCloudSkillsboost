#!/bin/bash

# Define text formatting variables
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

# Welcome Banner
echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}          DR. ABHISHEK'S BIGQUERY LAB SCRIPT              ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${WHITE_TEXT}This lab demonstrates BigQuery integration with Compute Engine${RESET_FORMAT}"
echo "${WHITE_TEXT}using service accounts and Python client libraries${RESET_FORMAT}"
echo

echo "${GREEN_TEXT}${BOLD_TEXT}=== INITIATING CLOUD CONFIGURATION ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👤 Listing active GCP accounts...${RESET_FORMAT}"
gcloud auth list

echo "${YELLOW_TEXT}${BOLD_TEXT}🔧 Setting PROJECT_ID variable...${RESET_FORMAT}"
export PROJECT_ID=$(gcloud config get-value project)
echo "${GREEN_TEXT}✅ Project ID: ${BOLD_TEXT}$PROJECT_ID${RESET_FORMAT}"

echo "${YELLOW_TEXT}${BOLD_TEXT}🌍 Determining default compute zone...${RESET_FORMAT}"
export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
echo "${GREEN_TEXT}✅ Zone: ${BOLD_TEXT}$ZONE${RESET_FORMAT}"

echo "${YELLOW_TEXT}${BOLD_TEXT}🌏 Determining default compute region...${RESET_FORMAT}"
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
echo "${GREEN_TEXT}✅ Region: ${BOLD_TEXT}$REGION${RESET_FORMAT}"

echo "${MAGENTA_TEXT}${BOLD_TEXT}=== SERVICE ACCOUNT CONFIGURATION ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}👤 Creating service account 'my-sa-123'...${RESET_FORMAT}"
gcloud iam service-accounts create my-sa-123 --display-name "Service Account for BigQuery Demo"

echo "${YELLOW_TEXT}${BOLD_TEXT}🔑 Granting 'Editor' role to 'my-sa-123'...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member serviceAccount:my-sa-123@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com \
  --role roles/editor

echo "${YELLOW_TEXT}${BOLD_TEXT}👤 Creating service account 'bigquery-qwiklab'...${RESET_FORMAT}"
gcloud iam service-accounts create bigquery-qwiklab \
  --description="Service account for BigQuery operations" \
  --display-name="bigquery-qwiklab"

echo "${YELLOW_TEXT}${BOLD_TEXT}🔑 Granting BigQuery roles to 'bigquery-qwiklab'...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member="serviceAccount:bigquery-qwiklab@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/bigquery.dataViewer"

gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member="serviceAccount:bigquery-qwiklab@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/bigquery.user"

echo "${MAGENTA_TEXT}${BOLD_TEXT}=== COMPUTE ENGINE SETUP ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}💻 Creating Compute Engine instance 'bigquery-instance'...${RESET_FORMAT}"
gcloud compute instances create bigquery-instance \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --machine-type=e2-medium \
  --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
  --metadata=enable-oslogin=true \
  --maintenance-policy=MIGRATE \
  --provisioning-model=STANDARD \
  --service-account=bigquery-qwiklab@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --create-disk=auto-delete=yes,boot=yes,device-name=bigquery-instance,image=projects/debian-cloud/global/images/debian-11-bullseye-v20231010,mode=rw,size=10,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced \
  --no-shielded-secure-boot \
  --shielded-vtpm \
  --shielded-integrity-monitoring \
  --labels=goog-ec-src=vm_add-gcloud \
  --reservation-affinity=any

echo "${BLUE_TEXT}${BOLD_TEXT}⏳ Waiting for instance initialization (20 seconds)...${RESET_FORMAT}"
echo -n "${BLUE_TEXT}${BOLD_TEXT}   ["
for i in {1..20}; do
    echo -n "#"
    sleep 1
done
echo "]${RESET_FORMAT}"
echo

echo "${MAGENTA_TEXT}${BOLD_TEXT}=== BIGQUERY SCRIPT DEPLOYMENT ===${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}📝 Creating local script 'cp_disk.sh'...${RESET_FORMAT}"
cat > cp_disk.sh <<'EOF_CP'
#!/bin/bash

# Install required packages
echo "${GREEN}Installing required packages...${RESET}"
sudo apt-get update -qq
sudo apt-get install -y -qq git python3-pip

# Upgrade pip and install Python libraries
echo "${GREEN}Installing Python libraries...${RESET}"
pip3 install --quiet --upgrade pip
pip3 install --quiet google-cloud-bigquery pyarrow pandas db-dtypes

# Create Python script
cat > query.py <<'EOF_PY'
from google.auth import compute_engine
from google.cloud import bigquery
import pandas as pd

print("Initializing BigQuery client...")
credentials = compute_engine.Credentials(
    service_account_email='YOUR_SERVICE_ACCOUNT')

query = '''
SELECT
  year,
  COUNT(1) as num_babies
FROM
  publicdata.samples.natality
WHERE
  year > 2000
GROUP BY
  year
ORDER BY
  year
'''

client = bigquery.Client(
    project='PROJECT_ID',
    credentials=credentials)

print("\nExecuting BigQuery job...")
df = client.query(query).to_dataframe()

print("\nQuery results:")
print(df.to_string(index=False))
EOF_PY

# Replace placeholders
sed -i -e "s/PROJECT_ID/$(gcloud config get-value project)/g" query.py
sed -i -e "s/YOUR_SERVICE_ACCOUNT/bigquery-qwiklab@$(gcloud config get-value project).iam.gserviceaccount.com/g" query.py

# Execute the script
echo "${GREEN}Running BigQuery query...${RESET}"
python3 query.py
EOF_CP
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Script created successfully${RESET_FORMAT}"

echo "${YELLOW_TEXT}${BOLD_TEXT}📤 Copying script to VM instance...${RESET_FORMAT}"
gcloud compute scp cp_disk.sh bigquery-instance:/tmp \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet

echo "${YELLOW_TEXT}${BOLD_TEXT}🚀 Executing script on VM instance...${RESET_FORMAT}"
gcloud compute ssh bigquery-instance \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet \
  --command="chmod +x /tmp/cp_disk.sh && /tmp/cp_disk.sh"

# Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}             LAB EXECUTION COMPLETED SUCCESSFULLY         ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}💡 For more cloud tutorials and labs:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}Subscribe to Dr. Abhishek's YouTube Channel${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo
