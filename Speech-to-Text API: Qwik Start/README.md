

# 🟢 Speech-to-Text API: Qwik Start (GSP119)

https://www.skills.google/games/7174/labs/44446

```text
Task 1. Create an API key
Task 2. Create your Speech-to-Text API request
Task 3. Call the Speech-to-Text API
```

## 👉 Run the commands in Google Cloud shell

```bash
export ZONE=$(gcloud compute instances list linux-instance --format 'csv[no-heading](zone)')
gcloud compute ssh linux-instance --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet
```

Once connected to the VM, download and run the setup script:

```bash
curl -LO https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/refs/heads/main/Speech-to-Text%20API%3A%20Qwik%20Start/abhishekGSP119.sh
sudo chmod +x abhishekGSP119.sh
./abhishekGSP119.sh
```

<br><br><br>   

## Join the Community

[![Telegram](https://img.shields.io/badge/Join-Telegram_Group-blue?style=for-the-badge&logo=telegram)](https://t.me/+gBcgRTlZLyM4OGI1) - Connect with fellow cloud enthusiasts, ask questions, and share your learning journey.
