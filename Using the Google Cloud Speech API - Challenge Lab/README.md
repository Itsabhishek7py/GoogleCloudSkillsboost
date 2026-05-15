# 🟢 Using the Google Cloud Speech API: Challenge Lab

### In this lab, You need to:

- Create an API key.
- Create and call your API request.
- Update the API request for transcription in different languages.

### Run the following Commands in CloudShell (wait till vm is logged into the cloud shell then run 2nd command)

```bash
export ZONE=$(gcloud compute instances list lab-vm --format 'csv[no-heading](zone)')
gcloud compute ssh lab-vm --project=$DEVSHELL_PROJECT_ID --zone=$ZONE --quiet
```

```bash
curl -LO https://raw.githubusercontent.com/Itsabhishek7py/GoogleCloudSkillsboost/refs/heads/main/Using%20the%20Google%20Cloud%20Speech%20API%3A%20Challenge%20Lab/abhishek.sh
sudo chmod +x abhishek.sh
./abhishek.sh
```
