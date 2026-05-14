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

# Array of color codes excluding black and white
TEXT_COLORS=($RED $GREEN $YELLOW $BLUE $MAGENTA $CYAN)
BG_COLORS=($BG_RED $BG_GREEN $BG_YELLOW $BG_BLUE $BG_MAGENTA $BG_CYAN)

# Pick random colors
RANDOM_TEXT_COLOR=${TEXT_COLORS[$RANDOM % ${#TEXT_COLORS[@]}]}
RANDOM_BG_COLOR=${BG_COLORS[$RANDOM % ${#BG_COLORS[@]}]}

#----------------------------------------------------start--------------------------------------------------#

echo "${CYAN}${BOLD}"
echo "**********************************************************************"
echo "* Welcome to Dr. Abhishek Cloud Tutorial!                            *"
echo "*                                                                    *"
echo "* Please do like, share and subscribe to the channel:                *"
echo "* https://www.youtube.com/@drabhishek.5460/videos                    *"
echo "*                                                                    *"
echo "* Thank you for your support!                                        *"
echo "**********************************************************************"
echo "${RESET}"

echo "${RANDOM_BG_COLOR}${RANDOM_TEXT_COLOR}${BOLD}Starting Execution${RESET}"

# Step 1: Set Compute Zone
echo "${BOLD}${BLUE}Setting Compute Zone${RESET}"
export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])") 

# Step 2: Enable Compute Engine API
echo "${BOLD}${GREEN}Enabling Compute Engine API${RESET}"
gcloud services enable compute.googleapis.com

sleep 15

# Step 3: Create VM Instance
echo "${BOLD}${CYAN}Creating VM Instance 'instance-1'${RESET}"
curl -X POST "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/instances" \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"instance-1\",
    \"machineType\": \"zones/$ZONE/machineTypes/n1-standard-1\",
    \"networkInterfaces\": [{}],
    \"disks\": [{
      \"type\": \"PERSISTENT\",
      \"boot\": true,
      \"initializeParams\": {
        \"sourceImage\": \"projects/debian-cloud/global/images/family/debian-11\"
      }
    }]
  }"

# Function to prompt user to check their progress
function check_progress {
    while true; do
        echo
        echo -n "${BOLD}${YELLOW}Have you checked your progress for Task 2 ? (Y/N): ${RESET}"
        read -r user_input
        if [[ "$user_input" == "Y" || "$user_input" == "y" ]]; then
            echo
            echo "${BOLD}${GREEN}Great! Proceeding to the next steps...${RESET}"
            echo
            break
        elif [[ "$user_input" == "N" || "$user_input" == "n" ]]; then
            echo
            echo "${BOLD}${RED}Please check your progress for Task 2 and then press Y to continue.${RESET}"
        else
            echo
            echo "${BOLD}${MAGENTA}Invalid input. Please enter Y or N.${RESET}"
        fi
    done
}

# Call function to check progress before proceeding
check_progress

# Step 4: Delete VM Instance
echo "${BOLD}${YELLOW}Deleting VM Instance 'instance-1'${RESET}"
curl -X DELETE \
  -H "Authorization: Bearer $(gcloud auth application-default print-access-token)" \
  -H "Content-Type: application/json" \
  "https://compute.googleapis.com/compute/v1/projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/instances/instance-1"

echo


echo "${CYAN}${BOLD}"
echo "**********************************************************************"
echo "* Lab execution completed successfully!                              *"
echo "*                                                                    *"
echo "* Don't forget to subscribe to Dr. Abhishek's YouTube channel:       *"
echo "* https://www.youtube.com/@drabhishek.5460/videos                    *"
echo "*                                                                    *"
echo "* Thank you for following along!                                     *"
echo "**********************************************************************"
echo "${RESET}"

echo -e "\n"  # Adding one blank line

cd

remove_files() {
    # Loop through all files in the current directory
    for file in *; do
        # Check if the file name starts with "gsp", "arc", or "shell"
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
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
