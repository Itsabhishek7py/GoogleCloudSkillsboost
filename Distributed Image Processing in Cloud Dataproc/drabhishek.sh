#!/bin/bash

clear
echo "=============================================="
echo "🎉 WELCOME TO DR ABHISHEK TUTORIAL 🎉"
echo "Subscribe 👉 https://www.youtube.com/@drabhishek.5460/videos"
echo "=============================================="

# =============================
# ENTER REGION
# =============================

read -p "Enter Dataproc REGION (example: us-central1): " REGION
export REGION=$REGION
gcloud config set dataproc/region $REGION

# =============================
# INSTALL REQUIRED SOFTWARE
# =============================

echo "Installing Scala & SBT..."

sudo apt-get update -y
sudo apt-get install -y dirmngr unzip apt-transport-https bc scala

echo "Adding SBT repository..."

echo "deb https://repo.scala-sbt.org/scalasbt/debian all main" | sudo tee /etc/apt/sources.list.d/sbt.list
echo "deb https://repo.scala-sbt.org/scalasbt/debian /" | sudo tee /etc/apt/sources.list.d/sbt_old.list

curl -sL https://keyserver.ubuntu.com/pks/lookup?op=get\&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823 | sudo apt-key add -
sudo apt-get update -y
sudo apt-get install -y sbt

echo "Software Installed ✅"

# =============================
# DOWNLOAD & BUILD PROJECT
# =============================

echo "Downloading Dataproc lab files..."

gsutil cp gs://spls/gsp124/cloud-dataproc.zip .
unzip cloud-dataproc.zip
cd cloud-dataproc/codelabs/opencv-haarcascade

echo "Building Fat JAR (5-10 minutes)..."
sbt assembly

echo "Build Completed ✅"

# =============================
# CREATE CLOUD STORAGE BUCKET
# =============================

MYBUCKET="${USER//google}-image-${RANDOM}"
export MYBUCKET

echo "Creating bucket: $MYBUCKET"
gsutil mb gs://${MYBUCKET}

# =============================
# UPLOAD SAMPLE IMAGES
# =============================

echo "Uploading images..."

curl https://www.publicdomainpictures.net/pictures/20000/velka/family-of-three-871290963799xUk.jpg | gsutil cp - gs://${MYBUCKET}/imgs/family-of-three.jpg

curl https://www.publicdomainpictures.net/pictures/10000/velka/african-woman-331287912508yqXc.jpg | gsutil cp - gs://${MYBUCKET}/imgs/african-woman.jpg

curl https://www.publicdomainpictures.net/pictures/10000/velka/296-1246658839vCW7.jpg | gsutil cp - gs://${MYBUCKET}/imgs/classroom.jpg

echo "Images Uploaded ✅"

# =============================
# CREATE DATAPROC CLUSTER
# =============================

MYCLUSTER="${USER/_/-}-qwiklab"
export MYCLUSTER

echo "Creating Dataproc Cluster..."

gcloud dataproc clusters create ${MYCLUSTER} \
    --region=$REGION \
    --bucket=${MYBUCKET} \
    --worker-machine-type=e2-standard-2 \
    --master-machine-type=e2-standard-2 \
    --initialization-actions=gs://spls/gsp010/install-libgtk.sh \
    --image-version=2.0 \
    --worker-boot-disk-size=30GB \
    --master-boot-disk-size=30GB

echo "Cluster Created ✅"

# =============================
# ninja hattori hu mai
# =============================

curl https://raw.githubusercontent.com/opencv/opencv/master/data/haarcascades/haarcascade_frontalface_default.xml | gsutil cp - gs://${MYBUCKET}/haarcascade_frontalface_default.xml

# =============================
# SUBMIT SPARK JOB
# =============================

echo "Submitting Spark Job..."

gcloud dataproc jobs submit spark \
--region=$REGION \
--cluster=${MYCLUSTER} \
--jar target/scala-2.12/feature_detector-assembly-1.0.jar -- \
gs://${MYBUCKET}/haarcascade_frontalface_default.xml \
gs://${MYBUCKET}/imgs/ \
gs://${MYBUCKET}/out/

echo "🎉 ALL TASKS COMPLETED SUCCESSFULLY 🎉"
echo "Check results at: gs://${MYBUCKET}/out/"
