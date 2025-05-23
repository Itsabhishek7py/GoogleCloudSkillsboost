#!/bin/bash

# Color definitions
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Function to display the banner
show_banner() {
    local pattern=(
        "**********************************************************"
        "**                      WELCOME      TO                **"
        "**                 D R .  A B H I S H E K               **"
        "**       Cloud Solutions & Tutorials Channel            **"
        "**********************************************************"
    )
    for line in "${pattern[@]}"; do
        echo -e "${YELLOW}${line}${NC}"
    done
    echo -e "${GREEN}YouTube: https://www.youtube.com/@drabhishek.5460${NC}"
    echo
}

# Show welcome banner
show_banner

# Get user input
read -p "Enter your REGION: " REGION
export REGION

echo -e "${BLUE}Setting up Cloud Run environment...${NC}"
gcloud services disable run.googleapis.com
gcloud services enable run.googleapis.com
sleep 30

echo -e "${BLUE}Cloning repository...${NC}"
git clone https://github.com/rosera/pet-theory.git
cd pet-theory/lab03 || exit

echo -e "${BLUE}Configuring Node.js application...${NC}"
sed -i '6a\    "start": "node index.js",' package.json
npm install express body-parser child_process @google-cloud/storage

echo -e "${BLUE}Building and deploying PDF Converter...${NC}"
gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter
gcloud run deploy pdf-converter \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter \
  --platform managed \
  --region $REGION \
  --no-allow-unauthenticated \
  --max-instances=1

SERVICE_URL=$(gcloud beta run services describe pdf-converter --platform managed --region $REGION --format="value(status.url)")

echo -e "${BLUE}Testing service endpoints...${NC}"
curl -X POST $SERVICE_URL
curl -X POST -H "Authorization: Bearer $(gcloud auth print-identity-token)" $SERVICE_URL

echo -e "${BLUE}Setting up storage and pub/sub...${NC}"
gsutil mb gs://$GOOGLE_CLOUD_PROJECT-upload
gsutil mb gs://$GOOGLE_CLOUD_PROJECT-processed
gsutil notification create -t new-doc -f json -e OBJECT_FINALIZE gs://$GOOGLE_CLOUD_PROJECT-upload

gcloud iam service-accounts create pubsub-cloud-run-invoker --display-name "PubSub Cloud Run Invoker"
gcloud beta run services add-iam-policy-binding pdf-converter \
  --member=serviceAccount:pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com \
  --role=roles/run.invoker \
  --platform managed \
  --region $REGION

PROJECT_NUMBER=$(gcloud projects describe $GOOGLE_CLOUD_PROJECT --format='value(projectNumber)')
gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT \
  --member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-pubsub.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountTokenCreator

gcloud beta pubsub subscriptions create pdf-conv-sub \
  --topic new-doc \
  --push-endpoint=$SERVICE_URL \
  --push-auth-service-account=pubsub-cloud-run-invoker@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com

gsutil -m cp gs://spls/gsp644/* gs://$GOOGLE_CLOUD_PROJECT-upload

echo -e "${BLUE}Creating application files...${NC}"
cat > Dockerfile <<EOF
FROM node:20
RUN apt-get update -y \\
    && apt-get install -y libreoffice \\
    && apt-get clean
WORKDIR /usr/src/app
COPY package.json package*.json ./
RUN npm install --only=production
COPY . .
CMD [ "npm", "start" ]
EOF

cat > index.js <<'EOF'
const {promisify} = require('util');
const {Storage} = require('@google-cloud/storage');
const exec = promisify(require('child_process').exec);
const storage = new Storage();
const express = require('express');
const bodyParser = require('body-parser');
const app = express();

app.use(bodyParser.json());

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log('Listening on port', port);
});

app.post('/', async (req, res) => {
  try {
    const file = decodeBase64Json(req.body.message.data);
    await downloadFile(file.bucket, file.name);
    const pdfFileName = await convertFile(file.name);
    await uploadFile(process.env.PDF_BUCKET, pdfFileName);
    await deleteFile(file.bucket, file.name);
  }
  catch (ex) {
    console.log(`Error: ${ex}`);
  }
  res.set('Content-Type', 'text/plain');
  res.send('\n\nOK\n\n');
})

function decodeBase64Json(data) {
  return JSON.parse(Buffer.from(data, 'base64').toString());
}

async function downloadFile(bucketName, fileName) {
  const options = {destination: `/tmp/${fileName}`};
  await storage.bucket(bucketName).file(fileName).download(options);
}

async function convertFile(fileName) {
  const cmd = 'libreoffice --headless --convert-to pdf --outdir /tmp ' +
              `"/tmp/${fileName}"`;
  console.log(cmd);
  const { stdout, stderr } = await exec(cmd);
  if (stderr) {
    throw stderr;
  }
  console.log(stdout);
  pdfFileName = fileName.replace(/\.\w+$/, '.pdf');
  return pdfFileName;
}

async function deleteFile(bucketName, fileName) {
  await storage.bucket(bucketName).file(fileName).delete();
}

async function uploadFile(bucketName, fileName) {
  await storage.bucket(bucketName).upload(`/tmp/${fileName}`);
}
EOF

echo -e "${BLUE}Rebuilding with LibreOffice support...${NC}"
gcloud builds submit --tag gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter
gcloud run deploy pdf-converter \
  --image gcr.io/$GOOGLE_CLOUD_PROJECT/pdf-converter \
  --platform managed \
  --region $REGION \
  --memory=2Gi \
  --no-allow-unauthenticated \
  --max-instances=1 \
  --set-env-vars PDF_BUCKET=$GOOGLE_CLOUD_PROJECT-processed

echo -e "${GREEN}✅✅✅✅   LAB COMPLETED SUCCESSFULLY   ✅✅✅✅${NC}"
show_banner
