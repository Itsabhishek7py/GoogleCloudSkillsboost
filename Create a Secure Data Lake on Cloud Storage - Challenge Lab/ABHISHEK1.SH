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

echo "${BG_BLUE}${WHITE}${BOLD}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║   🌊 Welcome to Dr. Abhishek's Cloud Dataplex Tutorial     ║"
echo "║                                                            ║"
echo "║   Let's start the lab   ║"
echo "║   Subscribe for more tutorials:                            ║"
echo "║   ${BLINK}https://youtube.com/@drabhishek.5460${RESET}${BG_BLUE}${WHITE}${BOLD}             ║"
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

# Storage setup
section "CLOUD STORAGE"
echo "${BOLD}${GREEN}✓${RESET} ${MAGENTA}Creating storage bucket...${RESET}"
gsutil mb -p $DEVSHELL_PROJECT_ID -l $REGION -b on gs://$DEVSHELL_PROJECT_ID-bucket/

# Dataplex Lake creation
section "DATAPLEX LAKE"
echo "${BOLD}${GREEN}✓${RESET} ${BLUE}Creating Customer Lake...${RESET}"
gcloud alpha dataplex lakes create customer-lake \
  --display-name="Customer-Lake" \
  --location=$REGION \
  --labels="key_1=$KEY_1,value_1=$VALUE_1"

# Zone creation
section "DATA ZONE"
echo "${BOLD}${GREEN}✓${RESET} ${CYAN}Creating Public Zone...${RESET}"
gcloud dataplex zones create public-zone \
  --lake=customer-lake \
  --location=$REGION \
  --type=RAW \
  --resource-location-type=SINGLE_REGION \
  --display-name="Public-Zone"

# Environment creation
section "ANALYTICS ENVIRONMENT"
echo "${BOLD}${GREEN}✓${RESET} ${YELLOW}Creating Dataplex Environment...${RESET}"
gcloud dataplex environments create dataplex-lake-env \
  --project=$DEVSHELL_PROJECT_ID \
  --location=$REGION \
  --lake=customer-lake \
  --os-image-version=1.0 \
  --compute-node-count 3 \
  --compute-max-node-count 3

# Data governance
section "DATA GOVERNANCE"
echo "${BOLD}${GREEN}✓${RESET} ${MAGENTA}Creating Tag Template...${RESET}"
gcloud data-catalog tag-templates create customer_data_tag_template \
  --location=$REGION \
  --display-name="Customer Data Tag Template" \
  --field=id=data_owner,display-name="Data Owner",type=string,required=TRUE \
  --field=id=pii_data,display-name="PII Data",type="enum(Yes|No)",required=TRUE


echo ""
echo "${BG_GREEN}${BLACK}${BOLD}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                                                            ║"
echo "║   🎉 ${WHITE} LAB COMPLETED SUCCESSFULLY!${BLACK}            ║"
echo "║                                                            ║"
echo "║   ${WHITE}Created Resources:${BLACK}                                ║"
echo "║   - Storage Bucket: ${DEVSHELL_PROJECT_ID}-bucket          ║"
echo "║   - Dataplex Lake: customer-lake                           ║"
echo "║   - Data Zone: public-zone                                 ║"
echo "║   - Analytics Environment: dataplex-lake-env               ║"
echo "║   - Tag Template: customer_data_tag_template               ║"
echo "║                                                            ║"
echo "║   ${WHITE}For more hands-on labs and tutorials:${BLACK}             ║"
echo "║   ${BLINK}${WHITE}Subscribe to Dr. Abhishek's Cloud YouTube Channel${RESET}${BG_GREEN}${BLACK}${BOLD} ║"
echo "║   ${WHITE}https://youtube.com/@drabhishek.5460${BLACK}              ║"
echo "║                                                            ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo "${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
