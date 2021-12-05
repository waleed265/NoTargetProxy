# Proxy-Repository-Apigee-CICD

## 1) Basic Concept
Proxy repository is the one where a proxy which has to be deployed on Apigee edge, tested & undeployed in case of tests failure automatically using pipelines; Pipelines will deploy the proxy on APIGEE edge UI using maven plugin.

## 2) Repository-Source Code & Branching Strategy
In Proxy repository Repository-Source Code Strategy will be as followed:
- 1 Project = 1 or more repo(s) 
- 1 Repo = 1 proxy
- 1 branch against each logical environment + 1 documentation branch as well
- Let say if you have 3 logical environment (DEV, UAT, PROD) than 3 branches will be utilized and 1 additional branch (Documentation) will be used in each proxy repository
- API developer will complete API proxy development on playground environment and push the code and artifacts (Pipelines yaml & scripts file) on playground branch
- API developer will initiate a Pull Request for approval from solution architect for merging playground branch code to respective higher (e.g. dev, uat, prod) environments

## 3) Branch Protection Rules
To restrict users from directly pushing the code into any environment branch, the branch protection rules are defined. All the branches of the repository except "playground" branch are protected and following branch protection rules will be applied.
- Require pull request reviews before merging
	- When enabled, all commits must be made to a non-protected branch and submitted via a pull request before they can be merged into a branch that matches this rule.
- Require approvals
	- When enabled, pull requests targeting a matching branch require a number of approvals and no changes requested before they can be merged.
	- Number of approvals can be defined in this option. As per our strategy multiple approvals will be required for prod level branches.
- Require status checks to pass before merging
	- When enabled, commits must first be pushed to another branch, then merged or pushed directly to a branch that matches this rule after status checks have passed.
	
## 4) Directory & File Structure
There will be 2 main directories in this repository.
- .github directory
- apigee-cicd-master directory


### 4.1) ".github" directory
- github directory contains the single directory named as workflows
- All the “.YML” files related to GitHub action pipelines will be placed in this workflows directory
	- mergeRequest.yml
	- pullRequest.yml
	- pipeline_testing.yml
	- Details about both of these files are explained in Pipelines section
	
### 4.2) "apigee-cicd-master" directory
In this directory there will be following subdirectories 
- Target Proxy Directory (e.g. NoTargetProxy)
- "scripts" Directory 
- "test" Directory
- "zap" Directory
- "package.json" file
- "shared-pom.xml" file

#### 4.2.1) Target Proxy Directory
This folder contains the target API proxy folder which has to be deployed to apigee. The name of the proxy repository should match with the name of this directory, because it is automatically set and used in the proxy pipeline. It contains following directories and files.
- "apiproxy" directory
- "pom.xml" file

##### 4.2.1.1) "apiproxy" directory
This folder contains the API proxy files in standard apigee API proxy directory structure. it contains the following subdirectories
- manifests directory
- policies directory
- proxies directory
- resources directory
- targets directory
- "ProxyName.xml" file e.g. NoTargetProxy.xml 

##### 4.2.1.2) "pom.xml" file
A Project Object Model or POM is the fundamental unit of work in Maven. It is an XML file that contains information about the project and configuration details used by Maven to build the project. It contains default values for most projects. When executing a task or goal, Maven looks for the POM in the current directory. It reads the POM, gets the needed configuration information, and then executes the goal. 
Some of the configuration that can be specified in the POM are the project dependencies, the plugins or goals that can be executed, the build profiles, and so on. Other information such as the project version, description, developers, mailing lists and such can also be specified.
This file is used in maven deployment of the proxy to apigee & it is a mandatory file for proxy deployment. It contains the important descriptions of an API proxy such as groupId, artifactId, version, name & packaging of the API proxy. It also contains the reference to the shared-pom/parent-pom which contains the shared necessary deployment configurations of the API proxy.

##### 4.2.1.3) Restrictions
- The proxy repository name should be identical with the the proxy directory name
	- The pipeline will dynamically pick the repository name & in case it is not set properly, it may result the failure of pipeline

#### 4.2.2) "scripts" directory
This folder contains all the scripts files used in pipeline workflows which are as follows:
- integration.sh
- revision.sh
- undeploy.sh
- pullRequest_validation.sh

##### 4.2.2.1) integration.sh
This script is called in the “Post-Deployment” job of “mergeRequest_(Branch_Name).yml” workflow. It is used for the integration testing of deployed proxy and execution of written integration tests in postman collection using newman.

##### 4.2.2.2) revision.sh
This script is called in the “Deployment” job of “mergeRequest_(Branch_Name).yml” workflow. It is used for getting the stable revision of currently deployed target proxy and saving it into the GitHub environment variable to use in next steps. 

##### 4.2.2.3) undeploy.sh
This script is called in the “Post-Deployment” job of “mergeRequest_(Branch_Name).yml” workflow. It is called in case of integration or ZAP tests failure, for undeploying the unstable revision and reverting back to stable revision of the target proxy.

##### 4.2.2.4) pullRequest_validation.sh
This script file is used to enforce branch protection rules.  This script will be used for pull request branch validation and will check if the source and target branch are valid. 

#### 4.2.3) "test" Directory
This folder contains the “Unit” & “Integration” tests to be executed on the target API proxy. It contains following 2 subdirectories:
- "integration" subdirectory
- "unit" subdirectory
- “proxy_details.json” file

##### 4.2.3.1) "integration" subdirectory
This folder contains the integration tests written in the postman collections. These collections are then run in our CICD pipeline through newman which is a collection runner.
These integration tests are written in JavaScript language. Postman tests can use Chai Assertion Library BDD syntax, which provides options to optimize how readable your tests are to you and your collaborators. 
For the API proxies which require the access token to call them must contain the pre-request script which is used for access token generation at the run time, store it in environment variable & then use it to call the API and execute integration tests on them. 

##### 4.2.3.2) "unit" subdirectory
This folder contains the unit tests written for java script files in proxy (jsc folder). These unit tests are written in java script language and executed through “npm”. “Mocha” is used as the unit testing framework, “sinon” for mocking and expect.js for assertions.

##### 4.2.3.3) “proxy_details.json” file
There is json file which contains below-mentioned details. This file in placed in the integration directory. The information provided in this file will help proxy to execute integration test scenarios by dynamically generating the access token and using the generated token to call the integration test scenarios. The file name is “proxy_details.json”

#### 4.2.4) "zap" Directory
This folder contains the “options.prop” zap configurations file. 
- This file is provided as cmd_options in zap scan task
- It contains the header replacement parameters of target API Proxy. For example for this sample proxy (NoTargetProxy) header Authorization parameters are passed which are used to call the proxy in zap scan
- Value of the access token is passed into this file at the run time during the execution of “integration.sh” script

#### 4.2.5) "package.json" file
The “package. json” file is the heart of any Node project. It records important metadata about a project which is required before publishing to NPM, and also defines functional attributes of a project that npm uses to install dependencies, run scripts, and identify the entry point to our package.
Mocha unit tests & NYC (Istanbul) coverage tests which are executed in “Pre-deployment” stage in “pull_request” pipeline are run through npm. And all of the npm install dependencies and run scripts are defined in this “package.json” file.

#### 4.2.6) "shared-pom.xml" file
A Project Object Model or POM is the fundamental unit of work in Maven. It is an XML file that contains information about the project and configuration details used by Maven to build the project. It contains default values for most projects. When executing a task or goal, Maven looks for the POM in the current directory. It reads the POM, gets the needed configuration information, and then executes the goal. 
Some of the configuration that can be specified in the POM are the project dependencies, the plugins or goals that can be executed, the build profiles, and so on. Other information such as the project version, description, developers, mailing lists and such can also be specified.
This “shared-pom.xml” file is a reference file of “pom.xml” file which is used in proxy deployment to apigee. It contains the necessary information/tools required for the deployment.

## 5) Pipelines
This repository will contain following 3 pipeline files in “.github/workflows/” directory.
1)	pullRequest.yml
2)	mergeRequest.yml
3)	pipeline_testing.yml

### 5.1) “pullRequest.yml” - Pipeline Setup
This workflow is triggered whenever a pull request in opened/initiated for the specified (e.g. sandbox,dev,uat,prod etc) branch.

#### 5.1.1) Workflow Environment Variables – Secrets
There are 2 environment variables defined for this workflow.

- ProxyName: This variable contains the target proxy name on which the pre-deployment phase tests (Unit Tests, Coverage and Policy Code Analysis) are performed. Value of this environment variable is set dynamically as current repository name. 
- MS_TEAMS_WEBHOOK_URI: There is  1 secret type environment variable “MS_TEAMS_WEBHOOK_URI” for this workflow. It is used to send pipeline execution notifications to Microsoft teams.

#### 5.1.2) Workflow Jobs
There is only one Job named as “Pre-Deployment” in this workflow.

#### 5.1.3) Workflow Execution Steps
This pipeline workflow will execute the b/m steps defined in workflow .yml file:
- Checkout the repository to fetch source code in the agent workspace
- Get branch name of the pull request's "Base (Target)" branch and setting as environment variable
- Perform unit testing with coverage using Mocha and attach Unit Test Report on Pull Request
- Publish coverage report using Cobertura on Pull Request
- Perform policy code analysis to check for anti-patterns using Apigee Lint
- Publish the policy code analysis report in HTML format as an artifact
- Update the status of the commit and add execution related comments on Pull Request
- Send notification on Microsoft teams about the execution (Initiation, Success & Failure) of the pipeline workflow

### 5.2) “mergeRequest.yml” - Pipeline Setup
This workflow is triggered whenever a pull request in merged (closed) for the specified (e.g. sandbox,dev,uat,prod etc) branch.

#### 5.2.1) Workflow Environment Variables – Secrets
Following environment variables are defined for this pipeline workflow.
- Proxy Name: Contains the name of target proxy for Deployment & Post-Deployment stages. It is dynamically set to the repository name. As repository name will be same as target proxy name as per our defined strategy
- ORG: Target Apigee organization where the proxy will be deployed
- ENV: Target Apigee environment for proxy deployment. It is dynamically set to "Base (Target)" branch name of the pull request. As branch name corresponds to the apigee environment as per our defined strategy
- machine_apigeeUsername: Username of the Apigee machine user (type of this environment variable will be secret and will be defined in GitHub repository/organization secrets)
	- It is recommended to place this information in GitHub organization secret
- machine_apigeePassword: Password of the Apigee machine user (type of this environment variable will be secret and will be defined in GitHub repository/organization secrets)
	- It is recommended to place this information in GitHub organization secret
- SAML_BASIC:  Basic access token value used in curl command to get SAML access token in different pipeline scripts
- proxy_basepath:  URL Base Path of the target API Proxy. Used to generate Target API/Proxy URL for ZAP DAST scan dynamically (In integration.sh script)
- NEWMAN_TARGET_COLLECTION: Target API/Proxy collection containing the integration tests (dynamically generated in integration.sh script) 
- MS_TEAMS_WEBHOOK_URI: It is used to send pipeline execution notifications to Microsoft Teams
	- It is recommended to place this information in GitHub organization secret
	
#### 5.2.2) Workflow Jobs
There are two Jobs in this workflow naming:
1)	Deployment
2)	Post-Deployment

#### 5.2.3) Workflow Execution Steps
This pipeline workflow will execute the b/m steps defined in workflow .yml file:
- Checkout the repository to fetch source code in the agent workspace
- Setting environment variables "stable_revision_number" & "ENV", generated in this job as "Job outputs" to pass them into next job
- Getting "Base (Target)" branch name of the pull request and setting it as environment variable "ENV"
- Setting $ENV as output for passing it to next job (Post-Deployment)
- Pipeline will save stable revision of API proxy that is currently deployed
- Pipeline will deploy API proxy using maven command
- Commit build Status update & publish respective comments on Pull Request for “Deployment” job
- Sending Microsoft Teams Notifications regarding the execution of "Deployment" Job
- Getting $ENV output from previous "Deployment" Job & setting it as environment variable to use it in this job (Post-Deployment)
- Getting the stable revision output from previous job “Deployment” & setting it as environment variable to use it in this job (Post-Deployment)
- Perform integration testing through Newman tool, save the report in HTML format & then publishing it
- Perform DAST scanning through ZAP tool and publishing its report
- In case of failure of either “Integration” or “ZAP scan” tasks pipeline will un-deploy current unstable revision & redeploy stable revision of API proxy using undeploy.sh script
- Commit build Status update & publish respective comments on Pull Request
- In case of success or failure during execution of pipeline concerned team/person will be notified on Microsoft teams. Sending Microsoft Teams Notifications regarding the execution of "Deployment" Job

### 5.3) “pipeline_testing.yml” - Pipeline Setup
This workflow is created to be run on “playground” environment by the developer for the initial testing purposes. It can be triggered on push to the playground branch as well as can be run manually by “workflow_dispatch” event trigger also. This workflow contains all the 3 Jobs which are explained above “Pre-Deployment”, “Deployment” & “Post-Deployment” at one place. 
Note: After completing the testing in playground environment, developer should comment the push trigger section in this workflow before generating pull request (to merge proxy code in higher environment). As in case of push/merge commit for resolving conflicts, this pipeline will be triggered again. 


## 6) CICD Flow
Following are the step for CICD flow:

### 6.1) CICD Flow – Developer
- API developer will complete API proxy development on playground environment and push the code and artifacts (Pipelines yaml & scripts file) on playground branch
- API developer will initiate a Pull Request for approval from solution architect for merging playground branch code to respective higher (e.g. DEV, UAT) environment
- On initiating/opening Pull Request, a pipeline workflow “PullRequest.yaml” will automatically triggered which will execute the between steps defined in workflow.yaml file
- Perform unit testing with coverage using Mocha and attach Unit Test Report on Pull Request
- Publish coverage report using Cobertura on Pull Request
- Perform policy code analysis to check for anti-patterns using ApigeeLint
- Publish the policy code analysis report in HTML format as an artifact
- Commit build Status update & publish respective comments on Pull Request

### 6.2) CICD Flow – Reviewer/Solution Architect 
- API Solution Architect will review the pull request (proxy code, attached unit test reports on pull request) and approve the merge request. This will trigger the second pipeline workflow “mergeRequest.yaml”  for the respective (e.g. dev) branch which will execute the steps define in “mergeRequest.yaml” file
- Pipeline will save stable revision of API proxy that is currently deployed
- Pipeline will deploy environment configurations defined in config file & API proxy using maven command
- Perform integration testing through Newman tool and save the report in HTML format
	- In case of failure pipeline will un-deploy current unstable revision & redeploy stable revision of API proxy 
- Perform DAST scanning through ZAP tool and save the report in HTML format
	- In case of failure pipeline will un-deploy current unstable revision & redeploy stable revision of API proxy 
- Publish integration & ZAP test reports
- Commit build Status update & publish respective comments on Pull Request
- In case of success or failure during execution of pipeline concerned team/person will be notified on Microsoft teams
- In case of failure API Solution Architect will revert the merged commit which will roll back the last stable commit of the branch
- After successful deployment of API proxy on dev environment API Solution Architect will merge the code of dev branch into UAT branch
- CICD pipeline workflows for UAT branch will be triggered and start executing steps explained above for UAT environment
