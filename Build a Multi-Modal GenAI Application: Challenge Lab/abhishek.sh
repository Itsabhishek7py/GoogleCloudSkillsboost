#!/bin/bash

# Color Definitions
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

clear

# Welcome Message
echo "${MAGENTA_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}        WELCOME TO DR ABHISHEK CLOUD       ${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo

# Instruction for Region Input
read -p "${CYAN_TEXT}${BOLD_TEXT}Enter REGION: ${RESET_FORMAT}" REGION
echo

# Confirm User Input
echo "${GREEN_TEXT}${BOLD_TEXT}You have entered the region:${RESET_FORMAT} ${YELLOW_TEXT}${REGION}${RESET_FORMAT}"
echo

# Fetch GCP Project ID
ID="$(gcloud projects list --format='value(PROJECT_ID)')"

# ==============================================================================
# TASK 1: Generate Image Script
# ==============================================================================
cat > GenerateImage.py <<EOF_END
from google import genai

def generate_image(project_id: str, location: str, output_file: str, prompt: str):
    # Initialize the new GenAI SDK client for Vertex AI
    client = genai.Client(vertexai=True, project=project_id, location=location)
   
    # Generate the image using the correct Imagen model
    result = client.models.generate_images(
        model='imagen-3.0-generate-002',
        prompt=prompt,
    )
   
    # Extract the bytes from the generated image and save locally
    with open(output_file, 'wb') as f:
        f.write(result.generated_images[0].image.image_bytes)

generate_image(
    project_id='$ID',
    location='$REGION',
    output_file='image.jpeg',
    prompt='Create an image containing a bouquet of 2 sunflowers and 3 roses'
)
EOF_END

echo "${YELLOW_TEXT}${BOLD_TEXT}Generating an image of flowers... Please wait.${RESET_FORMAT}"
/usr/bin/python3 GenerateImage.py
echo "${GREEN_TEXT}${BOLD_TEXT}Image generated successfully! Check 'image.jpeg' in your working directory.${RESET_FORMAT}"

# ==============================================================================
# TASK 2: Multimodal Analysis & Streaming Script
# ==============================================================================
cat > genai.py <<EOF_END
from google import genai
from google.genai import types

def analyze_bouquet_image(project_id: str, location: str, image_path: str):
    # Initialize the new GenAI SDK client for Vertex AI
    client = genai.Client(vertexai=True, project=project_id, location=location)
   
    # Load the generated image and create a Part object
    with open(image_path, "rb") as f:
        image_bytes = f.read()
       
    image_part = types.Part.from_bytes(
        data=image_bytes,
        mime_type='image/jpeg'
    )
   
    # Set the prompt for birthday wishes
    prompt = "Write a birthday message inspired by this bouquet image."
   
    print("📷 Generating Birthday Wishes (Streaming): \n", end="", flush=True)
   
    # Generate content using streaming
    response_stream = client.models.generate_content_stream(
        model="gemini-2.5-flash",
        contents=[image_part, prompt]
    )
   
    # Iterate through the stream, print to console, and build the full response
    full_response = ""
    for chunk in response_stream:
        if chunk.text:
            print(chunk.text, end="", flush=True)
            full_response += chunk.text
    print("\n")
   
    # Save the streamed response to a .txt file
    output_filename = "birthday_wishes.txt"
    with open(output_filename, "w") as f:
        f.write(full_response)
       
    print(f"✅ Birthday wishes successfully saved to {output_filename}")

# Run the function
analyze_bouquet_image(
    project_id="$ID",
    location="$REGION",
    image_path="image.jpeg"
)
EOF_END

echo "${YELLOW_TEXT}${BOLD_TEXT}Analyzing the generated image with Gemini and writing wishes...${RESET_FORMAT}"
/usr/bin/python3 genai.py

# Enhanced Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔══════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║                                                  ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║          🎉 LAB COMPLETED SUCCESSFULLY! 🎉       ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║                                                  ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚══════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}┌──────────────────────────────────────────────────┐${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}│  ${WHITE_TEXT}🔍 Explore more AI content at:                  ${CYAN_TEXT}│${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}│  ${BLUE_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460/videos${NO_COLOR}${CYAN_TEXT}   │${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}└──────────────────────────────────────────────────┘${RESET_FORMAT}"
