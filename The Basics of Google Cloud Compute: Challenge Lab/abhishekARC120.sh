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
#----------------------------------------------------start--------------------------------------------------#

echo "${BG_MAGENTA}${BOLD}Starting Execution${RESET}"

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

# Create instance with Debian 12 (bookworm)
gcloud compute instances create my-instance \
    --machine-type=e2-medium \
    --zone=$ZONE \
    --image-project=debian-cloud \
    --image-family=debian-12 \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-balanced \
    --create-disk=size=100GB,type=pd-standard,mode=rw,device-name=additional-disk \
    --tags=http-server

# Create additional disk
gcloud compute disks create mydisk \
    --size=200GB \
    --zone=$ZONE

# Attach additional disk to instance
gcloud compute instances attach-disk my-instance \
    --disk=mydisk \
    --zone=$ZONE

sleep 30

# Create script to prepare the disk and install nginx
cat > prepare_disk.sh <<'EOF_END'
#!/bin/bash
sudo apt update
sudo apt install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
EOF_END

# Copy the script to the instance
gcloud compute scp prepare_disk.sh my-instance:/tmp --zone=$ZONE --quiet

# Execute the script on the instance
gcloud compute ssh my-instance --zone=$ZONE --quiet --command="sudo bash /tmp/prepare_disk.sh"

echo "${BG_RED}${BOLD}Congratulations For Completing The Lab !!!${RESET}"

echo "${CYAN}${BOLD}"
echo "**********************************************************************"
echo "* Don't forget to subscribe to Dr. Abhishek's YouTube channel:       *"
echo "* https://www.youtube.com/@drabhishek.5460/videos                    *"
echo "*                                                                    *"
echo "* Thank you for following along!                                     *"
echo "**********************************************************************"
echo "${RESET}"

#-----------------------------------------------------end----------------------------------------------------------#
