#!/bin/bash
# Define rich color variables
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)

# Background colors
BG_BLACK=$(tput setab 0)
BG_RED=$(tput setab 1)
BG_GREEN=$(tput setab 2)
BG_YELLOW=$(tput setab 3)
BG_BLUE=$(tput setab 4)
BG_MAGENTA=$(tput setab 5)
BG_CYAN=$(tput setab 6)
BG_WHITE=$(tput setab 7)

# Text effects
BOLD=$(tput bold)
DIM=$(tput dim)
BLINK=$(tput blink)
REVERSE=$(tput rev)
RESET=$(tput sgr0)

#----------------------------------------------------start--------------------------------------------------#


echo "${BG_MAGENTA}${WHITE}${BOLD}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║   🏷️  Welcome to Dr abhishek Channel         ║"
echo "║                                                            ║"
echo "║   📺 Learn more at:                                        ║"
echo "║   ${BLINK}https://youtube.com/@drabhishek.5460${RESET}${BG_MAGENTA}${WHITE}${BOLD}             ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo "${RESET}"

# Section header function
section() {
    echo ""
    echo "${BG_CYAN}${BLACK}${BOLD}»»» $1 «««${RESET}"
    echo ""
}

# Starting execution
section "INITIAL SETUP"
echo "${BOLD}${GREEN}✓${RESET} ${YELLOW}Setting region from zone...${RESET}"
export REGION="${ZONE%-*}"
echo "${BOLD}Derived Region:${RESET} ${WHITE}$REGION${RESET}"

# BigQuery operations
section "BIGQUERY SETUP"
echo "${BOLD}${GREEN}✓${RESET} ${BLUE}Creating Raw_data dataset...${RESET}"
bq mk --location=US Raw_data

echo "${BOLD}${GREEN}✓${RESET} ${BLUE}Loading public data from Cloud Storage...${RESET}"
bq load --source_format=AVRO Raw_data.public-data gs://spls/gsp1145/users.avro

# Dataplex configuration
section "DATAPLEX CONFIGURATION"
echo "${BOLD}${GREEN}✓${RESET} ${MAGENTA}Creating temperature-raw-data zone...${RESET}"
gcloud dataplex zones create temperature-raw-data \
    --lake=public-lake \
    --location=$REGION \
    --type=RAW \
    --resource-location-type=SINGLE_REGION \
    --display-name="temperature-raw-data"

echo "${BOLD}${GREEN}✓${RESET} ${MAGENTA}Creating customer-details-dataset asset...${RESET}"
gcloud dataplex assets create customer-details-dataset \
    --location=$REGION \
    --lake=public-lake \
    --zone=temperature-raw-data \
    --resource-type=BIGQUERY_DATASET \
    --resource-name=projects/$DEVSHELL_PROJECT_ID/datasets/customer_reference_data \
    --display-name="Customer Details Dataset" \
    --discovery-enabled

# Data Catalog setup
section "DATA GOVERNANCE"
echo "${BOLD}${GREEN}✓${RESET} ${CYAN}Creating protected data tag template...${RESET}"
gcloud data-catalog tag-templates create protected_data_template \
    --location=$REGION \
    --display-name="Protected Data Template" \
    --field=id=protected_data_flag,display-name="Protected Data Flag",type='enum(Yes|No)',required=TRUE

section "SETUP COMPLETE"
echo "${BOLD}${GREEN}✓${RESET} ${WHITE}All resources configured successfully!${RESET}"
echo ""
echo "${BOLD}${YELLOW}Next steps:${RESET}"
echo "${WHITE}1. Review your Dataplex lake at:${RESET}"
echo "${BLUE}${BOLD}   https://console.cloud.google.com/dataplex/search?project=$DEVSHELL_PROJECT_ID&q=us-states&qSystems=BIGQUERY${RESET}"
echo ""
echo "${WHITE}2. Do Like share & subscribe${RESET}"
echo "${BLUE}${BOLD}   https://console.cloud.google.com/dataplex/govern${RESET}"
echo ""
echo "${BOLD}${GREEN}Need help with Google Cloud?${RESET}"
echo "${WHITE}Subscribe for more tutorials:${RESET}"
echo "${BLINK}${CYAN}https://youtube.com/@drabhishek.5460${RESET}"
echo ""

#-----------------------------------------------------end----------------------------------------------------------#
