# fully-automated-infras-project | DevOps
This Project uses Jenkins to fully automate the deployment of AWS infrastructure via Terraform scripts. 
It also intergrates Slack to receive notifications from the pipeline.

## Set up the Jenkins Server
- Create an **Amazon Linux 2 VM** instance and name it "Jenkins"
- tags:  **Key=Application, value=jenkins**
- Instance type: t2.large
- Enable public IP
- Security Group (Open): 8080, 9100 and 22 to 0.0.0.0/0
- Key pair: Select or create a new keypair
- Attach an **"AdministratorAccess"** IAM role for EC2 to the Jenkins server
- Attach User data: `fully-automated-infras-project\scripts\AmazonLinux2-cicd-installations.sh`
- Launch Instance

### Configure Slack
1) ###### Slack
    - Create a channel within a Workspace on Slack
    - Store the workspace name (workspace.slack.com), and channel ID
    - Goto the Repo, and add channel name to the Jenkinsfile: **#channelname** line 97
    - Intergate Jenkins to Slack
        - Right-click channel -> View channel details -> Integrations -> Add App -> select "Jenkins" -> Configuration (This will open a link on browser)
        - Select the channel -> Integrate (keep this page open and follow the instructions later to add Slack to Jenkins)

### Configure Jenkins 
2) #### Access Jenkins
    - Copy your Jenkins Public IP Address and paste on the browser = ExternalIP:8080
    - Login via SSH into your Jenkins instance 
    - Copy the Path from the Jenkins UI to get the Administrator Password
        - Run: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
        - Copy the password and login to Jenkins
    - Plugins: Choose "Install Suggested Plugin" 
    - Provide 
        - Username: **admin**
        - Password: **admin**
        - Name and Email can also be admin.
    - Continue and Start using Jenkins

3)  #### Plugin installations:
    - Click on "Manage Jenkins"
    - Click on "Plugins"
    - Click "Available Plugins"
    - Search and Install the `Slack Notification` plugin

4)  #### Pipeline creation
    - Click on **New Item**
    - Enter an item name: `infrastructure-pipeline` & select the category as `"Pipeline"` --> Next
    - Scroll-down and in the Pipeline section --> Definition --> Select `"Pipeline script from SCM"`
    - SCM: `"Git"`
    - Repositories
        - Repository URL: FILL YOUR OWN infrastructure REPO URL (that we created by importing in the first step)
        - Branch Specifier (blank for 'any'): */main
        - Script Path: `Jenkinsfile`
    - Save

5)  #### Slack Credentials set up:
    - Click on Manage Jenkins --> System
    - Go to section Slack
    - Workspace: (copy from slack page -Team subdomain)
    - Credentials: Click on Add button to add new credentials
        - Kind: Secret text            
        - Secret: (copy from slack page -Token Credential ID)
        - ID: slack-token
        - Description: slack-token
        - Click on Create        


### GitHub webhook
6) #### Add jenkins webhook to github
    - Access your repo on github -> **fully-automated-infras-project**
    - Goto Settings --> Webhooks --> Click "Add webhook" 
    - Payload URL: **http://REPLACE-JENKINS-SERVER-PUBLIC-IP:8080/github-webhook/**             
    (Note: The IP should be public as GitHub is outside of the AWS VPC where Jenkins server is hosted)
    - Scroll and "Add Webhook"

7) #### Configure on the Jenkins side to pull based on the event
    - Access your jenkins server pipeline **infrastructure-pipeline**
    - Once pipeline is accessed --> Click on Configure --> In the General section --> Select `GitHub project checkbox` and fill in the URL of your repository.
    - Scroll down --> In the Build Triggers section -->  Select `GitHub hook trigger for GITScm polling checkbox`
    - Save


### Codebase setup
8) #### Jenkinsfile
    - On line 13, add the URL to your github repository
    - On line 97, add the name of your slack channel: `#channel-name`

9) #### For the checkov scanner 
    - uncomment lines 79-83 in ec2/ec2.tf file
    - uncomment lines 50, 60 or 61 in the Jenkinsfile
    (Can skip all the checks by commenting out the checkov scan lines accordingly) 
    - Save the changes in both files
    - Finally push changes to repo
```bash
git add .
git commit -m "relevant commit message"
git push
```

### Finally observe the whole flow and See the Results :) 
10) #### Apply Infra
    - On the Jenkins Web Server, observe the pipeline progress
    - select "Proceed" with the Manual Approval to create the instances
    - Check out the e-commerce app by browsing the `public-IP-of-webservers:80`

11) #### Destroy Infra
    - On the Jenkins Web Server, select "proceed" with the 2nd Manual Approval stage
    - The instances will be terminated

12) #### Terminate Jenkins Web Server
