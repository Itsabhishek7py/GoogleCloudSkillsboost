# Configuring IAM Permissions with gCloud - AWS (GSP1126)

```
export ZONE=$(gcloud compute instances list --filter="name=debian-clean" --format="value(zone)")
gcloud compute ssh debian-clean --zone=$ZONE --quiet
```
```
curl -LO https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/refs/heads/main/Configuring%20IAM%20Permissions%20with%20gCloud%20AWS%20/abhishek.sh
sudo chmod +x abhishek.sh
./abhishek.sh
```
