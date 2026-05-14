#!/bin/bash


PURPLE_TEXT=$'\033[0;35m'
ORANGE_TEXT=$'\033[0;33m'
NEON_GREEN_TEXT=$'\033[1;32m'
PINK_TEXT=$'\033[1;35m'
LIGHT_BLUE_TEXT=$'\033[1;34m'
LIGHT_CYAN_TEXT=$'\033[1;36m'
BOLD_WHITE=$'\033[1;37m'
RESET_FORMAT=$'\033[0m'

echo
echo "${PINK_TEXT}${BOLD_WHITE}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${PINK_TEXT}${BOLD_WHITE}          Welcome to Dr. Abhishek's cloud tutorial             ${RESET_FORMAT}"
echo "${PINK_TEXT}${BOLD_WHITE}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo


echo "${NEON_GREEN_TEXT}${BOLD_WHITE}Initiating DLP Inspection Process...${RESET_FORMAT}"
echo

export PROJECT_ID=$DEVSHELL_PROJECT_ID

# Create inspection request file
cat > inspect-request.json <<EOF_END
{
  "item":{
    "value":"My phone number is (206) 555-0123."
  },
  "inspectConfig":{
    "infoTypes":[
      {
        "name":"PHONE_NUMBER"
      },
      {
        "name":"US_TOLLFREE_PHONE_NUMBER"
      }
    ],
    "minLikelihood":"POSSIBLE",
    "limits":{
      "maxFindingsPerItem":0
    },
    "includeQuote":true
  }
}
EOF_END

# Execute DLP inspection
curl -s \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:inspect \
  -d @inspect-request.json -o inspect-output.txt

cat inspect-output.txt
gsutil cp inspect-output.txt gs://$DEVSHELL_PROJECT_ID-bucket

# Create de-identification request file
cat > new-inspect-file.json <<EOF_END
{
  "item": {
     "value":"My email is test@gmail.com"
   },
   "deidentifyConfig": {
     "infoTypeTransformations":{
          "transformations": [
            {
              "primitiveTransformation": {
                "replaceWithInfoTypeConfig": {}
              }
            }
          ]
        }
    },
    "inspectConfig": {
      "infoTypes": [{
        "name": "EMAIL_ADDRESS"
      }]
    }
}
EOF_END

# Execute DLP de-identification
curl -s \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  https://dlp.googleapis.com/v2/projects/$PROJECT_ID/content:deidentify \
  -d @new-inspect-file.json -o redact-output.txt

cat redact-output.txt
gsutil cp redact-output.txt gs://$DEVSHELL_PROJECT_ID-bucket


echo
echo "${PINK_TEXT}${BOLD_WHITE}╔════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${PINK_TEXT}${BOLD_WHITE}               DO HIT THE LIKE BUTTON AND SUBSCRIBE !           ${RESET_FORMAT}"
echo "${PINK_TEXT}${BOLD_WHITE}╚════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo -e "${NEON_GREEN_TEXT}${BOLD_WHITE}Subscribe our Channel:${RESET_FORMAT} ${LIGHT_BLUE_TEXT}${BOLD_WHITE}https://www.youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo -e "${LIGHT_CYAN_TEXT}${BOLD_WHITE}Follow on Instagram:${RESET_FORMAT} ${PURPLE_TEXT}${BOLD_WHITE}https://www.instagram.com/drabhishek.5460/${RESET_FORMAT}"
echo
