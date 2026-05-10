# 🟢 Implement DevOps Workflows in Google Cloud (GSP330)

https://www.skills.google/games/7173/labs/44434   
https://www.skills.google/course_templates/716/labs/598755   

### Challenge Lab  

[<img src="https://img.shields.io/badge/Open_Lab-Cloud_Skills_Boost-4285F4?style=for-the-badge&logo=google&logoColor=white&labelColor=34A853" alt="Open Lab Badge">](https://www.cloudskillsboost.google/focuses/13287?parent=catalog)

### ⚠️ Disclaimer
- This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.

### ©Credit
- DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/) 🙏

### 📋 Prerequisites   

* If you do not already have a `GitHub` account, you will need to create a [GitHub account](https://github.com/signup)  

<br>  

---

👉 **IMPORTANT:**   
  After the lab, make sure to manually delete the GitHub repository named `sample-app` that was created by the script.

<div style="padding: 15px; margin: 10px 0;">
<p><strong>👉 Run in Cloud Shell:</strong></p>  
 
```bash
rm -f abhishek.sh
curl -LO https://raw.githubusercontent.com/nov05/gcp-skills-boost/refs/heads/main/Implement%20DevOps%20Workflows%20in%20Google%20Cloud%3A%20Challenge%20Lab/abhishek.sh
sudo chmod +x abhishek.sh
./abhishek.sh
```

</div>

👉 **Cloud Build Trigger Configuration**  

* Production Deployment Trigger:
  
  Name:
  ```
  sample-app-prod-deploy
  ```
  Branch Pattern:
  ```
  ^master$
  ```
  Build Configuration File:
  ```
  cloudbuild.yaml
  ```

* Development Deployment Trigger:
  
  Name:
  ```
  sample-app-dev-deploy
  ```
  Branch Pattern:
  ```
  ^dev$
  ```
  Build Configuration File:
  ```
  cloudbuild-dev.yaml
  ```

<br>  

---

### Congratulations !!!! 

Connect with fellow cloud enthusiasts, ask questions, and share your learning journey.    

[![Telegram](https://img.shields.io/badge/Telegram_Group-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white)](https://t.me/+gBcgRTlZLyM4OGI1)  
[![YouTube](https://img.shields.io/badge/Subscribe-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@drabhishek.5460?sub_confirmation=1)  
[![Instagram](https://img.shields.io/badge/Follow-%23E4405F?style=for-the-badge&logo=instagram&logoColor=white)](https://www.instagram.com/drabhishek.5460/) 
