## Deploy a RAG application with vector search in Firestore: Challenge Lab


### ⚠️ **Disclaimer**  

<div style="background-color: #fff3cd; padding: 15px; border-left: 5px solid #ffc107; border-radius: 4px; margin: 20px 0;">

📌 **Important Notice**  

This educational material is provided **for learning purposes only** to help you:  
- Understand Google Cloud lab services  
- Enhance your technical skills  
- Advance your cloud computing career  

**Before using any scripts or guides:**  
1. Always review the content thoroughly  
2. Complete labs through official channels first  
3. Comply with [Qwiklabs Terms of Service](https://www.qwiklabs.com/terms_of_service)  
4. Adhere to [YouTube Community Guidelines](https://www.youtube.com/howyoutubeworks/policies/community-guidelines/)  

❌ **Not intended** to bypass legitimate learning processes  
✅ **Meant to supplement** your educational journey  

</div>



### © **Credit & Attribution**  

<div style="background-color: #e7f5ff; padding: 15px; border-left: 5px solid #4dabf7; border-radius: 4px; margin: 20px 0;">

**Original Content Rights:**  
All rights and credit for the original lab content belong to:  
🔹 [Google Cloud Skill Boost](https://www.cloudskillsboost.google/)  
🔹 Google LLC  

**Copyright Notice:**  
- DM for credit/removal requests  
- No copyright infringement intended  
- Educational fair use purpose only  

🙏 **Acknowledgement:**  
We gratefully acknowledge Google's learning resources that make cloud education accessible  

</div>

```

gcloud firestore indexes composite create \
  --project=qwiklabs-gcp-01-26704bc814e4 \
  --collection-group=food-safety \
  --query-scope=COLLECTION \
  --field-config=vector-config='{"dimension":"768","flat": "{}"}',field-path=embedding
```
```
def search_vector_database(query: str):
    query_embedding = embedding_model.embed_query(query)
    query_vector = Vector(query_embedding)
    docs = collection.find_nearest(
        "embedding",
        query_vector=query_vector,
        distance_measure=DistanceMeasure.DOT_PRODUCT,
        limit=5
    ).get()
    
    pieces = []
    for doc in docs:
        data = doc.to_dict()
        if "content" in data:
            pieces.append(data["content"])
    
    context = "\n".join(pieces)
    return context

# Test the function
result = search_vector_database("How should I store food?")
print(result)
```

```
- Mainfile
```
```
import os
import logging
import google.cloud.logging
from flask import Flask, render_template, request

from google.cloud import firestore
from google.cloud.firestore_v1.vector import Vector
from google.cloud.firestore_v1.base_vector_query import DistanceMeasure

import vertexai
from vertexai.language_models import TextEmbeddingInput, TextEmbeddingModel
from vertexai.generative_models import (
    GenerativeModel,
    SafetySetting,
    HarmCategory,
    HarmBlockThreshold,
)

# -------------------------------------------------------------------
# Logging
# -------------------------------------------------------------------
logging_client = google.cloud.logging.Client()
logging_client.setup_logging()
logging.basicConfig(level=logging.INFO)

# -------------------------------------------------------------------
# App config
# -------------------------------------------------------------------
BOTNAME = "FreshBot"
SUBTITLE = "Your Friendly Restaurant Safety Expert"

app = Flask(__name__)

# -------------------------------------------------------------------
# Firestore client
# -------------------------------------------------------------------
db = firestore.Client()

# ✅ Food safety vector collection
collection = db.collection("food-safety")

# -------------------------------------------------------------------
# Vertex AI init
# -------------------------------------------------------------------
vertexai.init()


# ✅ Embedding model (REQUIRED by lab)
embedding_model = TextEmbeddingModel.from_pretrained("text-embedding-005")

# ✅ Gemini model with correct safety config
gen_model = GenerativeModel(
    "gemini-2.0-flash",
    generation_config={"temperature": 0},
    safety_settings=[
        SafetySetting(
            category=HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
            threshold=HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE,
        )
    ],
)

# -------------------------------------------------------------------
# Vector search
# -------------------------------------------------------------------
def search_vector_database(question: str) -> str:
    # 1️⃣ Generate embedding for the query
    embedding = embedding_model.get_embeddings(
        [TextEmbeddingInput(question, "RETRIEVAL_QUERY")]
    )[0].values

    query_vector = Vector(embedding)

    # 2️⃣ Vector similarity search (CORRECT METHOD)
    docs = (
        collection.find_nearest(
            vector_field="embedding",  # 🔴 change if your field name differs
            query_vector=query_vector,
            distance_measure=DistanceMeasure.COSINE,
            limit=5,
        )
        .get()
    )

    # 3️⃣ Build context
    context = ""
    for doc in docs:
        data = doc.to_dict()
        context += data.get("content", "") + "\n"

    # REQUIRED logging
    logging.info(
        context,
        extra={"labels": {"service": "cymbal-service", "component": "context"}},
    )

    return context


# -------------------------------------------------------------------
# Ask Gemini using vector context
# -------------------------------------------------------------------
def ask_gemini(question: str) -> str:
    context = search_vector_database(question)

    prompt = f"""
You are a food safety expert.
Answer the question ONLY using the context provided.

CONTEXT:
{context}

QUESTION:
{question}
"""

    response = gen_model.generate_content(prompt)
    return response.text


# -------------------------------------------------------------------
# Flask routes
# -------------------------------------------------------------------
@app.route("/", methods=["GET", "POST"])
def main():
    if request.method == "GET":
        question = ""
        answer = "Hi, I'm FreshBot, what can I do for you?"
    else:
        question = request.form["input"]



        logging.info(
            question,
            extra={"labels": {"service": "cymbal-service", "component": "question"}},
        )

        answer = ask_gemini(question)

    logging.info(
        answer,
        extra={"labels": {"service": "cymbal-service", "component": "answer"}},
    )

    config = {
        "title": BOTNAME,
        "subtitle": SUBTITLE,
        "botname": BOTNAME,
        "message": answer,
        "input": question,
    }

    return render_template("index.html", config=config)


# -------------------------------------------------------------------
# App entrypoint
# -------------------------------------------------------------------
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
```
```
gcloud storage cp -r gs://partner-genai-bucket/genai069/gen-ai-assessment .
cd gen-ai-assessment
python3 -m pip install -r requirements.txt
```
```
python3 main.py
```
```
# A. Build Docker Image
docker build -t cymbal-docker-image -f Dockerfile .

# B. Tag and Push Image
docker tag cymbal-docker-image us-central1-docker.pkg.dev/qwiklabs-gcp-01-26704bc814e4/cymbal-repo/cymbal-docker-image
gcloud auth configure-docker us-central1-docker.pkg.dev
docker push us-central1-docker.pkg.dev/qwiklabs-gcp-01-26704bc814e4/cymbal-repo/cymbal-docker-image

# C. Deploy to Cloud Run
gcloud run deploy cymbal-freshbot-service \
  --image=us-central1-docker.pkg.dev/qwiklabs-gcp-01-26704bc814e4/cymbal-repo/cymbal-docker-image \
  --region=us-central1 \
  --allow-unauthenticated
```

```
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
