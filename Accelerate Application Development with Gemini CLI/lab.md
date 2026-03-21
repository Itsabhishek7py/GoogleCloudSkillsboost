
# Accelerate Application Development with Gemini CLI: Challenge Lab #GENAI144 #qwiklabs

[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/i4LozZHsiX8)

> **Note:** Establish Hybrid Network Connectivity with NCC

---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Dr Abhishek](https://www.youtube.com/@drabhishek.5460/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏

###  Kindly Watch the video to complete else ur lab will fail :D
Video [![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/i4LozZHsiX8)

---

## 🔹 Task 1 — Setup

```bash
mkdir journal-app
cd journal-app
mkdir .gemini
nano .gemini/.env
```

```env
GOOGLE_CLOUD_PROJECT=qwiklabs-gcp-00-bef3adf59e4d
GOOGLE_CLOUD_LOCATION=us-central1
GOOGLE_GENAI_USE_VERTEXAI=true
```

```bash
nano ~/.gemini/settings.json
```

```json
{
  "telemetry": {
    "enabled": true,
    "target": "gcp"
  },
  "ui": {
    "showMemoryUsage": true,
    "showColor": true
  }
}
```

```bash
gemini
/help
/init
```

```bash
nano GEMINI.md
```

(Paste lab content)

```bash
/refresh
/context
```

---

## 🔹 Task 2 — Generate API

```bash
gemini
```

```
Generate a REST API supporting full lifecycle for a financial journal.
Follow:
1. Plan
2. Ask questions
3. Generate code
4. Use in-memory DB with sample data
5. Provide run steps
```

```bash
pip install flask
python app.py
```

```bash
curl http://localhost:8080/v1/journals
```

---

## 🔹 Task 3 — Unit Test

```
@main.py write a unit test for get journals endpoint
```

```bash
pip install pytest
python -m pytest
```

---

## 🔹 Task 4 — CLI Extension
### gemini extensions new
```bash
gemini extensions new ~/generate-tests custom-commands
```

```
Name: generate-tests
Template: custom-commands
```

```bash
cd ~/generate-tests

# Rename directory fs → tests
mv commands/fs commands/tests

# Rename grep-code.toml → unit.toml
mv commands/tests/grep-code.toml commands/tests/unit.toml

# Update name in gemini-extension.json
sed -i 's/"name": "custom-commands"/"name": "generate-unit-tests"/' gemini-extension.json

# Verify JSON
cat gemini-extension.json

# Update unit.toml content
cat > commands/tests/unit.toml << 'EOF'
description = "Generate unit tests for supplied code."
prompt = """
Generate unit tests for the following {{args}}.
"""
EOF

# Verify file
cat commands/tests/unit.toml
```

```bash
nano ../gemini-extensions.json
```

```json
"name": "generate-unit-tests"
```

```bash
nano unit.toml
```

```toml
description = "Generate unit tests for supplied code."
prompt = """
Generate unit tests for the following {{args}}.
"""
```

```bash
cd ~/journal-app
gemini extensions link ../generate-tests
gemini
/extensions list
/help
```

```
/tests:unit all methods in @main.py
```

```bash
python -m pytest
```

---

## 🔹 Task 5 — Checkpoint

```bash
nano ~/.gemini/settings.json
```

```json
{
  "telemetry": {
    "enabled": true,
    "target": "gcp"
  },
  "ui": {
    "showMemoryUsage": true,
    "showColor": true
  },
  "general": {
    "checkpointing": {
      "enabled": true
    }
  }
}
```

```bash
gemini
/restore
```

```
Generate a README.md file
/restore
```

---

## 🔹 Task 6 — Deploy

```bash
gemini extensions install https://github.com/GoogleCloudPlatform/cloud-run-mcp
gemini
/help
```

```
/deploy
```

```
Service: journal-app
Region: us-central1
Project: qwiklabs-gcp-00-bef3adf59e4d
Allow unauthenticated: yes
```

```bash
curl https://<cloud-run-url>/v1/journals
```

---


<div align="center">

<h3 style="font-family: 'Segoe UI', sans-serif; color: linear-gradient(90deg, #4F46E5, #E114E5);">🌟 Connect with Cloud Enthusiasts 🌟</h3>
<p style="font-family: 'Segoe UI', sans-serif;">Join the community, share knowledge, and grow together!</p>

<a href="https://t.me/+gBcgRTlZLyM4OGI1" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_Telegram_Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white&labelColor=2CA5E0" alt="Telegram Channel"/>
</a>

<a href="https://t.me/+RujS6mqBFawzZDFl" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_Telegram_Group-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white&labelColor=2CA5E0" alt="Telegram Group"/>
</a>

<a href="https://www.whatsapp.com/channel/0029VbCB6SpLo4hdpzFoD73f" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_WhatsApp_Channel-25D366?style=for-the-badge&logo=whatsapp&logoColor=white&labelColor=25D366" alt="WhatsApp Channel"/>
</a>

<a href="https://www.youtube.com/@drabhishek.5460?sub_confirmation=1" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Subscribe_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white&labelColor=FF0000" alt="YouTube"/>
</a>

<a href="https://www.instagram.com/drabhishek.5460/" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white&labelColor=E4405F" alt="Instagram"/>
</a>

<a href="https://www.facebook.com/people/Dr-Abhishek/61580947955153/" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white&labelColor=1877F2" alt="Facebook"/>
</a>

<a href="https://x.com/DAbhishek5460" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_X-000000?style=for-the-badge&logo=x&logoColor=white&labelColor=000000" alt="X (Twitter)"/>
</a>

</div>
