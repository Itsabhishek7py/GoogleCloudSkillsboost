# 🟢 App Engine: Qwik Start - Python (GSP067) 
https://www.skills.google/games/7171/labs/44405

```text
Task 1. Enable Google App Engine Admin API
Task 2. Download the Hello World app
Task 3. Test the application
Task 4. Make a change
Task 5. Deploy your app
Task 6. View your application
Task 7. Test your knowledge
```

```bash
gcloud services enable appengine.googleapis.com
cd ~
git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
cd ~/python-docs-samples/appengine/standard_python3/hello_world
sudo apt update
sudo apt install -y python3-venv
python3 -m venv myenv
source myenv/bin/activate
flask --app main run
```
Web Preview (web preview icon) > Preview on port 5000
```bash
sed -i 's/Hello World!/Hello, Cruel World!/g' main.py
flask --app main run
```
Web Preview (web preview icon) > Preview on port 5000
```bash
printf '1\n' | gcloud app create
gcloud app deploy --quiet
gcloud app browse
```

