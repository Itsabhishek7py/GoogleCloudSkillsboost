## 🟢 Migrating a Monolithic Website to Microservices on Google Kubernetes Engine (GSP699)

https://www.skills.google/games/7171/labs/44410

```text
Task 1. Clone the source repository
Task 2. Create a GKE cluster
Task 3. Deploy the existing monolith
Task 4. Migrate orders to a microservice
Task 5. Migrate Products to microservice
Task 6. Migrate Frontend to microservice
```

## 👉 Run the following Commands in CloudShell


```bash
gcloud auth list
export ZONE=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-zone])")
rm -f abhishek.sh
curl -LO https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/refs/heads/main/Migrating%20a%20Monolithic%20Website%20to%20Microservices%20on%20Google%20Kubernetes%20Engine/abhishek.sh
sudo chmod +x abhishek.sh
./abhishek.sh
```
