#!/bin/bash
# Clear the terminal
clear

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

# Array of color codes excluding black and white
TEXT_COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
BG_COLORS=($BG_RED $BG_GREEN $BG_YELLOW $BG_BLUE $BG_MAGENTA $BG_CYAN)

# Pick random colors
RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_COLOR=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

#----------------------------------------------------start--------------------------------------------------#

# Display welcome message
echo "${CYAN}${BOLD}"
cat << "EOF"
  ____ _                 _   _   _       _   _  __ _          _ _ 
 / ___| | ___  _   _  __| | | \ | | ___ | |_(_)/ _(_) ___  __| | |
| |   | |/ _ \| | | |/ _` | |  \| |/ _ \| __| | |_| |/ _ \/ _` | |
| |___| | (_) | |_| | (_| | | |\  | (_) | |_| |  _| |  __/ (_| |_|
 \____|_|\___/ \__,_|\__,_| |_| \_|\___/ \__|_|_| |_|\___|\__,_(_)
EOF
echo "${RESET}"
echo "${GREEN}${BOLD}Welcome to the Cloud DLP Lab Script!${RESET}"
echo "${YELLOW}Subscribe to Dr. Abhishek for more cloud tutorials(https://www.youtube.com/@drabhishek.5460/videos)!${RESET}"
echo "${BLUE}${BOLD}----------------------------------------------------${RESET}"

echo "${RANDOM_BG_COLOR}${RANDOM_TEXT_COLOR}${BOLD}Starting Execution${RESET}"

# Step 1: Export project ID and project number
echo "${GREEN}${BOLD}Exporting project info${RESET}"
export PROJECT_ID=$(gcloud config get-value project)

export PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} \
    --format="value(projectNumber)")

# Step 2: Create de-identification template config file
echo "${CYAN}${BOLD}Creating de-identification template JSON${RESET}"
cat <<EOF > deidentify-template.json
{
  "deidentifyTemplate": {
    "deidentifyConfig": {
      "recordTransformations": {
        "fieldTransformations": [
          {
            "fields": [
              {
                "name": "ssn"
              },
              {
                "name": "email"
              }
            ],
            "primitiveTransformation": {
              "replaceConfig": {
                "newValue": {
                  "stringValue": "[redacted]"
                }
              }
            }
          },
          {
            "fields": [
              {
                "name": "message"
              }
            ],
            "infoTypeTransformations": {
              "transformations": [
                {
                  "primitiveTransformation": {
                    "replaceWithInfoTypeConfig": {}
                  }
                }
              ]
            }
          }
        ]
      }
    },
    "displayName": "De-identify Credit Card Numbers"
  },
  "locationId": "global",
  "templateId": "us_ccn_deidentify"
}
EOF

# Step 3: Create the de-identification template using the DLP API
echo "${YELLOW}${BOLD}Creating de-identification template using the DLP API${RESET}"
curl -X POST -s \
-H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
-H "Content-Type: application/json" \
-d @deidentify-template.json \
"https://dlp.googleapis.com/v2/projects/$DEVSHELL_PROJECT_ID/locations/global/deidentifyTemplates"

# Step 4: Get Template ID
echo "${MAGENTA}${BOLD}Retrieving Template ID${RESET}"
export TEMPLATE_ID=$(curl -s \
--request GET \
--url "https://dlp.googleapis.com/v2/projects/$DEVSHELL_PROJECT_ID/locations/global/deidentifyTemplates/us_ccn_deidentify" \
--header "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
--header "Content-Type: application/json" \
| jq -r '.name')

# Step 5: Create job configuration JSON
echo "${BLUE}${BOLD}Creating job configuration for DLP inspection${RESET}"
cat > job-configuration.json << EOM
{
  "jobId": "us_ccn_deidentify",
  "inspectJob": {
    "actions": [
      {
        "deidentify": {
          "fileTypesToTransform": [
            "TEXT_FILE",
            "IMAGE",
            "CSV",
            "TSV"
          ],
          "transformationDetailsStorageConfig": {
            "table": {
              "projectId": "$DEVSHELL_PROJECT_ID",
              "datasetId": "cs_transformations",
              "tableId": "deidentify_ccn"
            }
          },
          "transformationConfig": {
            "structuredDeidentifyTemplate": "$TEMPLATE_ID"
          },
          "cloudStorageOutput": "gs://$DEVSHELL_PROJECT_ID-car-owners-transformed"
        }
      }
    ],
    "inspectConfig": {
      "infoTypes": [
        {
          "name": "ADVERTISING_ID"
        },
        {
          "name": "AGE"
        },
        {
          "name": "ARGENTINA_DNI_NUMBER"
        },
        {
          "name": "AUSTRALIA_TAX_FILE_NUMBER"
        },
        {
          "name": "BELGIUM_NATIONAL_ID_CARD_NUMBER"
        },
        {
          "name": "BRAZIL_CPF_NUMBER"
        },
        {
          "name": "CANADA_SOCIAL_INSURANCE_NUMBER"
        },
        {
          "name": "CHILE_CDI_NUMBER"
        },
        {
          "name": "CHINA_RESIDENT_ID_NUMBER"
        },
        {
          "name": "COLOMBIA_CDC_NUMBER"
        },
        {
          "name": "CREDIT_CARD_NUMBER"
        },
        {
          "name": "CREDIT_CARD_TRACK_NUMBER"
        },
        {
          "name": "DATE_OF_BIRTH"
        },
        {
          "name": "DENMARK_CPR_NUMBER"
        },
        {
          "name": "EMAIL_ADDRESS"
        },
        {
          "name": "ETHNIC_GROUP"
        },
        {
          "name": "FDA_CODE"
        },
        {
          "name": "FINLAND_NATIONAL_ID_NUMBER"
        },
        {
          "name": "FRANCE_CNI"
        },
        {
          "name": "FRANCE_NIR"
        },
        {
          "name": "FRANCE_TAX_IDENTIFICATION_NUMBER"
        },
        {
          "name": "GENDER"
        },
        {
          "name": "GERMANY_IDENTITY_CARD_NUMBER"
        },
        {
          "name": "GERMANY_TAXPAYER_IDENTIFICATION_NUMBER"
        },
        {
          "name": "HONG_KONG_ID_NUMBER"
        },
        {
          "name": "IBAN_CODE"
        },
        {
          "name": "IMEI_HARDWARE_ID"
        },
        {
          "name": "INDIA_AADHAAR_INDIVIDUAL"
        },
        {
          "name": "INDIA_GST_INDIVIDUAL"
        },
        {
          "name": "INDIA_PAN_INDIVIDUAL"
        },
        {
          "name": "INDONESIA_NIK_NUMBER"
        },
        {
          "name": "IRELAND_PPSN"
        },
        {
          "name": "ISRAEL_IDENTITY_CARD_NUMBER"
        },
        {
          "name": "JAPAN_INDIVIDUAL_NUMBER"
        },
        {
          "name": "KOREA_RRN"
        },
        {
          "name": "MAC_ADDRESS"
        },
        {
          "name": "MEXICO_CURP_NUMBER"
        },
        {
          "name": "NETHERLANDS_BSN_NUMBER"
        },
        {
          "name": "NORWAY_NI_NUMBER"
        },
        {
          "name": "PARAGUAY_CIC_NUMBER"
        },
        {
          "name": "PASSPORT"
        },
        {
          "name": "PERSON_NAME"
        },
        {
          "name": "PERU_DNI_NUMBER"
        },
        {
          "name": "PHONE_NUMBER"
        },
        {
          "name": "POLAND_NATIONAL_ID_NUMBER"
        },
        {
          "name": "PORTUGAL_CDC_NUMBER"
        },
        {
          "name": "SCOTLAND_COMMUNITY_HEALTH_INDEX_NUMBER"
        },
        {
          "name": "SINGAPORE_NATIONAL_REGISTRATION_ID_NUMBER"
        },
        {
          "name": "SPAIN_CIF_NUMBER"
        },
        {
          "name": "SPAIN_DNI_NUMBER"
        },
        {
          "name": "SPAIN_NIE_NUMBER"
        },
        {
          "name": "SPAIN_NIF_NUMBER"
        },
        {
          "name": "SPAIN_SOCIAL_SECURITY_NUMBER"
        },
        {
          "name": "STORAGE_SIGNED_URL"
        },
        {
          "name": "STREET_ADDRESS"
        },
        {
          "name": "SWEDEN_NATIONAL_ID_NUMBER"
        },
        {
          "name": "SWIFT_CODE"
        },
        {
          "name": "THAILAND_NATIONAL_ID_NUMBER"
        },
        {
          "name": "TURKEY_ID_NUMBER"
        },
        {
          "name": "UK_NATIONAL_HEALTH_SERVICE_NUMBER"
        },
        {
          "name": "UK_NATIONAL_INSURANCE_NUMBER"
        },
        {
          "name": "UK_TAXPAYER_REFERENCE"
        },
        {
          "name": "URUGUAY_CDI_NUMBER"
        },
        {
          "name": "US_BANK_ROUTING_MICR"
        },
        {
          "name": "US_EMPLOYER_IDENTIFICATION_NUMBER"
        },
        {
          "name": "US_HEALTHCARE_NPI"
        },
        {
          "name": "US_INDIVIDUAL_TAXPAYER_IDENTIFICATION_NUMBER"
        },
        {
          "name": "US_SOCIAL_SECURITY_NUMBER"
        },
        {
          "name": "VEHICLE_IDENTIFICATION_NUMBER"
        },
        {
          "name": "VENEZUELA_CDI_NUMBER"
        },
        {
          "name": "WEAK_PASSWORD_HASH"
        },
        {
          "name": "AUTH_TOKEN"
        },
        {
          "name": "AWS_CREDENTIALS"
        },
        {
          "name": "AZURE_AUTH_TOKEN"
        },
        {
          "name": "BASIC_AUTH_HEADER"
        },
        {
          "name": "ENCRYPTION_KEY"
        },
        {
          "name": "GCP_API_KEY"
        },
        {
          "name": "GCP_CREDENTIALS"
        },
        {
          "name": "JSON_WEB_TOKEN"
        },
        {
          "name": "HTTP_COOKIE"
        },
        {
          "name": "XSRF_TOKEN"
        }
      ],
      "minLikelihood": "POSSIBLE"
    },
    "storageConfig": {
      "cloudStorageOptions": {
        "filesLimitPercent": 100,
        "fileTypes": [
          "TEXT_FILE",
          "IMAGE",
          "WORD",
          "PDF",
          "AVRO",
          "CSV",
          "TSV",
          "EXCEL",
          "POWERPOINT"
        ],
        "fileSet": {
          "url": "gs://$DEVSHELL_PROJECT_ID-car-owners/**"
        }
      }
    }
  }
}
EOM

sleep 15

# Step 6: Create DLP Job
echo "${GREEN}${BOLD}Creating DLP Job${RESET}"
curl -s \
  -X POST \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://dlp.googleapis.com/v2/projects/$DEVSHELL_PROJECT_ID/dlpJobs" \
  -d @job-configuration.json

# Step 7: Create SPII Tag Key
echo "${YELLOW}${BOLD}Creating resource tag key for SPII${RESET}"
gcloud resource-manager tags keys create SPII \
    --parent=projects/$PROJECT_NUMBER \
    --description="Flag for sensitive personally identifiable information (SPII)"

# Step 8: Retrieve Tag Key ID
echo "${CYAN}${BOLD}Step 9: Retrieving tag key ID${RESET}"
TAG_KEY_ID=$(gcloud resource-manager tags keys list --parent="projects/${PROJECT_NUMBER}" --format="value(NAME)")

# Step 9: Create Tag Values
echo "${MAGENTA}${BOLD}Creating tag values for Yes/No SPII${RESET}"
gcloud resource-manager tags values create Yes \
    --parent=$TAG_KEY_ID \
    --description="Contains sensitive personally identifiable information (SPII)"

gcloud resource-manager tags values create No \
    --parent=$TAG_KEY_ID \
    --description="Does not contain sensitive personally identifiable information (SPII)"

echo -e "\n${GREEN}${BOLD}Lab completed successfully!${RESET}\n"

# Clean up temporary files
remove_files() {
    # Loop through all files in the current directory
    for file in *; do
        # Check if the file name starts with "gsp", "arc", "shell", or "gcp"
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* || "$file" == gcp* || "$file" == quicklab* ]]; then
            # Check if it's a regular file (not a directory)
            if [[ -f "$file" ]]; then
                # Remove the file and echo the file name
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}

remove_files
