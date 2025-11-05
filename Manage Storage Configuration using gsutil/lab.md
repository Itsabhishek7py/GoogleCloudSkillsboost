### Manage Storage Configuration using gsutil




### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏



```bash

# Step 1: Get the sample code and set variables
git clone https://github.com/GoogleCloudPlatform/training-data-analyst
cd training-data-analyst/blogs
PROJECT_ID=$(gcloud config get-value project)
BUCKET=${PROJECT_ID}-bucket

# Step 2: Create a bucket
gsutil mb -c multi_regional gs://${BUCKET}

# Step 3: Upload objects to your bucket
gsutil -m cp -r endpointslambda gs://${BUCKET}

# Step 4: List objects in your bucket
gsutil ls gs://${BUCKET}/*

# Step 5: Sync changes with bucket
mv endpointslambda/Apache2_0License.txt endpointslambda/old.txt
rm endpointslambda/aeflex-endpoints/app.yaml
gsutil -m rsync -d -r endpointslambda gs://${BUCKET}/endpointslambda
gsutil ls gs://${BUCKET}/*

# Step 6: Make objects public
gsutil -m acl set -R -a public-read gs://${BUCKET}

# (To test public access, open this link in incognito mode)
# http://storage.googleapis.com/<your-bucket-name>/endpointslambda/old.txt

# Step 7: Copy with different storage class (Nearline)
gsutil cp -s nearline ghcn/ghcn_on_bq.ipynb gs://${BUCKET}

```




<div align="center">

<h3>🌟 Connect with fellow cloud enthusiasts, ask questions, and share your learning journey! 🌟</h3>

<div align="center">

<h3 style="font-family: 'Segoe UI', sans-serif; color: linear-gradient(90deg, #4F46E5, #E114E5);">🌟 Connect with Cloud Enthusiasts 🌟</h3>
<p style="font-family: 'Segoe UI', sans-serif;">Join the community, share knowledge, and grow together!</p>

<!-- Telegram Channel -->
<a href="https://t.me/+gBcgRTlZLyM4OGI1" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_Telegram_Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white&labelColor=2CA5E0&color=white&gradient=linear-gradient(90deg, #2CA5E0, #2488C8)" alt="Telegram Channel"/>
</a>

<!-- Telegram Group -->
<a href="https://t.me/+RujS6mqBFawzZDFl" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_Telegram_Group-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white&labelColor=2CA5E0&color=white&gradient=linear-gradient(90deg, #2CA5E0, #2488C8)" alt="Telegram Group"/>
</a>

<!-- YouTube -->
<a href="https://www.youtube.com/@drabhishek.5460?sub_confirmation=1" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Subscribe_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white&labelColor=FF0000&color=white&gradient=linear-gradient(90deg, #FF0000, #CC0000)" alt="YouTube"/>
</a>

<!-- Instagram -->
<a href="https://www.instagram.com/drabhishek.5460/" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white&labelColor=E4405F&color=white&gradient=linear-gradient(90deg, #E4405F, #C13584)" alt="Instagram"/>
</a>

<!-- X (Twitter) -->
<a href="https://x.com/DAbhishek5460" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_X-000000?style=for-the-badge&logo=x&logoColor=white&labelColor=000000&color=white&gradient=linear-gradient(90deg, #000000, #2D2D2D)" alt="X (Twitter)"/>
</a>

</div>
