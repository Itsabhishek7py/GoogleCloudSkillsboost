#!/bin/bash

# Professional Color Scheme
HEADER_COLOR=$'\033[38;5;54m'       # Deep purple
TITLE_COLOR=$'\033[38;5;93m'         # Bright purple
PROMPT_COLOR=$'\033[38;5;178m'       # Gold
ACTION_COLOR=$'\033[38;5;44m'        # Teal
SUCCESS_COLOR=$'\033[38;5;46m'       # Bright green
WARNING_COLOR=$'\033[38;5;196m'      # Bright red
LINK_COLOR=$'\033[38;5;27m'          # Blue
TEXT_COLOR=$'\033[38;5;255m'         # Bright white

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# Welcome message with enhanced design
echo
echo "${HEADER_COLOR}${BOLD_TEXT}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET_FORMAT}"
echo "${TITLE_COLOR}${BOLD_TEXT}       🎓 DR. ABHISHEK'S DATA PIPELINE WORKSHOP      ${RESET_FORMAT}"
echo "${HEADER_COLOR}${BOLD_TEXT}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET_FORMAT}"
echo
echo "${TEXT_COLOR}This lab demonstrates a complete Pub/Sub to Cloud Storage${RESET_FORMAT}"
echo "${TEXT_COLOR}data pipeline using Google Cloud services.${RESET_FORMAT}"
echo

# Function to display messages with formatting
print_message() {
    local color=$1
    local emoji=$2
    local message=$3
    echo -e "${color}${BOLD_TEXT}${emoji}  ${message}${RESET_FORMAT}"
}

# Get user inputs with validation
print_message "$ACTION_COLOR" "📝" "Please provide the following configuration details:"

read -p "${PROMPT_COLOR}${BOLD_TEXT}Enter Pub/Sub Topic Name: ${RESET_FORMAT}" TOPIC_ID
print_message "$SUCCESS_COLOR" "✓" "Topic Name: $TOPIC_ID"

read -p "${PROMPT_COLOR}${BOLD_TEXT}Enter Test Message: ${RESET_FORMAT}" MESSAGE
print_message "$SUCCESS_COLOR" "✓" "Message: $MESSAGE"

read -p "${PROMPT_COLOR}${BOLD_TEXT}Enter Region (e.g., us-central1): ${RESET_FORMAT}" REGION
print_message "$SUCCESS_COLOR" "✓" "Region: $REGION"

PROJECT_ID=$(gcloud config get-value project)
print_message "$ACTION_COLOR" "🆔" "Using Project ID: $PROJECT_ID"

export BUCKET_NAME="${PROJECT_ID}-bucket"
print_message "$ACTION_COLOR" "🪣" "Bucket Name: $BUCKET_NAME"
echo

# API Management
print_message "$ACTION_COLOR" "⚙️" "Configuring required APIs..."
gcloud services disable dataflow.googleapis.com --quiet
gcloud services enable dataflow.googleapis.com cloudscheduler.googleapis.com --quiet
print_success "APIs configured successfully"
echo

# Resource Creation
print_message "$ACTION_COLOR" "🛠️" "Creating infrastructure resources..."

print_message "$TEXT_COLOR" "🪣" "Creating Cloud Storage bucket..."
gsutil mb -l $REGION gs://$BUCKET_NAME

print_message "$TEXT_COLOR" "📨" "Creating Pub/Sub topic..."
gcloud pubsub topics create $TOPIC_ID

print_message "$TEXT_COLOR" "🚀" "Creating App Engine application..."
gcloud app create --region=$REGION --quiet

print_message "$WARNING_COLOR" "⏳" "Waiting for App Engine initialization..."
sleep 100
print_success "Infrastructure resources created successfully"
echo

# Scheduler Configuration
print_message "$ACTION_COLOR" "⏰" "Configuring Cloud Scheduler..."
gcloud scheduler jobs create pubsub data-pipeline-trigger \
  --schedule="* * * * *" \
  --topic=$TOPIC_ID \
  --message-body="$MESSAGE" \
  --quiet

print_message "$WARNING_COLOR" "⏳" "Waiting for Scheduler initialization..."
sleep 20

print_message "$TEXT_COLOR" "🔧" "Testing Scheduler configuration..."
gcloud scheduler jobs run data-pipeline-trigger --quiet
print_success "Scheduler configured successfully"
echo

# Dataflow Pipeline Setup
print_message "$ACTION_COLOR" "🌊" "Preparing Dataflow pipeline..."

cat > run_pipeline.sh <<EOF
#!/bin/bash

# Environment configuration
export PROJECT_ID=$PROJECT_ID
export REGION=$REGION
export TOPIC_ID=$TOPIC_ID
export BUCKET_NAME=$BUCKET_NAME

# Clone samples repository
git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
cd python-docs-samples/pubsub/streaming-analytics

# Install dependencies
pip install -U -r requirements.txt

# Execute pipeline
python PubSubToGCS.py \\
  --project=\$PROJECT_ID \\
  --region=\$REGION \\
  --input_topic=projects/\$PROJECT_ID/topics/\$TOPIC_ID \\
  --output_path=gs://\$BUCKET_NAME/samples/output \\
  --runner=DataflowRunner \\
  --window_size=2 \\
  --num_shards=2 \\
  --temp_location=gs://\$BUCKET_NAME/temp
EOF

chmod +x run_pipeline.sh
print_success "Pipeline script prepared"
echo

# Docker Execution
print_message "$ACTION_COLOR" "🐳" "Running pipeline in Docker container..."
docker run -it \
  -e DEVSHELL_PROJECT_ID=$DEVSHELL_PROJECT_ID \
  -v "$(pwd)/run_pipeline.sh:/run_pipeline.sh" \
  python:3.7 \
  /bin/bash -c "/run_pipeline.sh"
print_success "Pipeline execution initiated"
echo

# Completion message
echo "${HEADER_COLOR}${BOLD_TEXT}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET_FORMAT}"
echo "${SUCCESS_COLOR}${BOLD_TEXT}          🎉 LAB COMPLETED SUCCESSFULLY! 🎉         ${RESET_FORMAT}"
echo "${HEADER_COLOR}${BOLD_TEXT}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET_FORMAT}"
echo
echo "${TEXT_COLOR}${BOLD_TEXT}You've successfully completed these operations:${RESET_FORMAT}"
echo "${TEXT_COLOR}• Configured Pub/Sub messaging"
echo "• Established Cloud Storage integration"
echo "• Created a scheduled data pipeline"
echo "• Implemented Dataflow processing${RESET_FORMAT}"
echo
echo -e "${PROMPT_COLOR}${BOLD_TEXT}💡 Continue learning at: ${LINK_COLOR}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo "${PROMPT_COLOR}${BOLD_TEXT}   Don't forget to like and subscribe!${RESET_FORMAT}"
echo
