👉 For development  

```bash
rm -f nov05_gsp1077.sh 
curl -LO https://raw.githubusercontent.com/nov05/gcp-skills-boost/refs/heads/dev/Google%20Kubernetes%20Engine%20Pipeline%20using%20Cloud%20Build/nov05_gsp1077.sh
sudo chmod +x nov05_gsp1077.sh
./nov05_gsp1077.sh
```

<br><br>  

## 👉 Logs  

* 2026-05-10 Changed the script. It now waits for the user to connect the GitHub repositories manually in Cloud Build before creating two triggers.
  
  ✅ [Test result](https://gist.github.com/nov05/6be835acbcf1af1918fa225af739bcdb?permalink_comment_id=6143190#gistcomment-6143190): Passed all checks.

  ✅ [Test result](https://gist.github.com/nov05/6be835acbcf1af1918fa225af739bcdb?permalink_comment_id=6143315#gistcomment-6143315): Added commands to retry build of the last but one successful build of a trigger. [code snippet](https://gist.github.com/nov05/6be835acbcf1af1918fa225af739bcdb?permalink_comment_id=6143224#gistcomment-6143224)  

* 2026-05-09 [Test result](https://gist.github.com/nov05/6be835acbcf1af1918fa225af739bcdb) for [Commit dd53be2](https://github.com/nov05/gcp-skills-boost/commit/dd53be229d8746520b842107ada7fd1b0355a6af)
  
  ⚠️ Didn't pass the Task 4 check.   
  Task 4. Create the Continuous Integration (CI) pipeline   
  Create the Continuous Integration (CI) Pipeline    
  Please create the Cloud Build trigger as per the given configuration.   

  ⚠️ Didn't pass the Task 6 check.    
  Task 6. Create the test environment and CD pipeline   
  Create the Test Environment and CD Pipeline   
  Please create the trigger for the continuous delivery pipeline as per given configuration.   

  🔹 Solution: Add commands to create CI and CD triggers.   
