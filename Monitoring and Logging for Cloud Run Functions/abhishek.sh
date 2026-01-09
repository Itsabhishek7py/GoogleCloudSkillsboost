#!/bin/bash

# ================= COLORS =================
BLUE=$'\033[0;94m'
GREEN=$'\033[0;92m'
YELLOW=$'\033[0;93m'
RED=$'\033[0;91m'
MAGENTA=$'\033[0;95m'
CYAN=$'\033[0;96m'
WHITE=$'\033[0;97m'
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
RESET=$'\033[0m'

# ================= EFFECT FUNCTIONS =================

# Typing effect
type_text () {
  text="$1"
  color="$2"
  for (( i=0; i<${#text}; i++ )); do
    echo -ne "${color}${text:$i:1}${RESET}"
    sleep 0.02
  done
  echo
}

# Progress bar
progress_bar () {
  duration=$1
  already_done=0
  for ((i=0; i<=100; i+=5)); do
    printf "\r${CYAN}["
    for ((j=0; j<i/5; j++)); do printf "█"; done
    for ((j=i/5; j<20; j++)); do printf " "; done
    printf "] %d%%${RESET}" "$i"
    sleep $duration
  done
  echo
}

# ================= HEADER =================
echo "${CYAN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
type_text "🚀 WELCOME TO DR ABHISHEK CLOUD TUTORIALS 🚀" "${MAGENTA}${BOLD}"
echo "${CYAN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo

type_text "⚡ Initializing Cloud Run monitoring & load testing..." "${YELLOW}${BOLD}"
echo

# ================= AUTH =================
echo "${BLUE}${BOLD}▬▬▬▬▬▬▬▬▬ AUTHENTICATION ▬▬▬▬▬▬▬▬▬${RESET}"
type_text "🔐 Checking active GCP account..." "${CYAN}"
gcloud auth list
progress_bar 0.03
echo

# ================= REGION =================
echo "${BLUE}${BOLD}▬▬▬▬▬▬▬▬▬ REGION SETUP ▬▬▬▬▬▬▬▬▬${RESET}"
type_text "🌍 Fetching default compute region..." "${CYAN}"
export REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
type_text "✔ Selected Region: $REGION" "${GREEN}${BOLD}"
echo

# ================= CLOUD RUN =================
echo "${BLUE}${BOLD}▬▬▬▬▬ CLOUD RUN DEPLOYMENT ▬▬▬▬▬${RESET}"
type_text "🚀 Deploying Hello World Cloud Run service..." "${CYAN}"

gcloud run deploy helloworld \
  --image=gcr.io/cloudrun/hello \
  --region=$REGION \
  --platform=managed \
  --allow-unauthenticated \
  --execution-environment=gen2 \
  --max-instances=5

progress_bar 0.04
type_text "✅ Cloud Run service deployed successfully!" "${GREEN}${BOLD}"
echo

# ================= VEGETA =================
echo "${BLUE}${BOLD}▬▬▬▬▬▬▬▬ VEGETA SETUP ▬▬▬▬▬▬▬▬${RESET}"
type_text "📥 Downloading Vegeta load testing tool..." "${CYAN}"
curl -LO 'https://github.com/tsenart/vegeta/releases/download/v12.12.0/vegeta_12.12.0_linux_386.tar.gz'
type_text "📦 Extracting Vegeta..." "${YELLOW}"
tar -xvzf vegeta_12.12.0_linux_386.tar.gz
progress_bar 0.02
type_text "✔ Vegeta installed successfully!" "${GREEN}${BOLD}"
echo

# ================= SERVICE URL =================
echo "${BLUE}${BOLD}▬▬▬▬▬▬▬ CLOUD RUN URL ▬▬▬▬▬▬▬${RESET}"
type_text "🔗 Fetching Cloud Run service URL..." "${CYAN}"
CLOUD_RUN_URL=$(gcloud run services describe helloworld \
  --region=$REGION \
  --format='value(status.url)')
type_text "✔ Service URL: $CLOUD_RUN_URL" "${GREEN}${BOLD}"
echo

# ================= LOAD TEST =================
echo "${BLUE}${BOLD}▬▬▬▬▬▬▬ LOAD TESTING ▬▬▬▬▬▬▬${RESET}"
type_text "🔥 Running 300s load test at 200 RPS..." "${YELLOW}${BOLD}"
echo "GET $CLOUD_RUN_URL" | ./vegeta attack -duration=300s -rate=200 > results.bin
progress_bar 0.05
type_text "✔ Load test completed! Results saved to results.bin" "${GREEN}${BOLD}"
echo

# ================= LOGGING =================
echo "${BLUE}${BOLD}▬▬▬▬▬▬ LOGGING METRIC ▬▬▬▬▬▬${RESET}"
type_text "📊 Creating latency logging metric..." "${CYAN}"

gcloud logging metrics create nFunctionLatency-Logs \
  --project=$DEVSHELL_PROJECT_ID \
  --description="Cloud Run latency monitoring" \
  --log-filter='resource.type="cloud_run_revision" AND resource.labels.service_name="helloworld"'

type_text "✔ Logging metric created successfully!" "${GREEN}${BOLD}"
echo

# ================= FINISH =================
echo "${GREEN}${BOLD}╔════════════════════════════════════════════════════════╗${RESET}"
type_text "🎉 ALL TASKS COMPLETED SUCCESSFULLY! 🎉" "${GREEN}${BOLD}"
echo "${GREEN}${BOLD}╚════════════════════════════════════════════════════════╝${RESET}"
echo

# ================= SUBSCRIBE =================
type_text "📢 IMPORTANT: Subscribe for more Cloud & GCP Labs!" "${MAGENTA}${BOLD}"
echo "${RED}${BOLD}👉 SUBSCRIBE NOW:${RESET} ${BLUE}${UNDERLINE}https://www.youtube.com/@drabhishek.5460${RESET}"
echo
type_text "☁️ Happy Cloud Computing & Keep Learning 🚀" "${CYAN}${BOLD}"
