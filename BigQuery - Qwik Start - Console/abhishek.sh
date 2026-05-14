#!/bin/bash

# Bright Foreground Colors
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

# Displaying start message
echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}                 Welcome to Dr abhishek cloud...                   ${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${BLUE_TEXT}${BOLD_TEXT}          Tutorial by Dr. Abhishek                       ${RESET_FORMAT}"
echo "${YELLOW_TEXT}For more BigQuery tutorials, visit: https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Step 1: Querying Public Data ========================== ${RESET_FORMAT}"
echo
bq query --use_legacy_sql=false \
"
#standardSQL
SELECT
 weight_pounds, state, year, gestation_weeks
FROM
 \`bigquery-public-data.samples.natality\`
ORDER BY weight_pounds DESC LIMIT 10;
"

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Step 2: Create a Dataset ========================== ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT} This step will create a new dataset called 'babynames'. ${RESET_FORMAT}"
echo
bq mk babynames

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Step 3: Load Data into Table ========================== ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT} This step will load data from a Cloud Storage bucket into a table named 'names_2014' in the 'babynames' dataset. ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT} Please wait, it may take some time. ${RESET_FORMAT}"
echo
bq load --autodetect --source_format=CSV babynames.names_2014 gs://spls/gsp072/baby-names/yob2014.txt name:string,gender:string,count:integer

echo
echo "${GREEN_TEXT}${BOLD_TEXT} ========================== Step 4: Query the Loaded Data ========================== ${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT} This step will query the 'names_2014' table to fetch the top 5 most common male baby names. ${RESET_FORMAT}"
echo
bq query --use_legacy_sql=false \
"
#standardSQL
SELECT
 name, count
FROM
 \`babynames.names_2014\`
WHERE
 gender = 'M'
ORDER BY count DESC LIMIT 5;
"
echo

echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}              Lab Completed Successfully!               ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo -e "${RED_TEXT}${BOLD_TEXT}Subscribe to Dr. Abhishek's Channel:${RESET_FORMAT} ${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo
