# 🟢 Implement DevOps Workflows in Google Cloud (GSP330)

https://www.skills.google/games/7173/labs/44434   
https://www.skills.google/course_templates/716/labs/598755   


## 👉 Run in Cloud Shell
 
```bash
rm -f nov05_GSP330.sh && rm -rf sample-app
curl -LO https://github.com/nov05/gcp-skills-boost/blob/main/GSP330%20Implement%20DevOps%20Workflows%20in%20Google%20Cloud%20-%20Challenge%20Lab/nov05_GSP330.sh
sudo chmod +x nov05_GSP330.sh
./nov05_GSP330.sh
```

⚠️ After the lab, make sure to manually delete the GitHub repository named `sample-app` that was created by the script.


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