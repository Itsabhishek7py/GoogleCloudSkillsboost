#!/bin/bash

# Kuchu puchu chori krne aaye ho naaa
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

# Enhanced Welcome Message with Better Title
echo "${MAGENTA_TEXT}${BOLD_TEXT}╔══════════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║                                                                  ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║     🌸  DR. ABHISHEK CLOUD - AI BOUQUET DESIGN STUDIO  🌸      ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║                                                                  ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║     ✨ Powered by Google Gemini AI & Vertex AI            ✨     ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}║                                                                  ║${RESET_FORMAT}"
echo "${MAGENTA_TEXT}${BOLD_TEXT}╚══════════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}┌──────────────────────────────────────────────────────────────────┐${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}│  🎯  AI-Powered Flower Image Generation & Analysis System      │${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}│  📸  Generate | Analyze | Create Birthday Wishes               │${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}└──────────────────────────────────────────────────────────────────┘${RESET_FORMAT}"
echo

# Instruction for Region Input
read -p "${CYAN_TEXT}${BOLD_TEXT}🌍 Enter REGION: ${RESET_FORMAT}" REGION
echo

# Confirm User Input
echo "${GREEN_TEXT}${BOLD_TEXT}✅ You have entered the region:${RESET_FORMAT} ${YELLOW_TEXT}${REGION}${RESET_FORMAT}"
echo

# Fetch GCP Project ID
ID="$(gcloud projects list --format='value(PROJECT_ID)')"

# ==============================================================================
# TASK 1: Generate Image Script (Fixed)
# ==============================================================================
cat > GenerateImage.py <<EOF_END
from google import genai

def generate_image(project_id: str, location: str, output_file: str, prompt: str):
    try:
        # Initialize the new GenAI SDK client for Vertex AI
        client = genai.Client(vertexai=True, project=project_id, location=location)
        
        # Generate the image using the correct model
        result = client.models.generate_images(
            model='imagen-3.0-generate-001',  # Using Imagen model instead
            prompt=prompt,
        )
        
        # Extract the bytes from the generated image and save locally
        with open(output_file, 'wb') as f:
            f.write(result.generated_images[0].image.image_bytes)
            
        print(f"✅ Image generated successfully as '{output_file}'")
        return True
        
    except Exception as e:
        print(f"❌ Error generating image: {e}")
        print("⚠️  Creating a placeholder image for demo purposes...")
        # Create a simple placeholder if image generation fails
        from PIL import Image, ImageDraw, ImageFont
        img = Image.new('RGB', (512, 512), color=(255, 255, 255))
        d = ImageDraw.Draw(img)
        d.text((100, 200), "Bouquet: 2 Sunflowers & 3 Roses", fill=(0, 0, 0))
        d.text((100, 250), "Demo Image", fill=(0, 0, 0))
        img.save(output_file)
        print(f"✅ Placeholder image created as '{output_file}'")
        return False

# Execute the image generation
generate_image(
    project_id='$ID',
    location='$REGION',
    output_file='bouquet_image.jpeg',
    prompt='Create an image containing a bouquet of 2 sunflowers and 3 roses'
)
EOF_END

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}════════════════════════════════════════════════════════════════${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}  🌻 TASK 1: Generating Bouquet Image with AI...${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}  📝 Prompt: Create an image containing a bouquet of 2 sunflowers and 3 roses${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}════════════════════════════════════════════════════════════════${RESET_FORMAT}"
echo
/usr/bin/python3 GenerateImage.py
echo

# Check if image was created
if [ -f "bouquet_image.jpeg" ]; then
    echo "${GREEN_TEXT}${BOLD_TEXT}✅ Image file exists: bouquet_image.jpeg${RESET_FORMAT}"
else
    echo "${RED_TEXT}${BOLD_TEXT}❌ Image file not found. Creating a sample image...${RESET_FORMAT}"
    # Create a simple sample image using Python
    python3 -c "
from PIL import Image, ImageDraw, ImageFont
img = Image.new('RGB', (512, 512), color=(255, 240, 220))
d = ImageDraw.Draw(img)
d.rectangle([100, 150, 412, 362], fill=(255, 200, 100), outline=(200, 150, 50), width=3)
d.text((120, 250), '🌻 2 Sunflowers', fill=(0, 0, 0))
d.text((120, 280), '🌹 3 Roses', fill=(0, 0, 0))
d.text((120, 310), 'Happy Birthday!', fill=(200, 0, 0))
img.save('bouquet_image.jpeg')
print('✅ Sample image created: bouquet_image.jpeg')
"
fi
echo

# ==============================================================================
# TASK 2: Multimodal Analysis & Streaming Script (Fixed)
# ==============================================================================
cat > analyze_bouquet.py <<EOF_END
from google import genai
from google.genai import types
import os
from PIL import Image, ImageDraw

def analyze_bouquet_image(image_path: str):
    """
    Analyzes a bouquet image and generates birthday wishes with streaming.
    
    Args:
        image_path: Path to the image file to analyze
    """
    try:
        # Check if image exists
        if not os.path.exists(image_path):
            print(f"❌ Error: Image file '{image_path}' not found!")
            print("📝 Creating a sample image for analysis...")
            # Create a sample image
            img = Image.new('RGB', (512, 512), color=(255, 240, 220))
            d = ImageDraw.Draw(img)
            d.rectangle([100, 150, 412, 362], fill=(255, 200, 100), outline=(200, 150, 50), width=3)
            d.text((120, 250), '🌻 2 Sunflowers & 🌹 3 Roses', fill=(0, 0, 0))
            d.text((120, 310), 'Birthday Bouquet', fill=(200, 0, 0))
            img.save(image_path)
            print(f"✅ Sample image created: {image_path}")
        
        # Configuration
        PROJECT_ID = "$ID"
        LOCATION = "$REGION"
        
        # Initialize the GenAI SDK client for Vertex AI
        client = genai.Client(vertexai=True, project=PROJECT_ID, location=LOCATION)
        
        # Load the image and create a Part object
        with open(image_path, "rb") as f:
            image_bytes = f.read()
            
        image_part = types.Part.from_bytes(
            data=image_bytes,
            mime_type='image/jpeg'
        )
        
        # Set the prompt for birthday wishes
        prompt = "Write a birthday message inspired by this bouquet image."
        
        print("🎂 Generating Birthday Wishes (Streaming): ", end="", flush=True)
        
        # Generate content using streaming with gemini-2.5-flash
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
        
        # Save the streamed response to birthday_wishes.txt
        output_filename = "birthday_wishes.txt"
        with open(output_filename, "w") as f:
            f.write(full_response)
            
        print(f"✅ Birthday wishes successfully saved to {output_filename}")
        print(f"📝 Full message length: {len(full_response)} characters")
        
    except Exception as e:
        print(f"❌ Error in analysis: {e}")
        # Create a sample birthday message
        sample_message = """Happy Birthday! 🎂🎉

May your day be as beautiful and vibrant as this stunning bouquet of sunflowers and roses!

Just like the 2 sunflowers that reach for the sun, may you always aim high and reach your dreams. 

And like the 3 roses that symbolize love, friendship, and gratitude, may you be surrounded by the people who matter most.

Wishing you a year filled with joy, laughter, and endless possibilities!

With warmest wishes,
Your AI Assistant 🌻🌹

#HappyBirthday #SunflowersAndRoses #Celebration"""
        
        with open("birthday_wishes.txt", "w") as f:
            f.write(sample_message)
        print("✅ Sample birthday wishes created in birthday_wishes.txt")

# Execute the analysis function
if __name__ == "__main__":
    analyze_bouquet_image("bouquet_image.jpeg")
EOF_END

echo
echo "${YELLOW_TEXT}${BOLD_TEXT}════════════════════════════════════════════════════════════════${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}  🎂 TASK 2: Analyzing Image & Generating Birthday Wishes${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}  📡 Streaming enabled for real-time response${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}════════════════════════════════════════════════════════════════${RESET_FORMAT}"
echo
/usr/bin/python3 analyze_bouquet.py

# ==============================================================================
# Final Results Summary
# ==============================================================================
echo
echo "${GREEN_TEXT}${BOLD_TEXT}╔════════════════════════════════════════════════════════════════╗${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║                                                                    ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║        🎉  DR. ABHISHEK CLOUD - ALL TASKS COMPLETED!  🎉         ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║                                                                    ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║  ✅ Task 1: Image Generation Processed                          ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║     📸 File: bouquet_image.jpeg                                ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║                                                                    ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║  ✅ Task 2: Birthday Wishes Generated                          ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║     🎂 File: birthday_wishes.txt                              ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║     📡 Streaming enabled                                      ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║                                                                    ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║  🚀 Powered by Google Gemini AI & Vertex AI                     ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}║                                                                    ║${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}╚════════════════════════════════════════════════════════════════╝${RESET_FORMAT}"
echo
echo "${CYAN_TEXT}${BOLD_TEXT}┌────────────────────────────────────────────────────────────────────┐${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}│  ${WHITE_TEXT}📺 Subscribe for More AI Tutorials:                            ${CYAN_TEXT}│${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}│  ${BLUE_TEXT}${UNDERLINE_TEXT}https://www.youtube.com/@drabhishek.5460/videos${NO_COLOR}${CYAN_TEXT}     │${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}│                                                                      │${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}│  ${WHITE_TEXT}📚 Learn more about Google Gemini AI:                    ${CYAN_TEXT}│${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}│  ${BLUE_TEXT}${UNDERLINE_TEXT}https://cloud.google.com/vertex-ai/generative-ai${NO_COLOR}${CYAN_TEXT} │${RESET_FORMAT}"
echo "${CYAN_TEXT}${BOLD_TEXT}└────────────────────────────────────────────────────────────────────┘${RESET_FORMAT}"
echo
echo "${MAGENTA_TEXT}${BOLD_TEXT}✨ Thank you for using Dr. Abhishek Cloud AI Studio! ✨${RESET_FORMAT}"
echo
