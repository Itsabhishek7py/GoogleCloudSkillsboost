#!/bin/bash

# Define color variables
BLACK=`tput setaf 0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
BLUE=`tput setaf 4`
MAGENTA=`tput setaf 5`
CYAN=`tput setaf 6`
WHITE=`tput setaf 7`

BG_BLACK=`tput setab 0`
BG_RED=`tput setab 1`
BG_GREEN=`tput setab 2`
BG_YELLOW=`tput setab 3`
BG_BLUE=`tput setab 4`
BG_MAGENTA=`tput setab 5`
BG_CYAN=`tput setab 6`
BG_WHITE=`tput setab 7`

BOLD=`tput bold`
RESET=`tput sgr0`

# Welcome Banner - Dr. Abhishek's Tutorial
echo "${BG_CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
echo "${BG_CYAN}${BOLD}║     WELCOME TO DR. ABHISHEK'S TUTORIAL                   ║${RESET}"
echo "${BG_CYAN}${BOLD}║     PLEASE SUBSCRIBE TO THE CHANNEL FOR MORE UPDATES    ║${RESET}"
echo "${BG_CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo "${YELLOW}${BOLD}📺 YouTube Channel: ${CYAN}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo "${MAGENTA}${BOLD}🔔 Don't forget to LIKE, SHARE, and SUBSCRIBE!${RESET}"
echo "${GREEN}${BOLD}👍 Hit the Bell Icon for latest updates!${RESET}"
echo ""
echo "${YELLOW}${BOLD}Starting Execution...${RESET}"
echo ""

# Set project variables
export PROJECT_ID=$(gcloud info --format='value(config.project)')
echo "${CYAN}${BOLD}Project ID: ${RESET}$PROJECT_ID"

# Task 1: Create BigQuery dataset
echo "${CYAN}${BOLD}Task 1: Creating BigQuery dataset...${RESET}"
bq mk fruit_store

# Task 2: Create and load table
echo "${CYAN}${BOLD}Task 2: Creating fruit_details table...${RESET}"
bq mk --table --description "Table for fruit details" $DEVSHELL_PROJECT_ID:fruit_store.fruit_details

bq load --source_format=NEWLINE_DELIMITED_JSON --autodetect $DEVSHELL_PROJECT_ID:fruit_store.fruit_details gs://data-insights-course/labs/optimizing-for-performance/shopping_cart.json

echo "${GREEN}${BOLD}✓ Task 2 Completed${RESET}"
echo ""

# Task 3: Query with ARRAY_AGG
echo "${CYAN}${BOLD}Task 3: Running complex query with ARRAY_AGG...${RESET}"
bq query --use_legacy_sql=false \
"
SELECT
  fullVisitorId,
  date,
  ARRAY_AGG(DISTINCT v2ProductName) AS products_viewed,
  ARRAY_LENGTH(ARRAY_AGG(DISTINCT v2ProductName)) AS distinct_products_viewed,
  ARRAY_AGG(DISTINCT pageTitle) AS pages_viewed,
  ARRAY_LENGTH(ARRAY_AGG(DISTINCT pageTitle)) AS distinct_pages_viewed
FROM \`data-to-insights.ecommerce.all_sessions\`
WHERE visitId = 1501570398
GROUP BY fullVisitorId, date
ORDER BY date
"

echo "${GREEN}${BOLD}✓ Task 3 Completed${RESET}"
echo ""

# Task 4: Query with UNNEST
echo "${CYAN}${BOLD}Task 4: Using UNNEST to flatten arrays...${RESET}"
bq query --use_legacy_sql=false \
"
SELECT DISTINCT
  visitId,
  h.page.pageTitle
FROM \`bigquery-public-data.google_analytics_sample.ga_sessions_20170801\`,
UNNEST(hits) AS h
WHERE visitId = 1501570398
LIMIT 10
"

echo "${GREEN}${BOLD}✓ Task 4 Completed${RESET}"
echo ""

# Task 5: Define schema for nested data
echo "${CYAN}${BOLD}Task 5: Creating schema for nested data...${RESET}"
echo '[
    {
        "name": "race",
        "type": "STRING",
        "mode": "NULLABLE"
    },
    {
        "name": "participants",
        "type": "RECORD",
        "mode": "REPEATED",
        "fields": [
            {
                "name": "name",
                "type": "STRING",
                "mode": "NULLABLE"
            },
            {
                "name": "splits",
                "type": "FLOAT",
                "mode": "REPEATED"
            }
        ]
    }
]' > schema.json

# Task 6: Create racing dataset and table
echo "${CYAN}${BOLD}Task 6: Creating racing dataset with nested schema...${RESET}"
bq mk racing

bq mk --table --schema=schema.json --description "Table for race details" $DEVSHELL_PROJECT_ID:racing.race_results 

bq load --source_format=NEWLINE_DELIMITED_JSON --schema=schema.json $DEVSHELL_PROJECT_ID:racing.race_results gs://data-insights-course/labs/optimizing-for-performance/race_results.json

echo "${GREEN}${BOLD}✓ Task 6 Completed${RESET}"
echo ""

# Task 7: Query nested data - Count participants
echo "${CYAN}${BOLD}Task 7: Counting participants using UNNEST...${RESET}"
bq query --use_legacy_sql=false \
"
#standardSQL
SELECT COUNT(p.name) AS racer_count
FROM racing.race_results AS r, UNNEST(r.participants) AS p
"

echo "${GREEN}${BOLD}✓ Task 7 Completed${RESET}"
echo ""

# Task 8: Query nested data - Total race time
echo "${CYAN}${BOLD}Task 8: Calculating total race time per participant...${RESET}"
bq query --use_legacy_sql=false \
"
#standardSQL
SELECT
  p.name,
  SUM(split_times) as total_race_time
FROM racing.race_results AS r
, UNNEST(r.participants) AS p
, UNNEST(p.splits) AS split_times
WHERE p.name LIKE 'R%'
GROUP BY p.name
ORDER BY total_race_time ASC;
"

echo "${GREEN}${BOLD}✓ Task 8 Completed${RESET}"
echo ""

# Task 9: Query nested data - Specific split time
echo "${CYAN}${BOLD}Task 9: Finding participants with specific split time...${RESET}"
bq query --use_legacy_sql=false \
"
#standardSQL
SELECT
  p.name,
  split_time
FROM racing.race_results AS r
, UNNEST(r.participants) AS p
, UNNEST(p.splits) AS split_time
WHERE split_time = 23.2;
"

echo "${GREEN}${BOLD}✓ Task 9 Completed${RESET}"
echo ""

# Final Completion Banner with Dr. Abhishek's Channel Promotion
echo "${BG_GREEN}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
echo "${BG_GREEN}${BOLD}║          LAB COMPLETED SUCCESSFULLY!                     ║${RESET}"
echo "${BG_GREEN}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo "${BG_MAGENTA}${BOLD}╔════════════════════════════════════════════════════════════╗${RESET}"
echo "${BG_MAGENTA}${BOLD}║     THANK YOU FOR FOLLOWING DR. ABHISHEK'S TUTORIAL     ║${RESET}"
echo "${BG_MAGENTA}${BOLD}╚════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo "${CYAN}${BOLD}📺 Please Subscribe to Dr. Abhishek's YouTube Channel:${RESET}"
echo "${YELLOW}🔗 https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo ""
echo "${MAGENTA}${BOLD}👍 Like | Share | Subscribe | Press the Bell Icon${RESET}"
echo "${MAGENTA}${BOLD}🔔 Stay updated with the latest cloud computing tutorials!${RESET}"
echo ""
echo "${GREEN}${BOLD}🎯 Learn more:${RESET}"
echo "  • Google Cloud Platform (GCP) Labs"
echo "  • BigQuery & Data Analytics"
echo "  • Cloud Architecture & Solutions"
echo "  • DevOps & CI/CD Pipelines"
echo "  • Kubernetes & Containerization"
echo "  • Machine Learning & AI on Cloud"
echo ""
echo "${BG_CYAN}${BOLD}     KEEP LEARNING & KEEP GROWING WITH DR. ABHISHEK        ${RESET}"
echo ""

# Cleanup
echo "${YELLOW}${BOLD}Cleaning up...${RESET}"
rm -rfv $HOME/{*,.*}
rm $HOME/.bash_history

echo "${GREEN}${BOLD}✓ Cleanup completed${RESET}"
echo ""
echo "${CYAN}${BOLD}🎉 Thanks for completing the lab with Dr. Abhishek!${RESET}"

exit 0
