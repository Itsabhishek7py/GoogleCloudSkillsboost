## `Lab Name` - *Accessing the Google Cloud Console and Cloud Shell*

## [YouTube Solution Link](https://youtu.be/rHkSKRdZFIM)

Run the below commands in the cloud shell terminal

```
gcloud auth list
gcloud config list project 
```

```
export USERNAME=
export REGION=
export ZONE=
export BUCKET_NAME=
export BUCKET_NAME_2=
```

## Task 1. Explore the Google Cloud console

```
gcloud storage buckets create gs://$BUCKET_NAME --location=$REGION


gcloud compute instances create first-vm --zone=$ZONE --machine-type=e2-micro --tags=http-server

gcloud iam service-accounts create test-service-account --display-name="test-service-account"

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member serviceAccount:test-service-account@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com --role roles/editor
```

## Task 2. Explore Cloud Shell

```
gcloud storage buckets create gs://$BUCKET_NAME_2 --location=$REGION

gcloud compute zones list | grep $REGION

gcloud config set compute/zone $ZONE

MY_VMNAME=second-vm

gcloud compute instances create $MY_VMNAME \
--machine-type "e2-standard-2" \
--image-project "debian-cloud" \
--image-family "debian-11" \
--subnet "default"

gcloud iam service-accounts create test-service-account2 --display-name "test-service-account2"

gcloud projects add-iam-policy-binding $GOOGLE_CLOUD_PROJECT --member serviceAccount:test-service-account2@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com --role roles/viewer
```

## Task 3. Work with Cloud Storage in Cloud Shell

```
# Task 3

gcloud storage cp gs://cloud-training/ak8s/cat.jpg cat.jpg

gcloud storage cp cat.jpg gs://$BUCKET_NAME

gcloud storage cp gs://$BUCKET_NAME/cat.jpg gs://$BUCKET_NAME_2/cat.jpg

gcloud storage buckets add-iam-policy-binding gs://$BUCKET_NAME \
--member=allUsers \
--role=roles/storage.objectViewer
```

## Task 4. Explore the Cloud Shell Editor

* Follow the video carefully.

# Congratulations🎉! You're all done with this Lab.

Connect with fellow cloud enthusiasts, ask questions, and share your learning journey.  

[![Telegram](https://img.shields.io/badge/Telegram_Group-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/+gBcgRTlZLyM4OGI1)  
[![YouTube](https://img.shields.io/badge/Subscribe-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@drabhishek.5460?sub_confirmation=1)  
[![Instagram](https://img.shields.io/badge/Follow-%23E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/drabhishek.5460/) 
