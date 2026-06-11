#!/bin/bash

# Define color variables
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
CYAN_TEXT=$'\033[0;96m'
BLUE_TEXT=$'\033[0;94m'
ORANGE_TEXT=$'\033[38;5;208m'
MAGENTA_TEXT=$'\033[0;95m'

BOLD_TEXT=$'\033[1m'
RESET_FORMAT=$'\033[0m'
UNDERLINE_TEXT=$'\033[4m'

# Spinner function
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

clear

# Welcome message in ORANGE
echo "${ORANGE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}           WELCOME TO DR. ABHISHEK GUIDE${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}                 LIKE THE VIDEO & SUBSCRIBE THE CHANNEL..${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}==================================================================${RESET_FORMAT}"
echo

echo "${YELLOW_TEXT}${BOLD_TEXT}Enter required details:${RESET_FORMAT}"
read -p "Enter USER_2 (email): " USER_2
read -p "Enter ZONE (e.g. us-central1-a): " ZONE
read -p "Enter TOPIC name: " TOPIC
read -p "Enter FUNCTION name: " FUNCTION

export USER_2
export ZONE
export TOPIC
export FUNCTION

export REGION="${ZONE%-*}"

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}[1/8] Enabling required GCP services...${RESET_FORMAT}"
(
    gcloud services enable \
        artifactregistry.googleapis.com \
        cloudfunctions.googleapis.com \
        cloudbuild.googleapis.com \
        eventarc.googleapis.com \
        run.googleapis.com \
        logging.googleapis.com \
        pubsub.googleapis.com
) & spinner $!

echo -e "${GREEN_TEXT}✓ Services enabled successfully!${RESET_FORMAT}"

sleep 10

PROJECT_NUMBER=$(gcloud projects describe $DEVSHELL_PROJECT_ID --format='value(projectNumber)')

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}[2/8] Configuring IAM policies...${RESET_FORMAT}"
(
    gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
        --member=serviceAccount:$PROJECT_NUMBER-compute@developer.gserviceaccount.com \
        --role=roles/eventarc.eventReceiver
) & spinner $!
echo -e "${GREEN_TEXT}✓ IAM policy 1 applied${RESET_FORMAT}"

sleep 10

SERVICE_ACCOUNT="$(gsutil kms serviceaccount -p $DEVSHELL_PROJECT_ID)"

(
    gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
        --member="serviceAccount:${SERVICE_ACCOUNT}" \
        --role='roles/pubsub.publisher'
) & spinner $!
echo -e "${GREEN_TEXT}✓ IAM policy 2 applied${RESET_FORMAT}"

sleep 10

(
    gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
        --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com \
        --role=roles/iam.serviceAccountTokenCreator
) & spinner $!
echo -e "${GREEN_TEXT}✓ IAM policy 3 applied${RESET_FORMAT}"

sleep 10

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}[3/8] Creating Cloud Storage bucket...${RESET_FORMAT}"
(
    gsutil mb -l $REGION gs://$DEVSHELL_PROJECT_ID-bucket
) & spinner $!
echo -e "${GREEN_TEXT}✓ Bucket created: gs://$DEVSHELL_PROJECT_ID-bucket${RESET_FORMAT}"

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}[4/8] Creating Pub/Sub topic...${RESET_FORMAT}"
(
    gcloud pubsub topics create $TOPIC
) & spinner $!
echo -e "${GREEN_TEXT}✓ Topic created: $TOPIC${RESET_FORMAT}"

mkdir lol
cd lol

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}[5/8] Creating Cloud Function files...${RESET_FORMAT}"

cat > index.js <<'EOF_END'
const functions = require('@google-cloud/functions-framework');
const { Storage } = require('@google-cloud/storage');
const { PubSub } = require('@google-cloud/pubsub');
const sharp = require('sharp');

functions.cloudEvent('memories-thumbnail-generator', async cloudEvent => {
  const event = cloudEvent.data;

  console.log(`Event: ${JSON.stringify(event)}`);
  console.log(`Hello ${event.bucket}`);

  const fileName = event.name;
  const bucketName = event.bucket;
  const size = "64x64";
  const bucket = new Storage().bucket(bucketName);
  const topicName = "topic-memories-522";
  const pubsub = new PubSub();

  if (fileName.search("64x64_thumbnail") === -1) {
    const filename_split = fileName.split('.');
    const filename_ext = filename_split[filename_split.length - 1].toLowerCase();
    const filename_without_ext = fileName.substring(0, fileName.length - filename_ext.length - 1);

    if (filename_ext === 'png' || filename_ext === 'jpg' || filename_ext === 'jpeg') {
      console.log(`Processing Original: gs://${bucketName}/${fileName}`);
      const gcsObject = bucket.file(fileName);
      const newFilename = `${filename_without_ext}_64x64_thumbnail.${filename_ext}`;
      const gcsNewObject = bucket.file(newFilename);

      try {
        const [buffer] = await gcsObject.download();
        const resizedBuffer = await sharp(buffer)
          .resize(64, 64, {
            fit: 'inside',
            withoutEnlargement: true,
          })
          .toFormat(filename_ext)
          .toBuffer();

        await gcsNewObject.save(resizedBuffer, {
          metadata: {
            contentType: `image/${filename_ext}`,
          },
        });

        console.log(`Success: ${fileName} → ${newFilename}`);

        await pubsub
          .topic(topicName)
          .publishMessage({ data: Buffer.from(newFilename) });

        console.log(`Message published to ${topicName}`);
      } catch (err) {
        console.error(`Error: ${err}`);
      }
    } else {
      console.log(`gs://${bucketName}/${fileName} is not an image I can handle`);
    }
  } else {
    console.log(`gs://${bucketName}/${fileName} already has a thumbnail`);
  }
});
EOF_END

sed -i "8c\functions.cloudEvent('$FUNCTION', cloudEvent => { " index.js
sed -i "18c\  const topicName = '$TOPIC';" index.js

cat > package.json <<EOF_END
{
 "name": "thumbnails",
 "version": "1.0.0",
 "description": "Create Thumbnail of uploaded image",
 "scripts": {
   "start": "node index.js"
 },
 "dependencies": {
   "@google-cloud/functions-framework": "^3.0.0",
   "@google-cloud/pubsub": "^2.0.0",
   "@google-cloud/storage": "^6.11.0",
   "sharp": "^0.32.1"
 },
 "devDependencies": {},
 "engines": {
   "node": ">=4.3.2"
 }
}
EOF_END

echo -e "${GREEN_TEXT}✓ Cloud Function files created${RESET_FORMAT}"

PROJECT_ID=$(gcloud config get-value project)
BUCKET_SERVICE_ACCOUNT="${PROJECT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}[6/8] Adding bucket service account policy...${RESET_FORMAT}"
(
    gcloud projects add-iam-policy-binding $PROJECT_ID \
        --member=serviceAccount:$BUCKET_SERVICE_ACCOUNT \
        --role=roles/pubsub.publisher
) & spinner $!
echo -e "${GREEN_TEXT}✓ IAM policy applied${RESET_FORMAT}"

deploy_function() {
    gcloud functions deploy $FUNCTION \
        --gen2 \
        --runtime nodejs22 \
        --trigger-resource $DEVSHELL_PROJECT_ID-bucket \
        --trigger-event google.storage.object.finalize \
        --entry-point $FUNCTION \
        --region=$REGION \
        --source . \
        --quiet
}

SERVICE_NAME="$FUNCTION"

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}[7/8] Deploying Cloud Function...${RESET_FORMAT}"
echo -e "${YELLOW_TEXT}This may take 3-5 minutes...${RESET_FORMAT}"

while true; do
    deploy_function & spinner $!
    if gcloud run services describe $SERVICE_NAME --region $REGION &> /dev/null; then
        echo -e "${GREEN_TEXT}✓ Cloud Function deployed successfully!${RESET_FORMAT}"
        break
    else
        echo -e "${YELLOW_TEXT}Waiting for Cloud Run service to be created...${RESET_FORMAT}"
        sleep 20
    fi
done

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}[8/8] Testing the setup...${RESET_FORMAT}"
(
    curl -s -o map.jpg https://storage.googleapis.com/cloud-training/gsp315/map.jpg
    gsutil cp map.jpg gs://$DEVSHELL_PROJECT_ID-bucket/map.jpg
) & spinner $!
echo -e "${GREEN_TEXT}✓ Test image uploaded${RESET_FORMAT}"

echo -e "\n${ORANGE_TEXT}${BOLD_TEXT}Removing viewer permissions from USER_2...${RESET_FORMAT}"
(
    gcloud projects remove-iam-policy-binding $DEVSHELL_PROJECT_ID \
        --member=user:$USER_2 \
        --role=roles/viewer --quiet
) & spinner $!
echo -e "${GREEN_TEXT}✓ Permissions removed${RESET_FORMAT}"

# Final message
echo
echo "${ORANGE_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}              LAB COMPLETED SUCCESSFULLY!              ${RESET_FORMAT}"
echo "${ORANGE_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo
echo "${RED_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}Please subscribe to the channel for more videos and updates!${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}How are you !${RESET_FORMAT}"
echo
