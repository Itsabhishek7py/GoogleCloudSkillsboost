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


echo
echo "${HEADER_COLOR}${BOLD_TEXT}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET_FORMAT}"
echo "${TITLE_COLOR}${BOLD_TEXT}       🎓 DR. ABHISHEK'S DATAPLEX TUTORIAL      ${RESET_FORMAT}"
echo "${HEADER_COLOR}${BOLD_TEXT}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET_FORMAT}"
echo
echo "${TEXT_COLOR}This lab demonstrates Google Cloud Dataplex operations including${RESET_FORMAT}"
echo "${TEXT_COLOR}lake, zone, and asset creation and management.${RESET_FORMAT}"
echo

# Region selection with validation
print_message() {
    local color=$1
    local emoji=$2
    local message=$3
    echo -e "${color}${BOLD_TEXT}${emoji}  ${message}${RESET_FORMAT}"
}

print_error() {
    local message=$1
    print_message "$WARNING_COLOR" "❌" "${message}"
}

print_success() {
    local message=$1
    print_message "$SUCCESS_COLOR" "✓" "${message}"
}

# Get region from user
print_message "$ACTION_COLOR" "🌍" "Configuring region..."
read -p "${PROMPT_COLOR}${BOLD_TEXT}Enter your GCP region (e.g., us-central1): ${RESET_FORMAT}" REGION

if [[ -z "$REGION" ]]; then
    print_error "Region cannot be empty. Using default 'us-central1'"
    REGION="us-central1"
fi

export REGION
print_success "Region set to: $REGION"
echo

# Enable Dataplex API
print_message "$ACTION_COLOR" "⚙️" "Enabling Dataplex API..."
gcloud services enable dataplex.googleapis.com
print_success "Dataplex API enabled"
echo

# Create Dataplex Lake
print_message "$ACTION_COLOR" "🏞️" "Creating Dataplex Lake 'sensors'..."
gcloud alpha dataplex lakes create sensors \
    --location=$REGION \
    --labels=k1=v1,k2=v2,k3=v3
print_success "Lake 'sensors' created successfully"
echo

# Create Dataplex Zone
print_message "$ACTION_COLOR" "🗺️" "Creating Zone 'temperature-raw-data'..."
gcloud alpha dataplex zones create temperature-raw-data \
    --location=$REGION \
    --lake=sensors \
    --resource-location-type=SINGLE_REGION \
    --type=RAW
print_success "Zone 'temperature-raw-data' created successfully"
echo

# Create Storage Bucket
print_message "$ACTION_COLOR" "🪣" "Creating Storage Bucket..."
gsutil mb -l $REGION gs://$DEVSHELL_PROJECT_ID
print_success "Bucket created: gs://$DEVSHELL_PROJECT_ID"
echo

# Create Dataplex Asset
print_message "$ACTION_COLOR" "📦" "Creating Asset 'measurements'..."
gcloud dataplex assets create measurements \
    --location=$REGION \
    --lake=sensors \
    --zone=temperature-raw-data \
    --resource-type=STORAGE_BUCKET \
    --resource-name=projects/$DEVSHELL_PROJECT_ID/buckets/$DEVSHELL_PROJECT_ID
print_success "Asset 'measurements' created successfully"
echo

# Cleanup section
echo "${HEADER_COLOR}${BOLD_TEXT}┏━━━━━━━━━━━━━━━━ CLEANUP PROCESS ━━━━━━━━━━━━━━━━┓${RESET_FORMAT}"
echo

# Delete Dataplex Asset
print_message "$WARNING_COLOR" "🧹" "Cleaning up Asset 'measurements'..."
gcloud dataplex assets delete measurements \
    --zone=temperature-raw-data \
    --lake=sensors \
    --location=$REGION \
    --quiet
print_success "Asset deleted successfully"
echo

# Delete Dataplex Zone
print_message "$WARNING_COLOR" "🧹" "Cleaning up Zone 'temperature-raw-data'..."
gcloud dataplex zones delete temperature-raw-data \
    --lake=sensors \
    --location=$REGION \
    --quiet
print_success "Zone deleted successfully"
echo

# Delete Dataplex Lake
print_message "$WARNING_COLOR" "🧹" "Cleaning up Lake 'sensors'..."
gcloud dataplex lakes delete sensors \
    --location=$REGION \
    --quiet
print_success "Lake deleted successfully"
echo

# Script cleanup
print_message "$WARNING_COLOR" "🧹" "Performing script cleanup..."
SCRIPT_NAME="dataplex-lab.sh"
if [ -f "$SCRIPT_NAME" ]; then
    rm -- "$SCRIPT_NAME"
    print_success "Temporary files cleaned up"
else
    print_error "Script file not found for cleanup"
fi

# Completion message
echo
echo "${HEADER_COLOR}${BOLD_TEXT}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${RESET_FORMAT}"
echo "${SUCCESS_COLOR}${BOLD_TEXT}          🎉 LAB COMPLETED SUCCESSFULLY! 🎉         ${RESET_FORMAT}"
echo "${HEADER_COLOR}${BOLD_TEXT}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${RESET_FORMAT}"
echo
echo "${TEXT_COLOR}${BOLD_TEXT}You've successfully completed these Dataplex operations:${RESET_FORMAT}"
echo "${TEXT_COLOR}• Created and configured a Dataplex Lake"
echo "• Established a Dataplex Zone"
echo "• Created and managed Cloud Storage assets"
echo "• Performed proper resource cleanup${RESET_FORMAT}"
echo
echo -e "${PROMPT_COLOR}${BOLD_TEXT}💡 Continue learning at: ${LINK_COLOR}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo "${PROMPT_COLOR}${BOLD_TEXT}   Don't forget to like and subscribe!${RESET_FORMAT}"
echo
