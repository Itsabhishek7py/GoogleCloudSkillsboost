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
echo "║   🌊 WELCOME TO DR ABHISHEK CLOUD TUTORIALS                 ║"
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
echo "${BOLD}${GREEN}✓${RESET} ${YELLOW}Setting environment variables...${RESET}"
export REGION="${ZONE%-*}"
export KEY_1=domain_type
export VALUE_1=source_data
echo "${BOLD}Region:${RESET} ${WHITE}$REGION${RESET}"
echo "${BOLD}Labels:${RESET} ${WHITE}$KEY_1=$VALUE_1${RESET}"

# Dataplex Lake creation
section "DATAPLEX LAKE CONFIGURATION"
echo "${BOLD}${GREEN}✓${RESET} ${BLUE}Creating Customer Lake...${RESET}"
gcloud alpha dataplex lakes create customer-lake \
  --display-name="Customer-Lake" \
  --location=$REGION \
  --labels="key_1=$KEY_1,value_1=$VALUE_1"

# Zone creation
section "DATAPLEX ZONE SETUP"
echo "${BOLD}${GREEN}✓${RESET} ${MAGENTA}Creating Public Zone...${RESET}"
gcloud dataplex zones create public-zone \
  --lake=customer-lake \
  --location=$REGION \
  --type=RAW \
  --resource-location-type=SINGLE_REGION \
  --display-name="Public-Zone"

# Environment creation
section "DATAPLEX ENVIRONMENT"
echo "${BOLD}${GREEN}✓${RESET} ${CYAN}Creating Dataplex Environment...${RESET}"
gcloud dataplex environments create dataplex-lake-env \
  --project=$DEVSHELL_PROJECT_ID \
  --location=$REGION \
  --lake=customer-lake \
  --os-image-version=1.0 \
  --compute-node-count 3 \
  --compute-max-node-count 3

# Asset creation
section "DATA ASSETS CREATION"
echo "${BOLD}${GREEN}✓${RESET} ${YELLOW}Creating Customer Raw Data asset...${RESET}"
gcloud dataplex assets create customer-raw-data \
  --location=$REGION \
  --lake=customer-lake \
  --zone=public-zone \
  --resource-type=STORAGE_BUCKET \
  --resource-name=projects/$DEVSHELL_PROJECT_ID/buckets/$DEVSHELL_PROJECT_ID-customer-bucket \
  --discovery-enabled \
  --display-name="Customer Raw Data"

echo "${BOLD}${GREEN}✓${RESET} ${YELLOW}Creating Customer Reference Data asset...${RESET}"
gcloud dataplex assets create customer-reference-data \
  --location=$REGION \
  --lake=customer-lake \
  --zone=public-zone \
  --resource-type=BIGQUERY_DATASET \
  --resource-name=projects/$DEVSHELL_PROJECT_ID/datasets/customer_reference_data \
  --display-name="Customer Reference Data"

# Data Catalog setup
section "DATA GOVERNANCE"
echo "${BOLD}${GREEN}✓${RESET} ${BLUE}Creating Data Catalog Tag Template...${RESET}"
gcloud data-catalog tag-templates create customer_data_tag_template \
  --location=$REGION \
  --display-name="Customer Data Tag Template" \
  --field=id=data_owner,display-name="Data Owner",type=string,required=TRUE \
  --field=id=pii_data,display-name="PII Data",type='enum(Yes|No)',required=TRUE

# Completion message
section "SETUP COMPLETE"
echo "${BG_GREEN}${BLACK}${BOLD}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║   🎉 ${WHITE}LAB COMPLETED SUCCESSFULLY!${BLACK}        ║"
echo "║                                                            ║"
echo "║   ${WHITE}Created Resources:${BLACK}                                ║"
echo "║   - Lake: customer-lake                                    ║"
echo "║   - Zone: public-zone                                      ║"
echo "║   - Environment: dataplex-lake-env                         ║"
echo "║   - Assets: customer-raw-data, customer-reference-data     ║"
echo "║   - Tag Template: customer_data_tag_template               ║"
echo "║                                                            ║"
echo "║   ${WHITE}For more cloud  tutorials:${BLACK}         ║"
echo "║   ${BLINK}${WHITE}Subscribe to Dr. Abhishek's YouTube Channel${RESET}${BG_GREEN}${BLACK}${BOLD}  ║"
echo "║   ${WHITE}https://youtube.com/@drabhishek.5460${BLACK}                ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo "${RESET}"
