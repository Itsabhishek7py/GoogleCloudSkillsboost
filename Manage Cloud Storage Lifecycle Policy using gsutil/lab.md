## Manage Cloud Storage Lifecycle Policy using gsutil




### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏


### Run the following Commands in CloudShell

```
# I Know you will Steal it
PROJECT_ID=$(gcloud config get-value project)

cat <<EOF > lifecycle.json
{
  "rule": [
    {
      "action": {
        "type": "SetStorageClass",
        "storageClass": "NEARLINE"
      },
      "condition": {
        "daysSinceNoncurrentTime": 30,
        "matchesPrefix": ["projects/active/"]
      }
    },
    {
      "action": {
        "type": "SetStorageClass",
        "storageClass": "NEARLINE"
      },
      "condition": {
        "daysSinceNoncurrentTime": 90,
        "matchesPrefix": ["archive/"]
      }
    },
    {
      "action": {
        "type": "SetStorageClass",
        "storageClass": "COLDLINE"
      },
      "condition": {
        "daysSinceNoncurrentTime": 180,
        "matchesPrefix": ["archive/"]
      }
    },
    {
      "action": {
        "type": "Delete"
      },
      "condition": {
        "age": 7,
        "matchesPrefix": ["processing/temp_logs/"]
      }
    }
  ]
}
EOF


gsutil lifecycle set lifecycle.json gs://$PROJECT_ID-bucket
```
### Congratulations !!!!

Connect with fellow cloud enthusiasts, ask questions, and share your learning journey.  

[![Telegram](https://img.shields.io/badge/Telegram_Group-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/+gBcgRTlZLyM4OGI1)  
[![YouTube](https://img.shields.io/badge/Subscribe-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@drabhishek.5460?sub_confirmation=1)  
[![Instagram](https://img.shields.io/badge/Follow-%23E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/drabhishek.5460/) 
