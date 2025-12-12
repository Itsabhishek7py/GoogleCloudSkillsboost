
# Deploy and Evaluate Model Garden Models: Challenge Lab


[![Watch on YouTube](https://img.shields.io/badge/Watch_on_YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)]()


---
### 🤝 Support
If you found this helpful, please **Subscribe** to [Dr Abhishek](https://www.youtube.com/@drabhishek.5460/videos) for more Google Cloud solutions!


### ⚠️ Disclaimer
- **This script and guide are provided for  the educational purposes to help you understand the lab services and boost your career. Before using the script, please open and review it to familiarize yourself with Google Cloud services. Ensure that you follow 'Qwiklabs' terms of service and YouTube’s community guidelines. The goal is to enhance your learning experience, not to bypass it.**

### ©Credit
- **DM for credit or removal request (no copyright intended) ©All rights and credits for the original content belong to Google Cloud [Google Cloud Skill Boost website](https://www.cloudskillsboost.google/)** 🙏





### Task 2: Prepare a set of prompts for model evaluation
```bash
prompts = [prompt_template.format(project_request=req) for req in project_requests
```
### Task 3: Generate responses using Meta Llama 4

1.
accept_eula = True
 LLAMA_LOCATION = "us-east5"
 MAAS_ENDPOINT =f"{LLAMA_LOCATION}-aiplatform.googleapis.com"
 LLAMA_MODEL_ID = "meta/llama-4-scout-17b-16e-instruct-maas"
if not accept_eula:
 raise ValueError("Please accept the Llama 4 EULA before continuing.")
from openai import OpenAI
 openai_client = OpenAI(
 base_url=f"https://{MAAS_ENDPOINT}/v1beta1/projects/{PROJECT_ID}/locations/{LLAMA_L
 OCATION}/endpoints/openapi",
 api_key=credentials.token,
)

2.

llama_responses = []
for prompt in prompts:
 response = openai_client.chat.completions.create(
 model=LLAMA_MODEL_ID,
 messages=[{"role": "user", "content": prompt}],
 max_tokens=MAX_TOKENS,
 )
llama_response = response.choices[0].message.content
llama_responses.append(llama_response)



# Check your work
 print(f"Number of responses: {len(llama_responses)} (expected {len(prompts)})")
 print(f"All are strings: {all(isinstance(r, str) for r in llama_responses)}")
 # Preview a sample response
 print("\nSample Llama 4 response:\n", llama_responses[0][:500])


Task 4: Generate responses using Claude Sonnet 4


from anthropic import AnthropicVertex
 CLAUDE_MODEL ="claude-sonnet-4@20250514"
 CLAUDE_LOCATIONS = ["us-east5", "europe-west4", "GLOBAL"]
 LOCATION = CLAUDE_LOCATIONS[0] # or let the user select via dropdown
anthropic_client = AnthropicVertex(
 region=LOCATION,
 project_id="qwiklabs-asl-04-9ecb977d2e09" # Make sure PROJECT_ID is set
 )

2.
claude_responses = []
 for prompt in prompts:
 message = anthropic_client.messages.create(
 max_tokens=MAX_TOKENS,
 messages=[{"role": "user", "content": prompt}],
 model=CLAUDE_MODEL,
 )
claude_response = message.content
 claude_responses.append(claude_response)
 # Preview one response
 print("Example response:", claude_responses[0])

Task 5 :  Conduct a pairwise evaluation
 import pandas as pd
 def ensure_string(x):
 """Convert TextBlock or other objects to plain strings."""
 if hasattr(x, "text"): # handles TextBlock-like objects
 return x.text
 return str(x)
print("len(prompts):", len(prompts))
 print("len(llama_responses):", len(llama_responses))
 print("len(claude_responses):", len(claude_responses))
min_len = min(len(prompts), len(llama_responses), len(claude_responses))
 if len(set([len(prompts), len(llama_responses), len(claude_responses)])) != 1:
 print(f"
 Lists have different lengths — trimming to {min_len} entries.")
 prompts = prompts[:min_len]
 llama_responses = llama_responses[:min_len]
 claude_responses = claude_responses[:min_len]
prompts = [ensure_string(p) for p in prompts]
 llama_responses = [ensure_string(r) for r in llama_responses]
 claude_responses = [ensure_string(r) for r in claude_responses]
 # Create the evaluation dataset
 eval_dataset = pd.DataFrame({
 "prompt": prompts,
 "baseline_model_response": llama_responses,
 "response": claude_responses,
 })
 print("\n
 Cleaned dataset sample:")
 display(eval_dataset.head(1))


LOCATION = "us-central1" # usually allowed in labs
 PROJECT_ID = "qwiklabs-asl-04-9ecb977d2e09"
 from google.cloud import aiplatform
 aiplatform.init(project=PROJECT_ID, location=LOCATION)
 from vertexai.evaluation import EvalTask, MetricPromptTemplateExamples
 # Select the pairwise text quality metric
 selected_metric = MetricPromptTemplateExamples.Pairwise.TEXT_QUALITY
pairwise_eval_task = EvalTask(
 experiment="pairwise-text-quality-001",
 dataset=eval_dataset,
 baseline_model_response, response
 metrics=[selected_metric],
 )
 pairwise_eval_task

2.

# Display the summary metrics of the pairwise evaluation
 pairwise_result.summary_metrics
 # Display the metrics table with individual evaluation results
 pairwise_result.metrics_table











Task 7: Perform Cleanup


endpoints = aiplatform.Endpoint.list()
 if not endpoints:
 print("No endpoints found in this project/region.")
 else:
 for endpoint in endpoints:
 print(f"\nEndpoint: {endpoint.display_name} ({endpoint.resource_name})")
 deployed_models = endpoint.list_models()
 for dm in deployed_models:
 
 print(f" Undeploying model ID: {dm.id}")
endpoint.undeploy(deployed_model_id=dm.id, sync=True)
 print(f" Undeployed model ID: {dm.id}")
 print(" Deleting endpoint...")
 endpoint.delete(sync=True)
 print(f" Deleted endpoint: {endpoint.display_name}")
 print("\nDeleting models...")
 models = aiplatform.Model.list()

for model in models:
print(f" Deleting model: {model.display_name}")
model.delete(sync=True)
 print(" Deleted.")
log_message = "Deleted endpoints"
 logging.info(log_message)

```


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
