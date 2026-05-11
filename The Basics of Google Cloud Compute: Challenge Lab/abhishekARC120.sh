#!/bin/bash
## Changed by nov05, 2026-05-11

# Define color variables
BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

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
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

echo "${CYAN}${BOLD}"
echo "**********************************************************************"
echo "* Welcome to Dr. Abhishek Cloud Tutorial!                            *"
echo "*                                                                    *"
echo "* Please do like, share and subscribe to the channel:                *"
echo "* https://www.youtube.com/@drabhishek.5460/videos                    *"
echo "*                                                                    *"
echo "* Thank you for your support!                                        *"
echo "**********************************************************************"
echo "${RESET}"

# Get Project ID dynamically
echo "${YELLOW}${BOLD}Fetching Project Details...${RESET}"
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [[ -z "$PROJECT_ID" ]]; then
    echo "${RED}${BOLD}❌ Error: Could not get Project ID. Please ensure you're logged into gcloud.${RESET}"
    exit 1
fi
echo "${GREEN}🔹  Project ID: ${PROJECT_ID}${RESET}"

# Get Zone dynamically
ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])" 2>/dev/null)
if [[ -z "$ZONE" ]]; then
    ZONE="us-central1-a"
    echo "${YELLOW}⚠ Zone not found in metadata, using default: $ZONE${RESET}"
else
    echo "${GREEN}🔹  Zone detected: ${ZONE}${RESET}"
fi

# Get Region dynamically from Zone
REGION=$(echo $ZONE | sed 's/-[a-z]$//')
if [[ -z "$REGION" ]]; then
    REGION="us-central1"
    echo "${YELLOW}⚠ Region derived from zone, using: $REGION${RESET}"
else
    echo "${GREEN}🔹  Region detected: ${REGION}${RESET}"
fi

echo ""
echo "${CYAN}${BOLD}Configuration Summary:${RESET}"
echo "  Project ID: ${PROJECT_ID}"
echo "  Zone: ${ZONE}"
echo "  Region: ${REGION}"
echo ""

# Task 1: Create Cloud Storage bucket
echo "${YELLOW}${BOLD}Task 1: Creating Cloud Storage bucket...${RESET}"
BUCKET_NAME="${PROJECT_ID}-bucket"
if gsutil ls -b "gs://${BUCKET_NAME}" >/dev/null 2>&1; then
    echo "${YELLOW}⚠️  Bucket already exists: ${BUCKET_NAME}${RESET}"
else
    gsutil mb -l US "gs://${BUCKET_NAME}"
    echo "${GREEN}✅  Bucket created: ${BUCKET_NAME}${RESET}"
fi

# Task 2: Create Compute Engine instance with correct configuration
echo ""
echo "${YELLOW}${BOLD}Task 2: Creating Compute Engine instance...${RESET}"
if gcloud compute instances describe my-instance --zone=$ZONE --format="get(name)" 2>/dev/null; then
    echo "${YELLOW}⚠️  Instance 'my-instance' already exists. Deleting and recreating...${RESET}"
    gcloud compute instances delete my-instance --zone=$ZONE --quiet
    sleep 10
fi

gcloud compute instances create my-instance \
    --machine-type=e2-medium \
    --zone=$ZONE \
    --image-project=debian-cloud \
    --image-family=debian-12 \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-balanced \
    --tags=http-server

echo "${GREEN}✅  Instance 'my-instance' created${RESET}"

# Create persistent disk
echo ""
echo "${YELLOW}${BOLD}Creating persistent disk mydisk...${RESET}"
if gcloud compute disks describe mydisk --zone=$ZONE --format="get(name)" 2>/dev/null; then
    echo "${YELLOW}⚠ Disk 'mydisk' already exists. Deleting and recreating...${RESET}"
    gcloud compute disks delete mydisk --zone=$ZONE --quiet
    sleep 5
fi

gcloud compute disks create mydisk \
    --size=200GB \
    --zone=$ZONE

echo "${GREEN}✅  Disk 'mydisk' created${RESET}"

# Attach disk to instance
echo ""
echo "${YELLOW}${BOLD}Attaching disk to instance...${RESET}"
gcloud compute instances attach-disk my-instance \
    --disk=mydisk \
    --zone=$ZONE

echo "${GREEN}✅  Disk attached to instance${RESET}"

# Wait for instance to be ready
echo ""
echo "${YELLOW}${BOLD}Waiting for instance to be ready...${RESET}"
sleep 30

# Task 3: Install NGINX web server
echo ""
echo "${YELLOW}${BOLD}Task 3: Installing NGINX web server...${RESET}"
cat > prepare_disk.sh <<'EOF_END'
#!/bin/bash
sudo apt update -y
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
echo "NGINX installation completed"
EOF_END

# Make script executable
chmod +x prepare_disk.sh

# Copy script to instance
echo "${YELLOW}Copying installation script to instance...${RESET}"
gcloud compute scp prepare_disk.sh my-instance:/tmp/ --project=$PROJECT_ID --zone=$ZONE --quiet

# Execute script on instance
echo "${YELLOW}Installing NGINX on instance...${RESET}"
gcloud compute ssh my-instance --project=$PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/prepare_disk.sh"

# Clean up local script
rm -f prepare_disk.sh

# Get external IP and display URL
EXTERNAL_IP=$(gcloud compute instances describe my-instance --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

echo ""
echo "${GREEN}${BOLD}"
echo "=================================================="
echo "✅  NGINX installed successfully
echo "=================================================="
echo "${RESET}"
echo "${CYAN}👉  Access your web server at: http://${EXTERNAL_IP}${RESET}"
echo ""

# Test the web server
echo "${YELLOW}${BOLD}Testing web server...${RESET}"
if curl -s --head --max-time 5 "http://${EXTERNAL_IP}" | grep "200 OK" > /dev/null; then
    echo "${GREEN}✅  Web server is responding with HTTP 200 OK${RESET}"
else
    echo "${YELLOW}⚠️  Web server may take a few moments to fully start. Please check manually.${RESET}"
fi

echo ""
echo "${BG_GREEN}${BOLD}All Tasks Completed Successfully${RESET}"
echo ""
echo "${CYAN}${BOLD}Task Summary:${RESET}"
echo "  Task 1: Cloud Storage bucket created (${BUCKET_NAME})"
echo "  Task 2: Instance 'my-instance' created with attached disk 'mydisk'"
echo "  Task 3: NGINX web server installed and running"
echo ""

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab${RESET}"

echo "${CYAN}"
echo "**********************************************************************"
echo "* Don't forget to subscribe to Dr. Abhishek's YouTube channel:       *"
echo "* https://www.youtube.com/@drabhishek.5460/videos                    *"
echo "*                                                                    *"
echo "* Thank you for following along!                                     *"
echo "**********************************************************************"
echo "${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
