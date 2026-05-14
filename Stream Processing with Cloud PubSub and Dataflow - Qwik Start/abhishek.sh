#!/bin/bash

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
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear


echo "${BLUE_TEXT}${BOLD_TEXT}=================================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}    Welcome to   Dr. Abhishek Cloud Tutorials     ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}=================================================${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Do like the video${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}& Subscribe the channel for more such amazing content${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}Enter the region:${RESET_FORMAT}"
read -p "Region: " REGION
export REGION=$REGION
gcloud config set compute/region $REGION

echo "${CYAN_TEXT}${BOLD_TEXT}Configuring Dataflow API...${RESET_FORMAT}"
gcloud services disable dataflow.googleapis.com
gcloud services enable dataflow.googleapis.com

echo "${CYAN_TEXT}${BOLD_TEXT}Enabling Cloud Scheduler API...${RESET_FORMAT}"
gcloud services enable cloudscheduler.googleapis.com
sleep 60

PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-bucket"
TOPIC_ID=my-topic

echo "${MAGENTA_TEXT}${BOLD_TEXT}Creating Cloud Storage bucket: ${BUCKET_NAME}${RESET_FORMAT}"
gsutil mb gs://$BUCKET_NAME

echo "${MAGENTA_TEXT}${BOLD_TEXT}Creating Pub/Sub topic: ${TOPIC_ID}${RESET_FORMAT}"
gcloud pubsub topics create $TOPIC_ID

echo "${YELLOW_TEXT}${BOLD_TEXT}Setting up App Engine...${RESET_FORMAT}"
if [ "$REGION" == "us-central1" ]; then
  gcloud app create --region us-central
elif [ "$REGION" == "europe-west1" ]; then
  gcloud app create --region europe-west
else
  gcloud app create --region "$REGION"
fi

echo "${CYAN_TEXT}${BOLD_TEXT}Creating Cloud Scheduler job...${RESET_FORMAT}"
gcloud scheduler jobs create pubsub publisher-job --schedule="* * * * *" \
    --topic=$TOPIC_ID --message-body="Hello!"
sleep 90

echo "${CYAN_TEXT}${BOLD_TEXT}Testing Scheduler job execution...${RESET_FORMAT}"
gcloud scheduler jobs run publisher-job --location=$REGION
sleep 90
gcloud scheduler jobs run publisher-job --location=$REGION

echo "${MAGENTA_TEXT}${BOLD_TEXT}Generating automation script...${RESET_FORMAT}"
cat > automate_commands.sh <<EOF_END
#!/bin/bash
git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
cd python-docs-samples/pubsub/streaming-analytics
pip install -U -r requirements.txt
python PubSubToGCS.py \\
--project=$PROJECT_ID \\
--region=$REGION \\
--input_topic=projects/$PROJECT_ID/topics/$TOPIC_ID \\
--output_path=gs://$BUCKET_NAME/samples/output \\
--runner=DataflowRunner \\
--window_size=2 \\
--num_shards=2 \\
--temp_location=gs://$BUCKET_NAME/temp
EOF_END

chmod +x automate_commands.sh

echo "${CYAN_TEXT}${BOLD_TEXT}Executing automation in Docker container...${RESET_FORMAT}"
docker run -it -e DEVSHELL_PROJECT_ID=$DEVSHELL_PROJECT_ID -e BUCKET_NAME=$BUCKET_NAME -e PROJECT_ID=$PROJECT_ID -e REGION=$REGION -e TOPIC_ID=$TOPIC_ID -v $(pwd)/automate_commands.sh:/automate_commands.sh python:3.7 /bin/bash -c "/automate_commands.sh"

# Completion message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}=================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}       LAB COMPLETED SUCCESSFULLY      ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}=================================================${RESET_FORMAT}"
echo
echo "${BLUE_TEXT}${BOLD_TEXT}Thank you for using Dr. Abhishek Cloud Tutorials!${RESET_FORMAT}"
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}For more cloud tutorials and labs, visit:${RESET_FORMAT}"
echo "${CYAN_TEXT}https://www.youtube.com/@DrAbhishekCloudTutorials${RESET_FORMAT}"
echo
