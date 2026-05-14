#!/bin/bash

# Define color variables
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

# Spinner function
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Header function
header() {
    clear
    echo "${BG_MAGENTA}${BOLD}${WHITE}================================================${RESET}"
    echo "${BG_MAGENTA}${BOLD}${WHITE}  Dr. Abhishek's BigQuery ML Vector Search Lab  ${RESET}"
    echo "${BG_MAGENTA}${BOLD}${WHITE}================================================${RESET}"
    echo
}

# Welcome message
welcome() {
    header
    echo "${CYAN}${BOLD}Welcome to the BigQuery ML Vector Search Lab!${RESET}"
    echo "${YELLOW}Subscribe to my channel: https://www.youtube.com/@drabhishek.5460${RESET}"
    echo
    echo "${GREEN}${BOLD}Starting execution in 3 seconds...${RESET}"
    sleep 3
}

# Task separator
task_separator() {
    echo
    echo "${BG_BLUE}${BOLD}${WHITE}=== TASK $1 ===${RESET}"
    echo
}

# Success message
success() {
    echo "${GREEN}${BOLD}✓ $1${RESET}"
}

# Error message
error() {
    echo "${RED}${BOLD}✗ $1${RESET}"
}

#----------------------------------------------------start--------------------------------------------------#
welcome

# Task 1: Initial Setup
task_separator 1

echo "${YELLOW}${BOLD}Checking authentication...${RESET}"
(gcloud auth list >/dev/null 2>&1) & spinner
success "Authentication verified"

echo "${YELLOW}${BOLD}Enabling AI Platform API...${RESET}"
(gcloud services enable aiplatform.googleapis.com >/dev/null 2>&1) & spinner
success "AI Platform API enabled"

echo "${YELLOW}${BOLD}Setting up region and project variables...${RESET}"
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")
export PROJECT_ID=$(gcloud config get-value project)
success "Region set to $REGION and Project ID set to $PROJECT_ID"

echo "${YELLOW}${BOLD}Creating BigQuery connection...${RESET}"
(bq mk --connection --location=$REGION --project_id=$PROJECT_ID --connection_type=CLOUD_RESOURCE vector_conn >/dev/null 2>&1) & spinner
success "BigQuery connection created"

echo "${YELLOW}${BOLD}Getting service account...${RESET}"
SERVICE_ACCOUNT=$(bq show --format=json --connection $PROJECT_ID.$REGION.vector_conn | jq -r '.cloudResource.serviceAccountId')
echo "Service Account: ${CYAN}${SERVICE_ACCOUNT}${RESET}"

echo "${YELLOW}${BOLD}Assigning IAM roles...${RESET}"
(gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/bigquery.dataOwner" >/dev/null 2>&1) & spinner

(gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/storage.objectViewer" >/dev/null 2>&1) & spinner

(gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:$SERVICE_ACCOUNT" \
  --role="roles/aiplatform.user" >/dev/null 2>&1) & spinner
success "IAM roles assigned"

# Task 2: Create External Table
task_separator 2

echo "${YELLOW}${BOLD}Creating external table...${RESET}"
(bq query --use_legacy_sql=false "
CREATE OR REPLACE EXTERNAL TABLE \`${PROJECT_ID}.gcc_bqml_dataset.gcc_image_object_table\`
WITH CONNECTION \`${REGION}.vector_conn\`
OPTIONS (
  object_metadata = 'SIMPLE',
  uris = ['gs://${PROJECT_ID}/*']
)" >/dev/null 2>&1) & spinner
success "External table created"

# Task 3: Create Embedding Model
task_separator 3

echo "${YELLOW}${BOLD}Creating embedding model...${RESET}"
(bq query --use_legacy_sql=false "
CREATE OR REPLACE MODEL \`${PROJECT_ID}.gcc_bqml_dataset.gcc_embedding\`
REMOTE WITH CONNECTION \`${REGION}.vector_conn\`
OPTIONS (
  endpoint = 'multimodalembedding@001'
);" >/dev/null 2>&1) & spinner
success "Embedding model created"

echo "${YELLOW}${BOLD}Generating embeddings...${RESET}"
(bq query --use_legacy_sql=false "
CREATE OR REPLACE TABLE \`${PROJECT_ID}.gcc_bqml_dataset.gcc_retail_store_embeddings\` AS
SELECT *, REGEXP_EXTRACT(uri, r'[^/]+$') AS product_name
FROM ML.GENERATE_EMBEDDING(
  MODEL \`${PROJECT_ID}.gcc_bqml_dataset.gcc_embedding\`,
  TABLE \`${PROJECT_ID}.gcc_bqml_dataset.gcc_image_object_table\`
);" >/dev/null 2>&1) & spinner
success "Embeddings generated"

echo "${YELLOW}${BOLD}Displaying embeddings table...${RESET}"
(bq show --format=prettyjson ${PROJECT_ID}:gcc_bqml_dataset.gcc_retail_store_embeddings >/dev/null 2>&1) & spinner
success "Embeddings table displayed"

# Task 4: Vector Search
task_separator 4

echo "${YELLOW}${BOLD}Performing vector search...${RESET}"
(bq query --use_legacy_sql=false "
CREATE OR REPLACE TABLE \`${PROJECT_ID}.gcc_bqml_dataset.gcc_vector_search_table\` AS
SELECT
  base.uri,
  base.product_name,
  base.content_type,
  distance
FROM
  VECTOR_SEARCH(
    TABLE \`${PROJECT_ID}.gcc_bqml_dataset.gcc_retail_store_embeddings\`,
    'ml_generate_embedding_result',
    (
      SELECT
        ml_generate_embedding_result AS embedding_col
      FROM
        ML.GENERATE_EMBEDDING(
          MODEL \`${PROJECT_ID}.gcc_bqml_dataset.gcc_embedding\`,
          (SELECT 'Men Sweaters' AS content),
          STRUCT(TRUE AS flatten_json_output)
        )
    ),
    top_k => 3,
    distance_type => 'COSINE'
  );" >/dev/null 2>&1) & spinner
success "Vector search completed"

# Final message
echo
echo "${BG_GREEN}${BOLD}${WHITE}================================================${RESET}"
echo "${BG_GREEN}${BOLD}${WHITE}  Lab Completed Successfully!                  ${RESET}"
echo "${BG_GREEN}${BOLD}${WHITE}================================================${RESET}"
echo
echo "${CYAN}${BOLD}Thank you !${RESET}"
echo "${YELLOW}${BOLD}Don't forget to subscribe to my channel:${RESET}"
echo "${BLUE}${BOLD}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
