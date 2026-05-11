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
## Text format
NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

echo
read -p "${YELLOW_TEXT}${BOLD_TEXT}Enter ZONE: ${RESET_FORMAT}" ZONE
export ZONE=$ZONE
export REGION="${ZONE%-*}"

gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION

gcloud compute instances create gcelab \
  --zone $ZONE \
  --machine-type e2-standard-2

## Wait until VM is running
while true; do
  STATUS=$(gcloud compute instances describe gcelab \
    --zone "$ZONE" \
    --format='get(status)')
  echo "🔹  VM gcelab Current status: $STATUS"
  if [ "$STATUS" = "RUNNING" ]; then
    break
  fi
  sleep 5
done

## Wait for SSH readiness
until gcloud compute ssh gcelab \
  --zone "$ZONE" \
  --quiet \
  --command "echo ready" 2>/dev/null; do
  echo "🔹  Waiting for VM gcelab SSH readiness..."
  sleep 10
done

gcloud compute disks create mydisk --size=200GB \
  --zone $ZONE

gcloud compute instances attach-disk gcelab \
  --disk mydisk \
  --zone $ZONE

cat > prepare_disk.sh <<'EOF_END'
ls -l /dev/disk/by-id/
sudo mkdir /mnt/mydisk
sudo mkfs.ext4 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1
sudo mount -o discard,defaults /dev/disk/by-id/scsi-0Google_PersistentDisk_persistent-disk-1 /mnt/mydisk
EOF_END

gcloud compute scp prepare_disk.sh gcelab:/tmp \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet

gcloud compute ssh gcelab \
  --project=$DEVSHELL_PROJECT_ID \
  --zone=$ZONE \
  --quiet \
  --command="bash /tmp/prepare_disk.sh"
