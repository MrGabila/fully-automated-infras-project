# fully-automated-infrastructure-provision | DevOps
This Project uses Jenkins to deploy to fully automate the deployment of AWS infrstructure via Terraform. 

## Set up the Jenkins Server
- Create an **Amazon Linux 2 VM** instance and call it "Jenkins"
- Instance type: t2.large
- Security Group (Open): 8080, 9100 and 22 to 0.0.0.0/0
- Key pair: Select or create a new keypair
- **Attach Jenkins server with IAM role having "AdministratorAccess"**
- User data (user data): 
- Launch Instance
- After launching this Jenkins server, attach a tag as **Key=Application, value=jenkins**

### Configure Slack
1) ###### Slack
    - Create a channel within a Workspace on Slack
    - Store the workspace name (workspace.slack.com), and channel ID
    - Goto the Repo, and add channel name to the Jenkinsfile **#channelname** line 97
    - Intergate Jenkins to Slack
        - Right-click channel -> View channel details -> Integrations -> Add App -> select "Jenkins" -> Configuration (This will open a link on browser)
        - Select the channel -> Integrate (keep this page open and follow the instructions later to add Slack to Jenkins)

### Configure Jenkins 
2) #### Access Jenkins
    Copy your Jenkins Public IP Address and paste on the browser = ExternalIP:8080
    - Login to your Jenkins instance using your Shell (GitBash or your Mac Terminal)
    - Copy the Path from the Jenkins UI to get the Administrator Password
        - Run: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
        - Copy the password and login to Jenkins
    - Plugins: Choose Install Suggested Plugings 
    - Provide 
        - Username: **admin**
        - Password: **admin**
        - Name and Email can also be admin.
    - Continue and Start using Jenkins

3)  #### Plugin installations:
    - Click on "Manage Jenkins"
    - Click on "Plugins"
    - Click "Available Plugins"
    - Search and Install the following Plugings "Install Without Restart"        
        - **Slack Notification**

4)  #### Pipeline creation
    - Click on **New Item**
    - Enter an item name: **app-infra-pipeline** & select the category as **Pipeline**
    - Now scroll-down and in the Pipeline section --> Definition --> Select Pipeline script from SCM
    - SCM: **Git**
    - Repositories
        - Repository URL: FILL YOUR OWN REPO URL (that we created by importing in the first step)
        - Branch Specifier (blank for 'any'): */main
        - Script Path: Jenkinsfile
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
    - Access your repo on github -> **devops-fully-automated-infra**
    - Goto Settings --> Webhooks --> Click "Add webhook" 
    - Payload URL: **http://REPLACE-JENKINS-SERVER-PUBLIC-IP:8080/github-webhook/**             
    (Note: The IP should be public as GitHub is outside of the AWS VPC where Jenkins server is hosted)
    - Sroll and "Add Webhook"

7) #### Configure on the Jenkins side to pull based on the event
    - Access your jenkins server, pipeline **app-infra-pipeline**
    - Once pipeline is accessed --> Click on Configure --> In the General section --> **Select GitHub project checkbox** and fill your repo URL of the project devops-fully-automated.
    - Scroll down --> In the Build Triggers section -->  Select **GitHub hook trigger for GITScm polling checkbox**
    - Save


### Codebase setup
8) #### Jenkinsfile
    - On line 13, add the link to your githun reposirory
    - Make sure you added the slack channel to line 97

9) #### For checking the checkov scan uncomment lines 74-78 in ec2/ec2.tf file
    - Go back to your local, open your "devops-fully-automated" project on VSCODE
    - Open "ec2.tf file" uncomment lines   
    - Save the changes in both files
    - Finally push changes to repo
        `git add .`
        `git commit -m "relevant commit message"`
        `git push`

9) #### Skipping all the checks on the Jenkins file comment the checkov scan lines accordingly with # (sure to shell)

## Finally observe the whole flow and understand the integrations :) 

### Destroy the infra
10) #### Once the flow is observed, lets destroy the infra with same code
    - Go back to your local, open your "devops-fully-automated" project on VSCODE
    - Open "Jenkinsfile" comment lines 59, 76-82 & uncomment lines 61, 84-90
    - Save the changes in both files
    - Finally push changes to repo
        `git add .`
        `git commit -m "relevant commit message"`
        `git push`

11) #### Terminate Jenkins EC2 instance
