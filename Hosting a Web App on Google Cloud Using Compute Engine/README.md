# 🟢 Hosting a Web App on Google Cloud Using Compute Engine (GSP662)

https://www.skills.google/games/7171/labs/44409

```text
Task 1. Enable the Compute Engine API
Task 2. Create a Cloud Storage bucket
Task 3. Clone a source repository
Task 4. Create the Compute Engine instances
Task 5. Create managed instance groups
Task 6. Create load balancers
Task 7. Scale Compute Engine
Task 8. Update the website
```

## 👉 Run the following Commands in Cloud Shell

```bash
gcloud auth list
export ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
rm -f abhishek1.sh
curl -LO https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/refs/heads/main/Hosting%20a%20Web%20App%20on%20Google%20Cloud%20Using%20Compute%20Engine/abhishek1.sh
sudo chmod +x abhishek1.sh
./abhishek1.sh
```

⚠️ IMPORTANT: Hit the `Check my progress` button at the end of Task 6

Now continue to run the commands in cloud shell.  

```bash
gcloud auth list
export ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
rm -f abhishek2.sh
curl -LO https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/refs/heads/main/Hosting%20a%20Web%20App%20on%20Google%20Cloud%20Using%20Compute%20Engine/abhishek2.sh
sudo chmod +x abhishek2.sh
./abhishek2.sh
```
