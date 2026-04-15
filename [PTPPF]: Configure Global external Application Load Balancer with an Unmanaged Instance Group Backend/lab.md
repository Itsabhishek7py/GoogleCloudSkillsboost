### [PTPPF]: Configure Global external Application Load Balancer with an Unmanaged Instance Group Backend
[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://youtu.be/C3WIvvFjivs)

> **Note:** Establish Hybrid Network Connectivity with NCC

---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Dr Abhishek](https://www.youtube.com/@drabhishek.5460/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏



```bash

# ---------- CONFIG ----------
ZONE=$(gcloud config get-value compute/zone)
GROUP_NAME="webserver-instance-group"
BACKEND_NAME="cepf-webserver-backend"
IP_NAME="cepf-static-ip"
CERT_NAME="webserver-cert"

# ---------- TASK 1: STATIC IP ----------
gcloud compute addresses create $IP_NAME \
    --ip-version=IPV4 \
    --global

# Get IP
IP=$(gcloud compute addresses describe $IP_NAME \
    --global \
    --format="value(address)")

echo "Static IP: $IP"

# Convert IP → domain format
DOMAIN=$(echo $IP | sed 's/\./-/g').qlencrypt.com
echo "Domain: $DOMAIN"

# Create SSL certificate
gcloud compute ssl-certificates create $CERT_NAME \
    --description="WebserverCertificate" \
    --domains=$DOMAIN \
    --global

# ---------- TASK 2: INSTANCE GROUP ----------
gcloud compute instance-groups unmanaged create $GROUP_NAME

gcloud compute instance-groups unmanaged add-instances $GROUP_NAME \
    --instances=webserver1,webserver2 \
    --zone=$ZONE

# ---------- TASK 3: LOAD BALANCER ----------

# Health check
gcloud compute health-checks create http http-basic-check --port 80

# Backend service
gcloud compute backend-services create $BACKEND_NAME \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=http-basic-check \
    --global

# Add backend
gcloud compute backend-services add-backend $BACKEND_NAME \
    --instance-group=$GROUP_NAME \
    --instance-group-zone=$ZONE \
    --global

# URL map
gcloud compute url-maps create web-map \
    --default-service $BACKEND_NAME

# HTTPS proxy
gcloud compute target-https-proxies create https-proxy \
    --ssl-certificates=$CERT_NAME \
    --url-map=web-map

# HTTPS forwarding rule
gcloud compute forwarding-rules create https-rule \
    --address=$IP_NAME \
    --global \
    --target-https-proxy=https-proxy \
    --ports=443

# ---------- HTTP → HTTPS REDIRECT ----------

gcloud compute url-maps create http-redirect-map \
    --default-url-redirect="https://$DOMAIN" \
    --global

gcloud compute target-http-proxies create http-proxy \
    --url-map=http-redirect-map

gcloud compute forwarding-rules create http-rule \
    --address=$IP_NAME \
    --global \
    --target-http-proxy=http-proxy \
    --ports=80

# ---------- DONE ----------
echo "-----------------------------------"
echo "Load Balancer IP: $IP"
echo "Open: http://$IP (will redirect to HTTPS)"
echo "Or: https://$DOMAIN"
echo "-----------------------------------"
```




<div align="center">

<h3 style="font-family: 'Segoe UI', sans-serif; color: linear-gradient(90deg, #4F46E5, #E114E5);">🌟 Connect with Cloud Enthusiasts 🌟</h3>
<p style="font-family: 'Segoe UI', sans-serif;">Join the community, share knowledge, and grow together!</p>

<a href="https://t.me/+gBcgRTlZLyM4OGI1" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_Telegram_Channel-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white&labelColor=2CA5E0" alt="Telegram Channel"/>
</a>

<a href="https://t.me/+RujS6mqBFawzZDFl" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_Telegram_Group-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white&labelColor=2CA5E0" alt="Telegram Group"/>
</a>

<a href="https://www.whatsapp.com/channel/0029VbCB6SpLo4hdpzFoD73f" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Join_WhatsApp_Channel-25D366?style=for-the-badge&logo=whatsapp&logoColor=white&labelColor=25D366" alt="WhatsApp Channel"/>
</a>

<a href="https://www.youtube.com/@drabhishek.5460?sub_confirmation=1" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Subscribe_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white&labelColor=FF0000" alt="YouTube"/>
</a>

<a href="https://www.instagram.com/drabhishek.5460/" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white&labelColor=E4405F" alt="Instagram"/>
</a>

<a href="https://www.facebook.com/people/Dr-Abhishek/61580947955153/" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_Facebook-1877F2?style=for-the-badge&logo=facebook&logoColor=white&labelColor=1877F2" alt="Facebook"/>
</a>

<a href="https://x.com/DAbhishek5460" target="_blank" style="text-decoration: none;">
  <img src="https://img.shields.io/badge/-Follow_X-000000?style=for-the-badge&logo=x&logoColor=white&labelColor=000000" alt="X (Twitter)"/>
</a>

</div>
