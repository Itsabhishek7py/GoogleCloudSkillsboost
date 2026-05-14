### Pub/Sub: Qwik Start - Python





### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏


### Run the following Commands in CloudShell

```
sudo apt-get install -y virtualenv
python3 -m venv venv
source venv/bin/activate
pip install --upgrade google-cloud-pubsub
git clone https://github.com/googleapis/python-pubsub.git
cd python-pubsub/samples/snippets
echo $GOOGLE_CLOUD_PROJECT
cat publisher.py
python publisher.py -h
python publisher.py $GOOGLE_CLOUD_PROJECT create MyTopic
python publisher.py $GOOGLE_CLOUD_PROJECT list
python subscriber.py $GOOGLE_CLOUD_PROJECT create MyTopic MySub
python subscriber.py $GOOGLE_CLOUD_PROJECT list-in-project
```



<div align="center">
  
# Congratulations !!!!

Connect with fellow cloud enthusiasts, ask questions, and share your learning journey.

[![Join Telegram Group](https://img.shields.io/badge/-Join%20Telegram%20Group-2CA5E0?style=for-the-badge&logo=telegram&logoColor=white&labelColor=2CA5E0)](https://t.me/+gBcgRTlZLyM4OGI1)  
[![Subscribe on YouTube](https://img.shields.io/badge/-Subscribe%20on%20YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white&labelColor=FF0000)](https://www.youtube.com/@drabhishek.5460?sub_confirmation=1)  
[![Follow on Instagram](https://img.shields.io/badge/-Follow%20on%20Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white&labelColor=E4405F)](https://www.instagram.com/drabhishek.5460/)

*Let's grow together in the cloud computing world!*

</div>
