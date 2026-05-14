#!/bin/bash

echo "╔══════════════════════════════════════════════════╗"
echo "║          Welcome to Dr Abhishek Cloud  Tutorial!     ║"
echo "║  Let's start meanwhile hit the like button       ║"
echo "║  And subscribe to the channel.      ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
echo "📢 Don't forget to subscribe to Dr. Abhishek's YouTube channel:"
echo "   https://www.youtube.com/@drabhishek.5460/videos"
echo "   for more great Google Cloud content!"
echo ""

# Prompt for region if not already set
if [ -z "$REGION" ]; then
  echo "🌍 Please enter your preferred region (e.g., us-central1, europe-west1):"
  read -p "Region: " REGION
  export REGION
  echo "✅ Region set to: $REGION"
else
  echo "🌍 Using pre-configured region: $REGION"
fi

# Set gcloud configuration
echo ""
echo "⚙️ Configuring gcloud settings..."
gcloud config set compute/region $REGION
gcloud config set project $DEVSHELL_PROJECT_ID

# Enable App Engine API
echo ""
echo "🔌 Enabling App Engine API..."
gcloud services enable appengine.googleapis.com

# Clone sample code
echo ""
echo "📦 Cloning sample Go application..."
git clone https://github.com/GoogleCloudPlatform/golang-samples.git

# Change directory and install requirements
echo ""
echo "📂 Setting up the application..."
cd golang-samples/appengine/go11x/helloworld
sudo apt-get install -y google-cloud-sdk-app-engine-go

# Create App Engine app
echo ""
echo "🚀 Creating App Engine application in region: $REGION"
gcloud app create --region=$REGION

# Deploy the application
echo ""
echo "🛠️ Deploying the application..."
gcloud app deploy --quiet


echo ""
echo "🎉 Deployment complete! Your app is now live."
echo "👉 Access it using: gcloud app browse"
echo ""
echo "📢 Remember to subscribe to Dr. Abhishek's YouTube channel:"
echo "   https://www.youtube.com/@drabhishek.5460/videos"
echo "   for more Google Cloud tutorials and tips!"
