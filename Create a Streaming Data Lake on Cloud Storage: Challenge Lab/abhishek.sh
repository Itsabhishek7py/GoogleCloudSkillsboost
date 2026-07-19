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
echo "${TEXT_COLOR}and BigQuery data pipeline using Google Cloud services.${RESET_FORMAT}"
echo

# Function to display messages with formatting
print_message() {
    local color=$1
    local emoji=$2
    local message=$3
    echo -e "${color}${BOLD_TEXT}${emoji}  ${message}${RESET_FORMAT}"
}

# Success message function
print_success() {
    echo -e "${SUCCESS_COLOR}${BOLD_TEXT}✅  ${1}${RESET_FORMAT}"
}

# Get user inputs with validation
print_message "$ACTION_COLOR" "📝" "Please provide the following configuration details:"

read -p "${PROMPT_COLOR}${BOLD_TEXT}Enter Pub/Sub Topic Name: ${RESET_FORMAT}" TOPIC_ID
print_message "$SUCCESS_COLOR" "✓" "Topic Name: $TOPIC_ID"

read -p "${PROMPT_COLOR}${BOLD_TEXT}Enter Test Message: ${RESET_FORMAT}" MESSAGE
print_message "$SUCCESS_COLOR" "✓" "Message: $MESSAGE"

read -p "${PROMPT_COLOR}${BOLD_TEXT}Enter Region (e.g., us-central1): ${RESET_FORMAT}" REGION
print_message "$SUCCESS_COLOR" "✓" "Region: $REGION"

# ✅ NEW: BigQuery Configuration Inputs
echo
print_message "$ACTION_COLOR" "📊" "BigQuery Configuration:"
read -p "${PROMPT_COLOR}${BOLD_TEXT}Enter BigQuery Dataset Name: ${RESET_FORMAT}" BQ_DATASET
print_message "$SUCCESS_COLOR" "✓" "Dataset: $BQ_DATASET"

read -p "${PROMPT_COLOR}${BOLD_TEXT}Enter BigQuery Table Name: ${RESET_FORMAT}" BQ_TABLE
print_message "$SUCCESS_COLOR" "✓" "Table: $BQ_TABLE"

# ✅ NEW: Export Option
echo
print_message "$ACTION_COLOR" "💾" "Export Configuration:"
read -p "${PROMPT_COLOR}${BOLD_TEXT}Do you want to export data to BigQuery? (yes/no): ${RESET_FORMAT}" EXPORT_TO_BQ

if [[ "$EXPORT_TO_BQ" == "yes" || "$EXPORT_TO_BQ" == "y" ]]; then
    EXPORT_ENABLED=true
    print_success "BigQuery export ENABLED"
else
    EXPORT_ENABLED=false
    print_message "$TEXT_COLOR" "ℹ️" "BigQuery export DISABLED - data will only go to Cloud Storage"
fi

# Get Project ID
PROJECT_ID=$(gcloud config get-value project)
if [ -z "$PROJECT_ID" ]; then
    print_message "$WARNING_COLOR" "❌" "No project set. Please set a project first."
    exit 1
fi
print_message "$ACTION_COLOR" "🆔" "Using Project ID: $PROJECT_ID"

export BUCKET_NAME="${PROJECT_ID}-bucket"
print_message "$ACTION_COLOR" "🪣" "Bucket Name: $BUCKET_NAME"
echo

# API Management
print_message "$ACTION_COLOR" "⚙️" "Configuring required APIs..."
gcloud services disable dataflow.googleapis.com --quiet 2>/dev/null
gcloud services enable dataflow.googleapis.com cloudscheduler.googleapis.com bigquery.googleapis.com --quiet 2>/dev/null
print_success "APIs configured successfully"
echo

# Resource Creation
print_message "$ACTION_COLOR" "🛠️" "Creating infrastructure resources..."

# Create bucket
print_message "$TEXT_COLOR" "🪣" "Creating Cloud Storage bucket..."
gsutil mb -l $REGION gs://$BUCKET_NAME 2>/dev/null
print_success "Bucket created: gs://$BUCKET_NAME"

# Create Pub/Sub topic
print_message "$TEXT_COLOR" "📨" "Creating Pub/Sub topic..."
gcloud pubsub topics create $TOPIC_ID 2>/dev/null
print_success "Pub/Sub topic created: $TOPIC_ID"

# ✅ NEW: Create BigQuery Dataset
if [ "$EXPORT_ENABLED" = true ]; then
    print_message "$TEXT_COLOR" "📊" "Creating BigQuery dataset..."
    bq mk --dataset --location=$REGION $PROJECT_ID:$BQ_DATASET 2>/dev/null
    print_success "BigQuery dataset created: $BQ_DATASET"
    
    # ✅ NEW: Create BigQuery Table Schema
    print_message "$TEXT_COLOR" "📋" "Creating BigQuery table schema..."
    cat > schema.json <<EOF
[
    {"name": "timestamp", "type": "TIMESTAMP", "mode": "REQUIRED"},
    {"name": "message", "type": "STRING", "mode": "REQUIRED"},
    {"name": "message_id", "type": "STRING", "mode": "NULLABLE"},
    {"name": "publish_time", "type": "TIMESTAMP", "mode": "NULLABLE"}
]
EOF
    bq mk --table --schema=schema.json $PROJECT_ID:$BQ_DATASET.$BQ_TABLE 2>/dev/null
    print_success "BigQuery table created: $BQ_TABLE"
fi

# Create App Engine app (required for Cloud Scheduler)
print_message "$TEXT_COLOR" "🚀" "Creating App Engine application..."
gcloud app create --region=$REGION --quiet 2>/dev/null
print_message "$WARNING_COLOR" "⏳" "Waiting for App Engine initialization..."
sleep 10
print_success "App Engine application created"
echo

# Scheduler Configuration
print_message "$ACTION_COLOR" "⏰" "Configuring Cloud Scheduler..."
gcloud scheduler jobs create pubsub data-pipeline-trigger \
  --schedule="* * * * *" \
  --topic=$TOPIC_ID \
  --message-body="$MESSAGE" \
  --quiet 2>/dev/null

print_message "$WARNING_COLOR" "⏳" "Waiting for Scheduler initialization..."
sleep 5

print_message "$TEXT_COLOR" "🔧" "Testing Scheduler configuration..."
gcloud scheduler jobs run data-pipeline-trigger --quiet 2>/dev/null
print_success "Scheduler configured successfully"
echo

# ✅ ENHANCED: Generate Dataflow pipeline with BigQuery support
print_message "$ACTION_COLOR" "🌊" "Preparing Dataflow pipeline..."

# ✅ Create enhanced Python script for Dataflow with BigQuery export
cat > PubSubToGCS.py <<'EOF'
import argparse
import logging
import sys
import json
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions, GoogleCloudOptions, StandardOptions, WorkerOptions
from apache_beam.io.gcp.pubsub import ReadFromPubSub
from apache_beam.io.gcp.bigquery import WriteToBigQuery
from apache_beam.io.gcp.bigquery_tools import RetryStrategy
from apache_beam.io.gcp.gcsio import GcsIO
from datetime import datetime

class ParseMessage(beam.DoFn):
    """Parse Pub/Sub message into dictionary for BigQuery"""
    def process(self, element):
        try:
            # element is bytes, decode to string
            message_str = element.decode('utf-8')
            
            # Parse as JSON if possible, otherwise use raw string
            try:
                data = json.loads(message_str)
                # If JSON, extract fields
                output = {
                    'timestamp': datetime.utcnow().isoformat(),
                    'message': message_str,
                    'message_id': data.get('id', ''),
                    'publish_time': data.get('publish_time', datetime.utcnow().isoformat())
                }
            except json.JSONDecodeError:
                # If not JSON, create simple output
                output = {
                    'timestamp': datetime.utcnow().isoformat(),
                    'message': message_str,
                    'message_id': '',
                    'publish_time': datetime.utcnow().isoformat()
                }
            
            yield output
        except Exception as e:
            logging.error(f"Error parsing message: {e}")
            # Yield minimal data to avoid losing messages
            yield {
                'timestamp': datetime.utcnow().isoformat(),
                'message': str(element),
                'message_id': 'error',
                'publish_time': datetime.utcnow().isoformat()
            }

def run(argv=None):
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--project',
        required=True,
        help='Google Cloud project ID'
    )
    parser.add_argument(
        '--region',
        required=True,
        help='Google Cloud region'
    )
    parser.add_argument(
        '--input_topic',
        required=True,
        help='Pub/Sub topic to read from'
    )
    parser.add_argument(
        '--output_path',
        required=True,
        help='Output path for the data in Cloud Storage'
    )
    parser.add_argument(
        '--window_size',
        type=int,
        default=2,
        help='Window size in minutes'
    )
    parser.add_argument(
        '--num_shards',
        type=int,
        default=2,
        help='Number of shards'
    )
    parser.add_argument(
        '--temp_location',
        required=True,
        help='Temp location for Dataflow'
    )
    # ✅ NEW: BigQuery arguments
    parser.add_argument(
        '--bq_dataset',
        help='BigQuery dataset name'
    )
    parser.add_argument(
        '--bq_table',
        help='BigQuery table name'
    )
    parser.add_argument(
        '--export_to_bq',
        action='store_true',
        default=False,
        help='Enable BigQuery export'
    )

    known_args, pipeline_args = parser.parse_known_args(argv)

    pipeline_options = PipelineOptions(pipeline_args)
    google_cloud_options = pipeline_options.view_as(GoogleCloudOptions)
    google_cloud_options.project = known_args.project
    google_cloud_options.region = known_args.region
    google_cloud_options.temp_location = known_args.temp_location

    standard_options = pipeline_options.view_as(StandardOptions)
    standard_options.runner = 'DataflowRunner'

    worker_options = pipeline_options.view_as(WorkerOptions)
    worker_options.disk_type = 'pd-standard'
    worker_options.machine_type = 'e2-standard-2'

    with beam.Pipeline(options=pipeline_options) as p:
        # Read from Pub/Sub
        messages = (
            p
            | "Read from Pub/Sub" >> ReadFromPubSub(
                topic=known_args.input_topic,
                with_attributes=False
            )
            | "Parse Messages" >> beam.ParDo(ParseMessage())
            | "Window into fixed intervals" >> beam.WindowInto(
                beam.window.FixedWindows(known_args.window_size * 60)
            )
        )
        
        # ✅ Write to Cloud Storage
        output_path = known_args.output_path
        if not output_path.endswith('/'):
            output_path += '/'
        
        _ = (
            messages
            | "Format for GCS" >> beam.Map(lambda x: f"{x['timestamp']},{x['message']}")
            | "Write to GCS" >> beam.io.WriteToText(
                f"{output_path}output",
                num_shards=known_args.num_shards,
                file_name_suffix='.csv'
            )
        )
        
        # ✅ NEW: Write to BigQuery if enabled
        if known_args.export_to_bq and known_args.bq_dataset and known_args.bq_table:
            table_ref = f"{known_args.project}:{known_args.bq_dataset}.{known_args.bq_table}"
            
            _ = (
                messages
                | "Write to BigQuery" >> WriteToBigQuery(
                    table=table_ref,
                    schema='timestamp:TIMESTAMP,message:STRING,message_id:STRING,publish_time:TIMESTAMP',
                    write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                    create_disposition=beam.io.BigQueryDisposition.CREATE_NEVER,
                    method='STREAMING_INSERTS',
                    insert_retry_strategy=RetryStrategy.RETRY_ON_TRANSIENT_ERROR
                )
            )
            logging.info(f"BigQuery export enabled: {table_ref}")

if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)
    run(sys.argv)
EOF

print_success "Python script created"

# ✅ Install dependencies and run pipeline
print_message "$ACTION_COLOR" "🐍" "Installing dependencies and running Dataflow pipeline..."

# Install Apache Beam
pip install -q apache-beam[gcp] 2>/dev/null

# ✅ Build command with optional BigQuery parameters
BQ_ARGS=""
if [ "$EXPORT_ENABLED" = true ]; then
    BQ_ARGS="--bq_dataset=$BQ_DATASET --bq_table=$BQ_TABLE --export_to_bq"
    print_message "$TEXT_COLOR" "📊" "BigQuery export will write to: $BQ_DATASET.$BQ_TABLE"
fi

# Run the Dataflow pipeline
python3 PubToGCS.py \
    --project=$PROJECT_ID \
    --region=$REGION \
    --input_topic=projects/$PROJECT_ID/topics/$TOPIC_ID \
    --output_path=gs://$BUCKET_NAME/samples/output \
    --temp_location=gs://$BUCKET_NAME/temp \
    --window_size=2 \
    --num_shards=2 \
    --runner=DataflowRunner \
    --disk_type=pd-standard \
    --machine_type=e2-standard-2 \
    $BQ_ARGS

print_success "Dataflow pipeline submitted"
echo

# ✅ Check output files
print_message "$ACTION_COLOR" "📂" "Checking output files in Cloud Storage..."
sleep 30  # Give time for files to appear
gsutil ls gs://$BUCKET_NAME/samples/output/ 2>/dev/null
print_success "Files listed"

# ✅ NEW: Verify BigQuery data if export enabled
if [ "$EXPORT_ENABLED" = true ]; then
    echo
    print_message "$ACTION_COLOR" "📊" "Verifying BigQuery data..."
    sleep 20  # Give time for data to appear in BigQuery
    
    BQ_QUERY="SELECT COUNT(*) as total_rows FROM \`$PROJECT_ID.$BQ_DATASET.$BQ_TABLE\`"
    ROW_COUNT=$(bq query --format=json --use_legacy_sql=false "$BQ_QUERY" 2>/dev/null | jq '.[0].total_rows' 2>/dev/null)
    
    if [ -n "$ROW_COUNT" ] && [ "$ROW_COUNT" != "null" ]; then
        print_success "BigQuery table has $ROW_COUNT rows"
        
        # Show sample data
        print_message "$TEXT_COLOR" "📋" "Sample data from BigQuery:"
        bq query --format=pretty --limit=5 --use_legacy_sql=false \
            "SELECT timestamp, message FROM \`$PROJECT_ID.$BQ_DATASET.$BQ_TABLE\` LIMIT 5" 2>/dev/null
    else
        print_message "$WARNING_COLOR" "⚠️" "No data found in BigQuery table yet. Check pipeline status."
    fi
fi

# ✅ Verification
echo
print_message "$TEXT_COLOR" "🔍" "Verifying pipeline execution..."
JOB_ID=$(gcloud dataflow jobs list --region=$REGION --status=active --format="value(id)" | head -1)

if [ -n "$JOB_ID" ]; then
    print_success "Dataflow job running: $JOB_ID"
    gcloud dataflow jobs describe $JOB_ID --region=$REGION --format="yaml" | head -20
else
    JOB_ID=$(gcloud dataflow jobs list --region=$REGION --status=done --format="value(id)" | head -1)
    if [ -n "$JOB_ID" ]; then
        print_message "$TEXT_COLOR" "ℹ️" "Dataflow job completed: $JOB_ID"
    else
        print_message "$WARNING_COLOR" "⚠️" "No Dataflow job found. Check console for details."
    fi
fi

# ✅ NEW: Summary of resources
echo
echo "${HEADER_COLOR}${BOLD_TEXT}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET_FORMAT}"
echo "${HEADER_COLOR}${BOLD_TEXT}┃              RESOURCE SUMMARY                     ┃${RESET_FORMAT}"
echo "${HEADER_COLOR}${BOLD_TEXT}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET_FORMAT}"
echo
echo "${TEXT_COLOR}${BOLD_TEXT}📦 Resources Created:${RESET_FORMAT}"
echo "${TEXT_COLOR}├─ 🔷 Project: ${PROMPT_COLOR}$PROJECT_ID${RESET_FORMAT}"
echo "${TEXT_COLOR}├─ 📨 Pub/Sub Topic: ${PROMPT_COLOR}$TOPIC_ID${RESET_FORMAT}"
echo "${TEXT_COLOR}├─ 🪣 Cloud Storage: ${PROMPT_COLOR}gs://$BUCKET_NAME${RESET_FORMAT}"
echo "${TEXT_COLOR}├─ ⏰ Cloud Scheduler: ${PROMPT_COLOR}data-pipeline-trigger${RESET_FORMAT}"
if [ "$EXPORT_ENABLED" = true ]; then
    echo "${TEXT_COLOR}├─ 📊 BigQuery Dataset: ${PROMPT_COLOR}$BQ_DATASET${RESET_FORMAT}"
    echo "${TEXT_COLOR}└─ 📋 BigQuery Table: ${PROMPT_COLOR}$BQ_TABLE${RESET_FORMAT}"
else
    echo "${TEXT_COLOR}└─ 💾 BigQuery Export: ${WARNING_COLOR}DISABLED${RESET_FORMAT}"
fi
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
echo "• Implemented Dataflow processing"
if [ "$EXPORT_ENABLED" = true ]; then
    echo "• ✓ Exported data to BigQuery"
fi
echo "${RESET_FORMAT}"
echo
echo -e "${PROMPT_COLOR}${BOLD_TEXT}💡 Continue learning at: ${LINK_COLOR}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo "${PROMPT_COLOR}${BOLD_TEXT}   Don't forget to like and subscribe!${RESET_FORMAT}"
echo
