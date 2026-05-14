#!/bin/bash


# Modern Color Definitions
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

BG_BLACK=$(tput setab 0)
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)
BG_MAGENTA=$(tput setab 5)
BG_CYAN=$(tput setab 6)
BG_WHITE=$(tput setab 7)

BOLD=$(tput bold)
RESET=$(tput sgr0)

# Box Drawing Characters
BOX_TOP="${CYAN}╔════════════════════════════════════════════╗${RESET}"
BOX_MID="${CYAN}║                                            ║${RESET}"
BOX_BOT="${CYAN}╚════════════════════════════════════════════╝${RESET}"

# Header with Dr. Abhishek branding
clear
echo -e "${BOX_TOP}"
echo -e "${CYAN}║   🚀 Dr. Abhishek's Pub/Sub Automation Lab   ║${RESET}"
echo -e "${BOX_BOT}"
echo
echo -e "${WHITE}📺 YouTube: ${BLUE}https://youtube.com/@drabhishek.5460${RESET}"
echo -e "${WHITE}⭐ Subscribe for more Cloud & DevOps tutorials! ⭐${RESET}"
echo

# Function to run form 1 code
run_form_1() {
    echo -e "${GREEN}${BOLD}⚙️ Setting up Basic Pub/Sub with Scheduler${RESET}"
    
    echo -e "${YELLOW}Enabling Cloud Scheduler API...${RESET}"
    gcloud services enable cloudscheduler.googleapis.com
    
    echo -e "${YELLOW}Creating Pub/Sub topic...${RESET}"
    gcloud pubsub topics create cloud-pubsub-topic
    
    echo -e "${YELLOW}Creating subscription...${RESET}"
    gcloud pubsub subscriptions create 'cloud-pubsub-subscription' --topic=cloud-pubsub-topic
    
    echo -e "${YELLOW}Creating scheduled job...${RESET}"
    gcloud scheduler jobs create pubsub cron-scheduler-job \
        --schedule="* * * * *" --topic=cron-job-pubsub-topic \
        --message-body="Hello World!" --location=$REGION
    
    echo -e "${YELLOW}Pulling messages...${RESET}"
    gcloud pubsub subscriptions pull cron-job-pubsub-subscription --limit 5
}

# Function to run form 2 code
run_form_2() {
    echo -e "${GREEN}${BOLD}⚙️ Setting up Advanced Pub/Sub with Schema${RESET}"
    
    echo -e "${YELLOW}Creating Avro schema...${RESET}"
    gcloud beta pubsub schemas create city-temp-schema \
        --type=avro \
        --definition='{
            "type": "record",
            "name": "Avro",
            "fields": [
                {"name": "city", "type": "string"},
                {"name": "temperature", "type": "double"},
                {"name": "pressure", "type": "int"},
                {"name": "time_position", "type": "string"}
            ]
        }'

    echo -e "${YELLOW}Creating schema-enabled topic...${RESET}"
    gcloud pubsub topics create temp-topic \
        --message-encoding=JSON \
        --message-storage-policy-allowed-regions=$REGION \
        --schema=projects/$DEVSHELL_PROJECT_ID/schemas/temperature-schema

    echo -e "${YELLOW}Setting up Cloud Function...${RESET}"
    mkdir -p abhishek && cd abhishek || exit

    cat >index.js <<'EOF_END'
/**
* Triggered from a message on a Cloud Pub/Sub topic.
*
* @param {!Object} event Event payload.
* @param {!Object} context Metadata for the event.
*/
exports.helloPubSub = (event, context) => {
  const message = event.data
    ? Buffer.from(event.data, 'base64').toString()
    : 'Hello, World';
  console.log(message);
};
EOF_END

    cat >package.json <<'EOF_END'
{
  "name": "sample-pubsub",
  "version": "0.0.1",
  "dependencies": {
    "@google-cloud/pubsub": "^0.18.0"
  }
}
EOF_END

    deploy_function() {
        gcloud functions deploy gcf-pubsub \
            --trigger-topic=gcf-topic \
            --runtime=nodejs20 \
            --gen2 \
            --entry-point=helloPubSub \
            --source=. \
            --region=$REGION
    }

    echo -e "${YELLOW}Deploying Cloud Function (may take a few minutes)...${RESET}"
    deploy_success=false
    while [ "$deploy_success" = false ]; do
        if deploy_function; then
            echo -e "${GREEN}✅ Function deployed successfully!${RESET}"
            deploy_success=true
        else
            echo -e "${YELLOW}⏳ Waiting for deployment to complete...${RESET}"
            sleep 20
        fi
    done
}

# Function to run form 3 code
run_form_3() {
    echo -e "${GREEN}${BOLD}⚙️ Setting up Pub/Sub with Snapshots${RESET}"
    
    echo -e "${YELLOW}Creating subscription...${RESET}"
    gcloud pubsub subscriptions create pubsub-subscription-message --topic gcloud-pubsub-topic
    
    echo -e "${YELLOW}Publishing test message...${RESET}"
    gcloud pubsub topics publish gcloud-pubsub-topic --message="Hello from Dr. Abhishek's Lab"
    
    echo -e "${YELLOW}Waiting for message delivery...${RESET}"
    sleep 10
    
    echo -e "${YELLOW}Pulling messages...${RESET}"
    gcloud pubsub subscriptions pull pubsub-subscription-message --limit 5
    
    echo -e "${YELLOW}Creating snapshot...${RESET}"
    gcloud pubsub snapshots create pubsub-snapshot --subscription=gcloud-pubsub-subscription
}

# Main execution
echo -e "${CYAN}${BOLD}🌍 Region Configuration${RESET}"
read -p "Enter your GCP region (e.g., us-central1): " REGION
export REGION

echo -e "\n${CYAN}${BOLD}📋 Available Lab Options:${RESET}"
echo "1) Basic Pub/Sub with Scheduler"
echo "2) Advanced Pub/Sub with Schema"
echo "3) Pub/Sub with Snapshots"
echo

read -p "Select lab option (1-3): " form_number

case $form_number in
    1) run_form_1 ;;
    2) run_form_2 ;;
    3) run_form_3 ;;
    *) echo -e "${RED}Invalid selection. Please choose 1, 2, or 3.${RESET}"; exit 1 ;;
esac

# Completion message
echo -e "\n${GREEN}${BOLD}╔════════════════════════════════════════════╗"
echo -e "║          🎉 Lab Completed Successfully! 🎉          ║"
echo -e "╚════════════════════════════════════════════╝${RESET}"
echo -e "${WHITE}Thank you for using Dr. Abhishek's Cloud Lab!${RESET}"
echo -e "${CYAN}For more tutorials, subscribe: ${BLUE}https://youtube.com/@drabhishek.5460${RESET}"
