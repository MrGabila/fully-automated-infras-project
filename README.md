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


### Configure Jenkins and Set up the automated process
1) #### Access Jenkins
    Copy your Jenkins Public IP Address and paste on the browser = ExternalIP:8080
    - Login to your Jenkins instance using your Shell (GitBash or your Mac Terminal)
    - Copy the Path from the Jenkins UI to get the Administrator Password
        - Run: `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
        - Copy the password and login to Jenkins
    - Plugins: Choose Install Suggested Plugings 
    - Provide 
        - Username: **admin**
        - Password: **admin**
        - Name and Email can also be admin. You can use `admin` all, as its a poc.
    - Continue and Start using Jenkins

2)  #### Plugin installations:
    - Click on "Manage Jenkins"
    - Click on "Plugins"
    - Click "Available Plugins"
    - Search and Install the following Plugings "Install Without Restart"        
        - **Slack Notification**



3)  #### Pipeline creation
    - Click on **New Item**
    - Enter an item name: **app-infra-pipeline** & select the category as **Pipeline**
    - Now scroll-down and in the Pipeline section --> Definition --> Select Pipeline script from SCM
    - SCM: **Git**
    - Repositories
        - Repository URL: FILL YOUR OWN REPO URL (that we created by importing in the first step)
        - Branch Specifier (blank for 'any'): */main
        - Script Path: Jenkinsfile
    - Save

4) ###### Slack 
    - Create a channel within a Workspace on Slack
    - Store the workspace name (workspace.slack.com), and channel ID
    - Intergate Jenkins
        - View channel details -> Integrations -> Add App -> select "Jenkins" -> Configuration (This will open a link on browser)
        - Select the channel -> integrate (keep this page open and follow the instructions to add Slack to Jenkins)

5)  #### Credentials setup(Slack):
    1)  #### Configure slack credentials for the pipeline to post alerts on slack channel:
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

1) #### Add jenkins webhook to github
    - Access your repo on github -> **devops-fully-automated-infra**
    - Goto Settings --> Webhooks --> Click on Add webhook 
    - Payload URL: **http://REPLACE-JENKINS-SERVER-PUBLIC-IP:8080/github-webhook/**             (Note: The IP should be public as GitHub is outside of the AWS VPC where Jenkins server is hosted)
    - Click on Add webhook

2) #### Configure on the Jenkins side to pull based on the event
    - Access your jenkins server, pipeline **app-infra-pipeline**
    - Once pipeline is accessed --> Click on Configure --> In the General section --> **Select GitHub project checkbox** and fill your repo URL of the project devops-fully-automated.
    - Scroll down --> In the Build Triggers section -->  Select **GitHub hook trigger for GITScm polling checkbox**
    - Save


### Codebase setup

1) #### For checking the checkov scan uncomment lines 74-78 in ec2/ec2.tf file
    - Go back to your local, open your "devops-fully-automated" project on VSCODE
    - Open "ec2.tf file" uncomment lines   
    - Save the changes in both files
    - Finally push changes to repo
        `git add .`
        `git commit -m "relevant commit message"`
        `git push`

2) #### Skipping all the checks on the Jenkins file comment the checkov scan lines accordingly with # (sure to shell)

## Finally observe the whole flow and understand the integrations :) 

### Destroy the infra

1) #### Once the flow is observed, lets destroy the infra with same code
    - Go back to your local, open your "devops-fully-automated" project on VSCODE
    - Open "Jenkinsfile" comment lines 59, 76-82 & uncomment lines 61, 84-90
    - Save the changes in both files
    - Finally push changes to repo
        `git add .`
        `git commit -m "relevant commit message"`
        `git push`

2) #### Terminate Jenkins EC2 instance

# Happy learning, everyone 😊 😊
