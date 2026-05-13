#!/bin/bash
## Created by nov05, 2026-05-12  

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
gcloud config set project $(gcloud projects list --format='value(PROJECT_ID)' --filter='qwiklabs-gcp')
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
cd ~
git clone https://github.com/rosera/pet-theory.git
  
cat << 'EOF'

========================================================
Task 1. Create a Firestore database
========================================================

EOF

gcloud firestore databases create \
  --location=$REGION \
  --type=firestore-native \
  --project=$PROJECT_ID
  
cat << 'EOF'

========================================================
Task 2. Import the database
========================================================

EOF

cd ~/pet-theory/lab06/firebase-import-csv/solution
npm install
node index.js netflix_titles_original.csv

cat << 'EOF'

========================================================
Task 3. Create the REST API
========================================================

EOF

gcloud artifacts repositories create rest-api-repo \
  --repository-format=docker \
  --location=$REGION \
  --description="GSP344 REST API container repository"
  
cd ~/pet-theory/lab06/firebase-rest-api/solution-01
gcloud builds submit \
  --tag $REGION-docker.pkg.dev/$PROJECT_ID/rest-api-repo/rest-api:0.1
gcloud run deploy netflix-dataset-service \
  --image $REGION-docker.pkg.dev/$PROJECT_ID/rest-api-repo/rest-api:0.1 \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --max-instances 1
$SERVICE_URL=$(gcloud run services describe netflix-dataset-service \
  --region $REGION \
  --format="value(status.url)")
echo -e "\n👉  Check netflix-dataset-service v0.1."
echo -e "  It should respond with: {\"status\":\"Netflix Dataset! Make a query.\"}\n"
curl -X GET $SERVICE_URL

answer=""
echo -e "\nReady to proceed?"
while true; do
  printf " (y/n): "
  read answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    break
  fi
  ## move cursor up one line and clear it
  echo -ne "\033[1A\033[2K"
done

cat << 'EOF'

========================================================
Task 4. Configure Firestore API access
========================================================

EOF

cd ~/pet-theory/lab06/firebase-rest-api/solution-02
gcloud builds submit \
  --tag $REGION-docker.pkg.dev/$PROJECT_ID/rest-api-repo/rest-api:0.2
gcloud run deploy netflix-dataset-service \
  --image $REGION-docker.pkg.dev/$PROJECT_ID/rest-api-repo/rest-api:0.2 \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --max-instances 1
export SERVICE_URL=$(gcloud run services describe netflix-dataset-service \
  --region $REGION \
  --format="value(status.url)")
echo -e "\n👉  Check netflix-dataset-service v0.2."
echo -e "  It should respond with json dataset\n"
curl -X GET $SERVICE_URL/2019

answer=""
echo -e "\nReady to proceed?"
while true; do
  printf " (y/n): "
  read answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    break
  fi
  ## move cursor up one line and clear it
  echo -ne "\033[1A\033[2K"
done

cat << 'EOF'

========================================================
Task 5. Deploy the staging frontend
========================================================

EOF

cd ~/pet-theory/lab06/firebase-frontend
gcloud builds submit \
  --tag $REGION-docker.pkg.dev/$PROJECT_ID/rest-api-repo/frontend-staging:0.1
gcloud run deploy frontend-staging-service \
  --image $REGION-docker.pkg.dev/$PROJECT_ID/rest-api-repo/frontend-staging:0.1 \
  --platform managed \
  --region $REGION \
  --max-instances 1 \
  --set-env-vars REST_API_SERVICE=$SERVICE_URL
export URL=$(gcloud run services describe frontend-staging-service \
  --region $REGION \
  --format="value(status.url)")
echo -e "\n👉  Check frontend-staging-service v0.1."
echo -e "  $URL\n"

answer=""
echo -e "\nReady to proceed?"
while true; do
  printf " (y/n): "
  read answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    break
  fi
  ## move cursor up one line and clear it
  echo -ne "\033[1A\033[2K"
done

cat << 'EOF'

========================================================
Task 6. Deploy the production frontend
========================================================

EOF

cd ~/pet-theory/lab06/firebase-frontend/public
gcloud run deploy frontend-production-service \
  --image $REGION-docker.pkg.dev/$PROJECT_ID/rest-api-repo/frontend-staging:0.1 \
  --platform managed \
  --region $REGION \
  --max-instances 1
$SERVICE_URL=$(gcloud run services describe frontend-production-service \
  --region $REGION \
  --format="value(status.url)")
sed -i "s|data/netflix.json|$SERVICE_URL/2020|g" app.js
echo -e "\n👉  Check frontend-production-service v0.1."
echo -e "  https://$SERVICE_URL/2020\n"

answer=""
echo -e "\nReady to proceed?"
while true; do
  printf " (y/n): "
  read answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    break
  fi
  ## move cursor up one line and clear it
  echo -ne "\033[1A\033[2K"
done

cd ~
echo -e "\n✅  All done\n"
