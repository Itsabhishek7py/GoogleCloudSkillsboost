#!/bin/bash


# Bright Foreground Colors
BLACK=$'\033[0;90m'
RED=$'\033[0;91m'
GREEN=$'\033[0;92m'
YELLOW=$'\033[0;93m'
BLUE=$'\033[0;94m'
MAGENTA=$'\033[0;95m'
CYAN=$'\033[0;96m'
WHITE=$'\033[0;97m'

# Text Formatting
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
RESET=$'\033[0m'

# Background Colors
BG_RED=$'\033[0;41m'
BG_GREEN=$'\033[0;42m'
BG_YELLOW=$'\033[0;43m'
BG_BLUE=$'\033[0;44m'

# Clear screen for better visibility
clear

# Welcome Banner
echo "${BLUE}${BOLD}╔════════════════════════════════════════════╗${RESET}"
echo "${BLUE}${BOLD}║                                            ║${RESET}"
echo "${BLUE}${BOLD}║    ${WHITE}${BG_BLUE} GEMINI AI IMPLEMENTATION SCRIPT ${RESET}${BLUE}${BOLD}    ║${RESET}"
echo "${BLUE}${BOLD}║                                            ║${RESET}"
echo "${BLUE}${BOLD}╚════════════════════════════════════════════╝${RESET}"
echo

# Get user input with validation
while true; do
    echo "${YELLOW}${BOLD}Enter your Google Cloud Region (e.g., us-central1):${RESET}"
    read -r user_region
    if [ -n "$user_region" ]; then
        export REGION="$user_region"
        echo "${GREEN}✓ Region set to: ${WHITE}${BOLD}$REGION${RESET}"
        break
    else
        echo "${RED}✗ Region cannot be empty. Please try again.${RESET}"
    fi
done
echo

# Project ID detection
echo "${CYAN}${BOLD}Retrieving Project ID...${RESET}"
ID="$(gcloud projects list --format='value(PROJECT_ID)' | head -1)"
if [ -z "$ID" ]; then
    echo "${RED}${BOLD}Error: Could not retrieve Project ID. Please ensure you're authenticated.${RESET}"
    exit 1
fi
echo "${GREEN}✓ Project ID: ${WHITE}${BOLD}$ID${RESET}"
echo

# Create Python script with improved formatting
echo "${MAGENTA}${BOLD}Creating genai.py script...${RESET}"
cat > genai.py <<EOF
#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import vertexai
from vertexai.generative_models import GenerativeModel, Part
import time

def generate_text(project_id: str, location: str) -> str:
    """Generate text using Gemini model with image input"""
    
    print("\\nInitializing Vertex AI...")
    vertexai.init(project=project_id, location=location)
    
    print("Loading Gemini 2.0 Flash model...")
    model = GenerativeModel("gemini-2.0-flash-001")
    
    print("Processing image and generating response...")
    start_time = time.time()
    
    response = model.generate_content([
        Part.from_uri(
            "gs://generativeai-downloads/images/scones.jpg",
            mime_type="image/jpeg"
        ),
        "Describe in detail what is shown in this image?"
    ])
    
    processing_time = time.time() - start_time
    print(f"\\nProcessing completed in {processing_time:.2f} seconds")
    
    return response.text

if __name__ == "__main__":
    # Configuration
    PROJECT_ID = "$ID"
    LOCATION = "$REGION"
    
    print("\\n=== Gemini AI Image Analysis ===")
    try:
        result = generate_text(PROJECT_ID, LOCATION)
        print("\\n=== Analysis Result ===")
        print(result)
    except Exception as e:
        print(f"\\n{RED}Error occurred: {str(e)}{RESET}")
EOF

echo "${GREEN}✓ genai.py script created successfully!${RESET}"
echo

# First execution
echo "${YELLOW}${BOLD}Running first analysis...${RESET}"
echo "${BLUE}──────────────────────────────────────────${RESET}"
/usr/bin/python3 /home/student/genai.py
echo "${BLUE}──────────────────────────────────────────${RESET}"
echo "${GREEN}✓ First analysis completed!${RESET}"
echo

# Delay with progress indicator
echo "${YELLOW}${BOLD}Waiting 30 seconds before second analysis${RESET}"
for i in {1..30}; do
    printf "${BLUE}⏳ ${RESET}"
    sleep 1
    if (( i % 10 == 0 )); then
        printf " ${i}s\n"
    fi
done
printf "\n"
echo "${GREEN}✓ Ready for second analysis${RESET}"
echo

# Second execution
echo "${YELLOW}${BOLD}Running second analysis...${RESET}"
echo "${BLUE}──────────────────────────────────────────${RESET}"
/usr/bin/python3 /home/student/genai.py
echo "${BLUE}──────────────────────────────────────────${RESET}"
echo "${GREEN}✓ Second analysis completed!${RESET}"
echo

# Completion Banner
echo "${GREEN}${BOLD}╔════════════════════════════════════════════╗${RESET}"
echo "${GREEN}${BOLD}║                                            ║${RESET}"
echo "${GREEN}${BOLD}║    ${WHITE}${BG_GREEN} LAB EXECUTED SUCCESSFULLY ${RESET}${GREEN}${BOLD}       ║${RESET}"
echo "${GREEN}${BOLD}║                                            ║${RESET}"
echo "${GREEN}${BOLD}╚════════════════════════════════════════════╝${RESET}"
echo
echo "${WHITE}${BOLD}For more cloud tutorials and guides:${RESET}"
echo "${YELLOW}${BOLD}👉 Subscribe to Dr. Abhishek Cloud Tutorials:${RESET}"
echo "${BLUE}${UNDERLINE}https://www.youtube.com/@drabhishek.5460/videos${RESET}"
echo
echo "${MAGENTA}Thank you Do like share and subscribe to the channel ${RESET}"
echo
