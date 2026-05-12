# 🟢 **Google Kubernetes Engine Pipeline using Cloud Build (GSP1077)**  

https://www.skills.google/games/7173/labs/44433      

```text
Task 1. Initialize your lab
Task 2. Create the Git repositories in GitHub repositories
Task 3. Create a container image with Cloud Build
Task 4. Create the Continuous Integration (CI) pipeline
Task 5. Accessing GitHub from a build via SSH keys
Task 6. Create the test environment and CD pipeline
Task 7. Review Cloud Build pipeline
Task 8. Test the complete pipeline
Task 9. Test the rollback
```

<br>  

## 👉 **Run the following Commands in CloudShell**

```bash
rm -f nov05_gsp1077.sh 
curl -LO https://raw.githubusercontent.com/nov05/gcp-skills-boost/refs/heads/main/Google%20Kubernetes%20Engine%20Pipeline%20using%20Cloud%20Build/nov05_gsp1077.sh
sudo chmod +x nov05_gsp1077.sh
./nov05_gsp1077.sh
```

⚠️ Remember to delete the GitHub repositories that were created for this lab after completing it. E.g.:      
  * https://github.com/nov05/hello-cloudbuild-app    
  * https://github.com/nov05/hello-cloudbuild-env     

<br><br><br>      

**Task 4.7**: Authenticate to your source repository with your username and password. This step has to be done manually.      
<img src="https://raw.githubusercontent.com/nov05/pictures/refs/heads/master/gcp-skills-boost%20/Google%20Kubernetes%20Engine%20Pipeline%20using%20Cloud%20Build/2026-05-11%2000_16_29-Settings.jpg" width=800>  

**Task 7.2**: Click the hello-cloudbuild-app trigger to follow its execution and examine its logs. The last step of this pipeline pushes the new manifest to the hello-cloudbuild-env repository, which triggers the continuous delivery pipeline.     
<img src="https://raw.githubusercontent.com/nov05/pictures/refs/heads/master/gcp-skills-boost%20/Google%20Kubernetes%20Engine%20Pipeline%20using%20Cloud%20Build/2026-05-10%2019_43_08-Settings.jpg" width=800>  

**Task 9.2**: Click the View all link under Build History for the hello-cloudbuild-env repository.
<img src="https://raw.githubusercontent.com/nov05/pictures/refs/heads/master/gcp-skills-boost%20/Google%20Kubernetes%20Engine%20Pipeline%20using%20Cloud%20Build/2026-05-10%2019_41_26-Settings.jpg" width=800>   
