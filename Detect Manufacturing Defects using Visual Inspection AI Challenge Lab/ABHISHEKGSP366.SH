#!/bin/bash

# Define color variables
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'

# Define text formatting variables
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# Welcome message
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}         WELCOME TO DR ABHISHEK CLOUD    ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}       TUTORIAL  INITIATING EXECUTION...      ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo

# Get container name from user
echo "${YELLOW_TEXT}${BOLD_TEXT}Enter the container name:${RESET_FORMAT}"
read CONTAINER

# Get defective result filename from user
echo "${YELLOW_TEXT}${BOLD_TEXT}Enter the filename for defective result:${RESET_FORMAT}"
read FILE_1

# Get non-defective result filename from user
echo "${YELLOW_TEXT}${BOLD_TEXT}Enter the filename for non-defective result:${RESET_FORMAT}"
read FILE_2

# Get project ID from user
echo "${YELLOW_TEXT}${BOLD_TEXT}Enter your Google Cloud Project ID:${RESET_FORMAT}"
read INPUT_PROJECT_ID

# Display the entered values
echo "${GREEN_TEXT}Using container name: ${BOLD_TEXT}$CONTAINER${RESET_FORMAT}"
echo "${GREEN_TEXT}Using defective result filename: ${BOLD_TEXT}$FILE_1${RESET_FORMAT}"
echo "${GREEN_TEXT}Using non-defective result filename: ${BOLD_TEXT}$FILE_2${RESET_FORMAT}"
echo "${GREEN_TEXT}Using Project ID: ${BOLD_TEXT}$INPUT_PROJECT_ID${RESET_FORMAT}"
echo

ZONE="$(gcloud compute instances list --project=$INPUT_PROJECT_ID --format='value(ZONE)' | head -n 1)"

echo "${MAGENTA_TEXT}${BOLD_TEXT}Saving environment variables...${RESET_FORMAT}"

echo "export CONTAINER_NAME=$CONTAINER" > env_vars.sh
echo "export TASK_3_FILE_NAME=$FILE_1" >> env_vars.sh
echo "export TASK_4_FILE_NAME=$FILE_2" >> env_vars.sh

echo "${GREEN_TEXT}${BOLD_TEXT}Environment variables saved successfully!${RESET_FORMAT}"

echo "${MAGENTA_TEXT}${BOLD_TEXT}Generating prepare_disk.sh script...${RESET_FORMAT}"

source env_vars.sh

cat > prepare_disk.sh <<'EOF_END'
# Source the environment variables
source /tmp/env_vars.sh

export mobile_inspection=gcr.io/ql-shared-resources-test/defect_solution@sha256:776fd8c65304ac017f5b9a986a1b8189695b7abbff6aa0e4ef693c46c7122f4c

export VISERVING_CPU_DOCKER_WITH_MODEL=${mobile_inspection}
export HTTP_PORT=8602
export LOCAL_METRIC_PORT=8603

docker pull ${VISERVING_CPU_DOCKER_WITH_MODEL}

docker run -v /secrets:/secrets --rm -d --name "$CONTAINER_NAME" \
--network="host" \
-p ${HTTP_PORT}:8602 \
-p ${LOCAL_METRIC_PORT}:8603 \
-t ${VISERVING_CPU_DOCKER_WITH_MODEL} \
--use_default_credentials=false \
--service_account_credentials_json=/secrets/assembly-usage-reporter.json

# Task 2
gsutil cp gs://cloud-training/gsp895/prediction_script.py .

export PROJECT_ID=$(gcloud config get-value core/project)
gsutil mb gs://${PROJECT_ID}
gsutil -m cp gs://cloud-training/gsp897/cosmetic-test-data/*.png \
gs://${PROJECT_ID}/cosmetic-test-data/
gsutil cp gs://${PROJECT_ID}/cosmetic-test-data/IMG_07703.png .

# Task 3
sudo apt install python3 -y
sudo apt install python3-pip -y
sudo apt install python3.11-venv -y 
python3 -m venv myvenv
source myvenv/bin/activate
pip install absl-py  
pip install numpy 
pip install requests

python3 ./prediction_script.py --input_image_file=./IMG_07703.png  --port=8602 --output_result_file=${TASK_3_FILE_NAME}

# Task 4
export PROJECT_ID=$(gcloud config get-value core/project)
gsutil cp gs://${PROJECT_ID}/cosmetic-test-data/IMG_0769.png .

python3 ./prediction_script.py --input_image_file=./IMG_0769.png  --port=8602 --output_result_file=${TASK_4_FILE_NAME}
EOF_END

echo "${GREEN_TEXT}${BOLD_TEXT}prepare_disk.sh script generated successfully!${RESET_FORMAT}"

echo "${MAGENTA_TEXT}${BOLD_TEXT}Copying scripts to the VM...${RESET_FORMAT}"

# Copy the environment variables script to the VM
gcloud compute scp env_vars.sh lab-vm:/tmp --project=$INPUT_PROJECT_ID --zone=$ZONE --quiet

# Copy the prepare_disk.sh script to the VM
gcloud compute scp prepare_disk.sh lab-vm:/tmp --project=$INPUT_PROJECT_ID --zone=$ZONE --quiet

echo "${GREEN_TEXT}${BOLD_TEXT}Scripts copied successfully!${RESET_FORMAT}"

echo "${MAGENTA_TEXT}${BOLD_TEXT}Executing script on VM...${RESET_FORMAT}"

# SSH into the VM and execute the script
gcloud compute ssh lab-vm --project=$INPUT_PROJECT_ID --zone=$ZONE --quiet --command="bash /tmp/prepare_disk.sh"

echo
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}              LAB COMPLETED SUCCESSFULLY!              ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo ""
echo -e "${RED_TEXT}${BOLD_TEXT}For more tech tutorials, subscribe to Dr. Abhishek's YouTube channel:${RESET_FORMAT}"
echo -e "${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo -e "${YELLOW_TEXT}${BOLD_TEXT}Thank you for using this lab script!${RESET_FORMAT}"
