#!/bin/bash
## Changed by nov05, on 2026-05-09

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

spinner() {
    local pid=$!
    local spin='|/-\'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r${CYAN_TEXT}Loading...${RESET_FORMAT} [%c]   " "${spin:$i:1}"
        sleep 0.1
    done
    printf "\r${GREEN_TEXT}Done!         ${RESET_FORMAT}\n\n"  
}
(sleep 3) & spinner
