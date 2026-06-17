#!/bin/bash
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

clear

# Welcome Banner
echo "${BLUE_TEXT}${BOLD_TEXT}"
echo "╔═══════════════════════════════════════════════════╗"
echo "║                                                   ║"
echo "║           Dr. Abhishek Cloud Tutorials            ║"
echo "║                                                   ║"
echo "║  Comprehensive GCP Learning Resources             ║"
echo "║  YouTube: https://youtube.com/@drabhishek.5460    ║"
echo "║                                                   ║"
echo "╚═══════════════════════════════════════════════════╝"
echo "${RESET_FORMAT}"

echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔═══════════════════════════════════════════════════╗"
echo "║                STARTING LAB                ║"
echo "╚═══════════════════════════════════════════════════╝${RESET_FORMAT}"
echo

# Spinner function
spinner() {
    local pid=$!
    local delay=0.1
    local spinstr='⣾⣽⣻⢿⡿⣟⣯⣷'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

echo "${CYAN_TEXT}${BOLD_TEXT}📌 Preparing to assign project variables...${RESET_FORMAT}"

assign_projects() {
  echo -n "${BLUE_TEXT}${BOLD_TEXT}🔍 Fetching available GCP projects...${RESET_FORMAT}"
  (PROJECT_LIST=$(gcloud projects list --format="value(projectId)") > /dev/null 2>&1) &
  spinner
  echo " ${GREEN_TEXT}✓${RESET_FORMAT}"
  
#!/bin/bash

# 1. Fetch and format the available projects
echo
echo -e "${GREEN_TEXT}${BOLD_TEXT}Available Projects:${RESET_FORMAT}"

# Extract clean IDs from your layout, ignoring labels and 'qwiklabs-resources'
PROJECT_LIST=$(gcloud projects list --format="value(projectId)" | grep -v "qwiklabs-resources")

# Display the projects to the user
gcloud projects list --format="table(projectId,name)"
    echo

# 2. Read and Validate PROJECT_2 input
    echo -n -e "${GREEN_TEXT}${BOLD_TEXT}✍️ Enter PROJECT_2 ID: ${RESET_FORMAT}"
    read -r PROJECT_2

# Clean input of any accidental spaces
    PROJECT_2=$(echo "$PROJECT_2" | xargs)

# Exact match validation against the clean list
    if ! echo "$PROJECT_LIST" | grep -qxF "$PROJECT_2"; then
    echo -e "${RED_TEXT}${BOLD_TEXT}❌ Error: Invalid project ID. Please try again.${RESET_FORMAT}"
    return 1 2>/dev/null || exit 1
    fi

# 3. Select PROJECT_1 (The other project ID from the list)
    echo -n -e "${BLUE_TEXT}${BOLD_TEXT}🔍 Selecting PROJECT_1...${RESET_FORMAT}"

# Pull the ID that does NOT match PROJECT_2
    PROJECT_1=$(echo "$PROJECT_LIST" | grep -v "^${PROJECT_2}$" | head -n 1)

    if [[ -z "$PROJECT_1" ]]; then
        echo -e "\n${RED_TEXT}${BOLD_TEXT}⚠️ Error: No available project for PROJECT_1${RESET_FORMAT}"
        return 1 2>/dev/null || exit 1
    fi
    echo -e " ${GREEN_TEXT}✓${RESET_FORMAT} ($PROJECT_1)"

# 4. Export variables to the current environment
    echo -n -e "${MAGENTA_TEXT}${BOLD_TEXT}⬆️ Exporting variables...${RESET_FORMAT}"
    export PROJECT_1
    export PROJECT_2
    echo -e " ${GREEN_TEXT}✓${RESET_FORMAT}"

  echo
  echo "${BLUE_TEXT}${BOLD_TEXT}┌──────────────────────┬─────────────────────────────────┐"
  echo "│     Variable      │              Value              │"
  echo "├──────────────────────┼─────────────────────────────────┤"
  echo "│ PROJECT_1         │ $PROJECT_1"
  echo "│ PROJECT_2         │ $PROJECT_2"
  echo "└──────────────────────┴─────────────────────────────────┘${RESET_FORMAT}"
}

assign_projects || exit 1

echo -n "${YELLOW_TEXT}${BOLD_TEXT}🔧 Setting default project to $PROJECT_2...${RESET_FORMAT}"
(gcloud config set project $PROJECT_2 > /dev/null 2>&1) &
spinner
echo " ${GREEN_TEXT}✓${RESET_FORMAT}"

echo -n "${CYAN_TEXT}${BOLD_TEXT}🌍 Detecting compute zone...${RESET_FORMAT}"
(export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone]")) &
spinner
echo " ${GREEN_TEXT}✓${RESET_FORMAT}"

echo -n "${CYAN_TEXT}${BOLD_TEXT}🛠️ Creating VM instance 'instance2'...${RESET_FORMAT}"
(gcloud compute instances create instance2 \
    --zone=$ZONE \
    --machine-type=e2-medium > /dev/null 2>&1) &
spinner
echo " ${GREEN_TEXT}✓${RESET_FORMAT}"

echo
echo "${GREEN_TEXT}${BOLD_TEXT}🔗 Monitoring Console: ${RESET_FORMAT}${WHITE_TEXT}https://console.cloud.google.com/monitoring/settings/metric-scope?project=$PROJECT_2${RESET_FORMAT}"

function check_progress {
    while true; do
        echo
        echo -n "${YELLOW_TEXT}${BOLD_TEXT}🤔 Have you created 'DemoGroup' and uptime check? [Y/N]: ${RESET_FORMAT}"
        read -r user_input
        case "$user_input" in
            [Yy])
                echo
                echo "${CYAN_TEXT}${BOLD_TEXT}⏩ Proceeding to next steps...${RESET_FORMAT}"
                echo
                break
                ;;
            [Nn])
                echo
                echo "${RED_TEXT}${BOLD_TEXT}🛑 Please complete the required setup first.${RESET_FORMAT}"
                ;;
            *)
                echo
                echo "${MAGENTA_TEXT}${BOLD_TEXT}❌ Invalid input. Please answer Y or N.${RESET_FORMAT}"
                ;;
        esac
    done
}

echo
echo "${CYAN_TEXT}${BOLD_TEXT}╔═══════════════════════════════════════════════════╗"
echo "║              MANUAL CONFIGURATION              ║"
echo "╚═══════════════════════════════════════════════════╝${RESET_FORMAT}"
echo "${WHITE_TEXT}Please follow these steps:"
echo "1. Create a Group named 'DemoGroup'"
echo "2. Set up 'DemoGroup uptime check'"
echo "3. Return here to continue${RESET_FORMAT}"
echo

check_progress

echo -n "${RED_TEXT}${BOLD_TEXT}📄 Generating monitoring policy...${RESET_FORMAT}"
(cat > monitoring_policy.json <<EOF_END
{
  "displayName": "Uptime Check Policy",
  "userLabels": {},
  "conditions": [
    {
      "displayName": "VM Instance - Check passed",
      "conditionAbsent": {
        "filter": "resource.type = \"gce_instance\" AND metric.type = \"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.labels.check_id = \"demogroup-uptime-check-f-UeocjSHdQ\"",
        "aggregations": [
          {
            "alignmentPeriod": "300s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_FRACTION_TRUE"
          }
        ],
        "duration": "300s",
        "trigger": {
          "count": 1
        }
      }
    }
  ],
  "alertStrategy": {},
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [],
  "severity": "SEVERITY_UNSPECIFIED"
}
EOF_END
) &
spinner
echo " ${GREEN_TEXT}✓${RESET_FORMAT}"

echo -n "${CYAN_TEXT}${BOLD_TEXT}📡 Creating monitoring policy...${RESET_FORMAT}"
(gcloud alpha monitoring policies create --policy-from-file="monitoring_policy.json" > /dev/null 2>&1) &
spinner
echo " ${GREEN_TEXT}✓${RESET_FORMAT}"

echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}╔═══════════════════════════════════════════════════╗"
echo "║                 THANK YOU!                  ║"
echo "╚═══════════════════════════════════════════════════╝${RESET_FORMAT}"
echo "${WHITE_TEXT}For more GCP tutorials and labs, subscribe to:"
echo "${BLUE_TEXT}${UNDERLINE_TEXT}https://youtube.com/@drabhishek.5460${RESET_FORMAT}"
echo
echo "${GREEN_TEXT}${BOLD_TEXT}✅ Lab completed successfully!${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}⚠️ Remember to clean up resources when finished.${RESET_FORMAT}"
