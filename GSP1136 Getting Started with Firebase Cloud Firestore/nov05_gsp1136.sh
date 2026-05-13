#!/bin/bash
## Created by nov05, 2026-05-11  

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

cat << 'EOF'

========================================================
Task 1. Setting Database Security Rules
========================================================

EOF
gcloud config set project qwiklabs-gcp-00-8418d4eb8bd8
mkdir firebase-project && cd $_

cat << EOF > firebase.json
{
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  }
}
EOF

cat << EOF > firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
EOF

cat << EOF > firestore.indexes.json
{
  "indexes": [],
  "fieldOverrides": []
}
EOF

firebase deploy --only firestore:rules --project qwiklabs-gcp-00-8418d4eb8bd8

cat << 'EOF'

========================================================
Task 2. Configuring the Firebase Environment
========================================================

EOF
npm init -y
npm i firebase

cat << 'EOF'

========================================================
Task 3. Creating a Firebase Application
========================================================

EOF
mkdir src

cat << 'EOF' > src/index.js
import { initializeApp } from 'firebase/app'

// Add your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyDi3G_w06a-sky-C6UplmQtV5VMBWsHyxI",
  authDomain: "qwiklabs-gcp-00-8418d4eb8bd8.firebaseapp.com",
  projectId: "qwiklabs-gcp-00-8418d4eb8bd8",
  storageBucket: "qwiklabs-gcp-00-8418d4eb8bd8.firebasestorage.app",
  messagingSenderId: "861383021586",
  appId: "1:861383021586:web:a5330da807b0fb620874cb",
  measurementId: ""
};

// Initialize Firebase
const firebaseApp = initializeApp(firebaseConfig);

console.log('Hello, Firestore!')
EOF

cat << 'EOF' > src/index.html 
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Getting Started with Firebase Cloud Firestore</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 flex flex-col items-center justify-center min-h-screen p-4">
    <div class="bg-white p-8 rounded-lg shadow-md max-w-md w-full">
        <h1 class="text-3xl font-bold text-gray-800 mb-4 text-center">Getting started with Firebase Cloud Firestore</h1>
        <p class="text-gray-600 mb-6 text-center">
            I probably won't even put anything in here! So check out the JavaScript console using DevTools.
        </p>
        <p id="dbTitle" class="text-lg font-semibold text-blue-600 mb-2"></p>
        <p id="dbDescription" class="text-gray-700"></p>
    </div>

    <script src="main.js"></script>
</body>
</html>
EOF
