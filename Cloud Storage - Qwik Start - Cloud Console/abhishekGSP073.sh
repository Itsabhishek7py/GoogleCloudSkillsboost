
export PROJECT_ID=$(gcloud config get-value project)

gsutil mb -l $REGION -c Standard gs://$PROJECT_ID

curl -O https://github.com/Itsabhishek7py/GoogleCloudSkillsboost/blob/f31d8eff4b56e6b72b256884cf4fc62d17fc58fa/Cloud%20Storage%3A%20Qwik%20Start%20-%20Cloud%20Console/kitten.png

gsutil cp kitten.png gs://$PROJECT_ID/kitten.png

gsutil iam ch allUsers:objectViewer gs://$PROJECT_ID

