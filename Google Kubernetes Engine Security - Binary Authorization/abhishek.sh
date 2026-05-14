#!/bin/bash
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

echo
echo "${CYAN_TEXT}${BOLD_TEXT}============================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}🚀  WELCOME TO DR. ABHISHEK CLOUD TUTORIALS  🚀${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}============================================${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Don't forget to subscribe to Dr. Abhishek's YouTube channel:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo

# Initialize environment
echo "${BLUE_TEXT}${BOLD_TEXT}🔧 Initializing Google Cloud environment...${RESET_FORMAT}"
gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud config set compute/zone "$ZONE"
gcloud config set compute/region "$REGION"
export PROJECT_ID="$(gcloud config get-value project)"

echo "${GREEN_TEXT}✅ Environment configured:${RESET_FORMAT}"
echo "   Project: ${BOLD_TEXT}$PROJECT_ID${RESET_FORMAT}"
echo "   Region:  ${BOLD_TEXT}$REGION${RESET_FORMAT}"
echo "   Zone:    ${BOLD_TEXT}$ZONE${RESET_FORMAT}"
echo

# Enable required services
echo "${BLUE_TEXT}${BOLD_TEXT}⚙️ Enabling required Google Cloud services...${RESET_FORMAT}"
gcloud services enable compute.googleapis.com --project=$DEVSHELL_PROJECT_ID
gcloud services enable container.googleapis.com --project=$DEVSHELL_PROJECT_ID
gcloud services enable containerregistry.googleapis.com --project=$DEVSHELL_PROJECT_ID
gcloud services enable containeranalysis.googleapis.com --project=$DEVSHELL_PROJECT_ID
gcloud services enable binaryauthorization.googleapis.com --project=$DEVSHELL_PROJECT_ID

echo "${YELLOW_TEXT}⏳ Waiting for services to initialize...${RESET_FORMAT}"
sleep 45

# Setup binary auth demo
echo "${BLUE_TEXT}${BOLD_TEXT}📦 Setting up Binary Authorization demo...${RESET_FORMAT}"
gsutil -m cp -r gs://spls/gke-binary-auth/* .
cd gke-binary-auth-demo

gcloud config set compute/region $REGION    
gcloud config set compute/zone $ZONE

chmod +x create.sh
chmod +x delete.sh
chmod 777 validate.sh

sed -i 's/validMasterVersions\[0\]/defaultClusterVersion/g' ./create.sh

# Create cluster
echo "${CYAN_TEXT}${BOLD_TEXT}🏗️ Creating GKE cluster 'my-cluster-1'...${RESET_FORMAT}"
./create.sh -c my-cluster-1

# Validate cluster
echo "${BLUE_TEXT}${BOLD_TEXT}🔍 Validating cluster setup...${RESET_FORMAT}"
./validate.sh -c my-cluster-1

# Configure binary auth policy
echo "${MAGENTA_TEXT}${BOLD_TEXT}🛡️ Configuring Binary Authorization policy...${RESET_FORMAT}"
gcloud beta container binauthz policy export > policy.yaml

cat > policy.yaml <<EOF_CP
defaultAdmissionRule:
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
  evaluationMode: ALWAYS_DENY
globalPolicyEvaluationMode: ENABLE
clusterAdmissionRules:
  $ZONE.my-cluster-1:
    evaluationMode: ALWAYS_ALLOW
    enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
name: projects/$PROJECT_ID/policy
EOF_CP

gcloud beta container binauthz policy import policy.yaml

# Docker setup
echo "${BLUE_TEXT}${BOLD_TEXT}🐳 Configuring Docker and pushing nginx image...${RESET_FORMAT}"
docker pull gcr.io/google-containers/nginx:latest
gcloud auth configure-docker --quiet

PROJECT_ID="$(gcloud config get-value project)"
docker tag gcr.io/google-containers/nginx "gcr.io/${PROJECT_ID}/nginx:latest"
docker push "gcr.io/${PROJECT_ID}/nginx:latest"

gcloud container images list-tags "gcr.io/${PROJECT_ID}/nginx"

# Create nginx pod
echo "${CYAN_TEXT}${BOLD_TEXT}🚀 Creating nginx pod...${RESET_FORMAT}"
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: "gcr.io/${PROJECT_ID}/nginx:latest"
    ports:
    - containerPort: 80
EOF

kubectl get pods
kubectl delete pod nginx

# Update policy to deny all
echo "${RED_TEXT}${BOLD_TEXT}🛑 Updating policy to deny all images...${RESET_FORMAT}"
gcloud beta container binauthz policy export > policy.yaml

cat > policy.yaml <<EOF_CP
defaultAdmissionRule:
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
  evaluationMode: ALWAYS_DENY
globalPolicyEvaluationMode: ENABLE
clusterAdmissionRules:
  $ZONE.my-cluster-1:
    evaluationMode: ALWAYS_DENY
    enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
name: projects/$PROJECT_ID/policy
EOF_CP

gcloud beta container binauthz policy import policy.yaml

# Try creating pod again (should fail)
echo "${YELLOW_TEXT}${BOLD_TEXT}⚠️ Attempting to create pod with denied image...${RESET_FORMAT}"
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: "gcr.io/${PROJECT_ID}/nginx:latest"
    ports:
    - containerPort: 80
EOF

# Check violation logs
echo "${BLUE_TEXT}${BOLD_TEXT}📝 Checking violation logs...${RESET_FORMAT}"
gcloud logging read "resource.type='k8s_cluster' AND protoPayload.response.reason='VIOLATES_POLICY'" --project=$PROJECT_ID

# Add whitelist pattern
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Adding whitelist pattern for nginx image...${RESET_FORMAT}"
IMAGE_PATH=$(echo "gcr.io/${PROJECT_ID}/nginx*")

cat > policy.yaml <<EOF_CP
defaultAdmissionRule:
  enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
  evaluationMode: ALWAYS_DENY
globalPolicyEvaluationMode: ENABLE
clusterAdmissionRules:
  $ZONE.my-cluster-1:
    evaluationMode: ALWAYS_DENY
    enforcementMode: ENFORCED_BLOCK_AND_AUDIT_LOG
admissionWhitelistPatterns:
- namePattern: "gcr.io/${PROJECT_ID}/nginx*"
name: projects/$PROJECT_ID/policy
EOF_CP

gcloud beta container binauthz policy import policy.yaml

# Create pod with whitelisted image
echo "${CYAN_TEXT}${BOLD_TEXT}🚀 Creating pod with whitelisted image...${RESET_FORMAT}"
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: "gcr.io/${PROJECT_ID}/nginx:latest"
    ports:
    - containerPort: 80
EOF

kubectl delete pod nginx

# Setup attestor
echo "${MAGENTA_TEXT}${BOLD_TEXT}🔏 Setting up manual attestor...${RESET_FORMAT}"
ATTESTOR="manually-verified"
ATTESTOR_NAME="Manual Attestor"
ATTESTOR_EMAIL="$(gcloud config get-value core/account)"

NOTE_ID="Human-Attestor-Note"
NOTE_DESC="Human Attestation Note Demo"

NOTE_PAYLOAD_PATH="note_payload.json"
IAM_REQUEST_JSON="iam_request.json"

cat > ${NOTE_PAYLOAD_PATH} << EOF
{
  "name": "projects/${PROJECT_ID}/notes/${NOTE_ID}",
  "attestation_authority": {
    "hint": {
      "human_readable_name": "${NOTE_DESC}"
    }
  }
}
EOF

curl -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $(gcloud auth print-access-token)"  \
    --data-binary @${NOTE_PAYLOAD_PATH}  \
    "https://containeranalysis.googleapis.com/v1beta1/projects/${PROJECT_ID}/notes/?noteId=${NOTE_ID}"

curl -H "Authorization: Bearer $(gcloud auth print-access-token)"  \
    "https://containeranalysis.googleapis.com/v1beta1/projects/${PROJECT_ID}/notes/${NOTE_ID}"

# Generate PGP key
echo "${BLUE_TEXT}${BOLD_TEXT}🔑 Generating PGP key for attestor...${RESET_FORMAT}"
PGP_PUB_KEY="generated-key.pgp"
sudo apt-get install rng-tools -y
sudo rngd -r /dev/urandom -y
gpg --quick-generate-key --yes ${ATTESTOR_EMAIL}
sleep 10
gpg --armor --export "${ATTESTOR_EMAIL}" > ${PGP_PUB_KEY}

# Create attestor
echo "${CYAN_TEXT}${BOLD_TEXT}👤 Creating attestor...${RESET_FORMAT}"
gcloud --project="${PROJECT_ID}" \
    beta container binauthz attestors create "${ATTESTOR}" \
    --attestation-authority-note="${NOTE_ID}" \
    --attestation-authority-note-project="${PROJECT_ID}"

gcloud --project="${PROJECT_ID}" \
    beta container binauthz attestors public-keys add \
    --attestor="${ATTESTOR}" \
    --pgp-public-key-file="${PGP_PUB_KEY}"

gcloud --project="${PROJECT_ID}" \
    beta container binauthz attestors list

# Create attestation
echo "${MAGENTA_TEXT}${BOLD_TEXT}📝 Creating attestation for nginx image...${RESET_FORMAT}"
GENERATED_PAYLOAD="generated_payload.json"
GENERATED_SIGNATURE="generated_signature.pgp"

PGP_FINGERPRINT="$(gpg --list-keys ${ATTESTOR_EMAIL} | head -2 | tail -1 | awk '{print $1}')"

IMAGE_PATH="gcr.io/${PROJECT_ID}/nginx"
IMAGE_DIGEST="$(gcloud container images list-tags --format='get(digest)' $IMAGE_PATH | head -1)"

gcloud beta container binauthz create-signature-payload \
    --artifact-url="${IMAGE_PATH}@${IMAGE_DIGEST}" > ${GENERATED_PAYLOAD}

sleep 5
cat "${GENERATED_PAYLOAD}"

gpg --local-user "${ATTESTOR_EMAIL}" \
    --armor \
    --output ${GENERATED_SIGNATURE} \
    --sign ${GENERATED_PAYLOAD}

sleep 5
cat "${GENERATED_SIGNATURE}"

gcloud beta container binauthz attestations create \
    --artifact-url="${IMAGE_PATH}@${IMAGE_DIGEST}" \
    --attestor="projects/${PROJECT_ID}/attestors/${ATTESTOR}" \
    --signature-file=${GENERATED_SIGNATURE} \
    --public-key-id="${PGP_FINGERPRINT}"

sleep 20

gcloud beta container binauthz attestations list \
    --attestor="projects/${PROJECT_ID}/attestors/${ATTESTOR}"

echo 
echo "projects/${PROJECT_ID}/attestors/${ATTESTOR}"
echo

echo -e "${YELLOW_TEXT}${BOLD_TEXT}Edit Binary Policy at: ${BLUE_TEXT}${UNDERLINE_TEXT}https://console.cloud.google.com/security/binary-authorization/policy?inv=1&invt=AbyETw&project=$DEVSHELL_PROJECT_ID${RESET_FORMAT}"
echo

# Confirmation prompt
while true; do
    echo -ne "${YELLOW_TEXT}${BOLD_TEXT}Do you want to proceed? (Y/n): ${RESET_FORMAT}"
    read confirm
    case "$confirm" in
        [Yy]) 
            echo -e "${BLUE_TEXT}Running the command...${RESET_FORMAT}"
            break
            ;;
        [Nn]|"") 
            echo "Operation canceled."
            break
            ;;
        *) 
            echo -e "${RED_TEXT}Invalid input. Please enter Y or N.${RESET_FORMAT}" 
            ;;
    esac
done

# Final pod creation
echo "${CYAN_TEXT}${BOLD_TEXT}🚀 Creating final nginx pod with attested image...${RESET_FORMAT}"
export PROJECT_ID="$(gcloud config get-value project)"
IMAGE_PATH="gcr.io/${PROJECT_ID}/nginx"
IMAGE_DIGEST="$(gcloud container images list-tags --format='get(digest)' $IMAGE_PATH | head -1)"

cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: "${IMAGE_PATH}@${IMAGE_DIGEST}"
    ports:
    - containerPort: 80
EOF

# Break-glass pod
echo "${RED_TEXT}${BOLD_TEXT}🚨 Creating break-glass pod (bypasses policy)...${RESET_FORMAT}"
cat << EOF | kubectl create -f -
apiVersion: v1
kind: Pod
metadata:
  name: nginx-alpha
  annotations:
    alpha.image-policy.k8s.io/break-glass: "true"
spec:
  containers:
  - name: nginx
    image: "nginx:latest"
    ports:
    - containerPort: 80
EOF

# Check break-glass logs
echo "${BLUE_TEXT}${BOLD_TEXT}📝 Checking break-glass logs...${RESET_FORMAT}"
gcloud logging read "resource.type='k8s_cluster' AND protoPayload.request.metadata.annotations.'alpha.image-policy.k8s.io/break-glass'='true'"

# Cleanup
echo "${RED_TEXT}${BOLD_TEXT}🧹 Cleaning up resources...${RESET_FORMAT}"
./delete.sh -c my-cluster-1
echo "Y" | gcloud container clusters delete my-cluster-1

# Completion message
echo
echo "${CYAN_TEXT}${BOLD_TEXT}============================================${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}🎉  FOLLOW THE VIDEO & COMPLETE WITH ME!  🎉${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}============================================${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}Thank you for following Dr. Abhishek's Cloud Tutorial!${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}For more tutorials, please subscribe to:${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460/videos${RESET_FORMAT}"
echo
