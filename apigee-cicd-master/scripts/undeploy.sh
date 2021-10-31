#!/bin/bash -eux

# ORG=$1
# base64encoded=$2
# ProxyName=$3
# my_stable_revision=$4
# ENV=$5

echo "ENV: $ENV"
echo "ORG: $ORG"
echo "base64encoded: $base64encoded"
echo "ProxyName: $ProxyName"
echo "stable revision: $stable_revision_number"

echo "**************************************************"
echo "Fall Back Edge.json Deployment"
echo "**************************************************"
echo "Before Decryption"
echo "**************************************************"
cd $GITHUB_WORKSPACE/apigee-cicd-master/$ProxyName && ls

#Decrypt the file
#--batch to prevent interactive command
#--yes to assume "yes" for questions

gpg --quiet --batch --yes --decrypt --passphrase="$LARGE_SECRET_PASSPHRASE" \
--output $GITHUB_WORKSPACE/apigee-cicd-master/$ProxyName/edge.json $GITHUB_WORKSPACE/apigee-cicd-master/$ProxyName/edge-fallback.json.gpg

echo "**************************************************"
echo "After Decryption"
echo "**************************************************"
cd $GITHUB_WORKSPACE/apigee-cicd-master/$ProxyName && ls

echo "**************************************************"
echo "Deploying Fall Back Edge.json"
echo "**************************************************"


token_response=$(curl -s -X POST "https://majid-al-futtaim-group.login.apigee.com/oauth/token" -H "Content-Type:application/x-www-form-urlencoded;charset=utf-8" -H "accept: application/json;charset=utf-8" -H "authorization: Basic ZWRnZWNsaTplZGdlY2xpc2VjcmV0" -d "grant_type=password&username=apigee.cicduser1@maf.ae&password=cicduser$")

accessToken_SAML=$(jq -r '.access_token' <<< "${token_response}")
echo "SAML Access Token: $accessToken_SAML"

cd $GITHUB_WORKSPACE/apigee-cicd-master/$ProxyName && mvn apigee-config:specs apigee-config:caches apigee-config:keystores apigee-config:aliases apigee-config:references apigee-config:targetservers apigee-config:resourcefiles apigee-config:apiproducts apigee-config:developers apigee-config:apps apigee-config:companies apigee-config:companyapps apigee-config:reports apigee-config:importKeys -P$ENV -Dusername=$apigeeUsername -Dpassword=$apigeePassword -Dorg=$ORG -Dbearer=$accessToken_SAML -Dapigee.config.options=update -Dapigee.app.ignoreAPIProducts=true

current_deployment_info=$(curl -H "Authorization: Bearer $accessToken_SAML" "https://api.enterprise.apigee.com/v1/organizations/$ORG/environments/$ENV/apis/$ProxyName/deployments") 

rev_num=$(jq -r .revision[0].name <<< "${current_deployment_info}" ) 
env_name=$(jq -r .environment <<< "${current_deployment_info}" )
api_name=$(jq -r .name <<< "${current_deployment_info}" ) 
org_name=$(jq -r .organization <<< "${current_deployment_info}" )


echo "Current Revision: '$rev_num'"
echo "Current API Name: '$api_name'"
echo "Current ORG Name: '$org_name'"
echo "Current ENV Name: '$env_name'"
echo "Stable Revision: '$stable_revision_number'"


if [[ "${stable_revision_number}" -eq null && "${rev_num}" -eq 1 ]];
then
	echo "WARNING: Test failed, undeploying and deleting revision $rev_num"

	curl -X DELETE --header "Authorization: Bearer $accessToken_SAML" "https://api.enterprise.apigee.com/v1/organizations/$org_name/environments/$env_name/apis/$api_name/revisions/$rev_num/deployments"

	curl -X DELETE --header "Authorization: Bearer $accessToken_SAML" "https://api.enterprise.apigee.com/v1/organizations/$org_name/apis/$api_name/revisions/$rev_num"
	
	curl -X DELETE --header "Authorization: Bearer $accessToken_SAML" "https://api.enterprise.apigee.com/v1/organizations/$org_name/apis/$api_name"
else
echo "WARNING: Test failed, reverting from $rev_num to $stable_revision_number --- undeploying and deleting revision $rev_num"

curl -X DELETE --header "Authorization: Bearer $accessToken_SAML" "https://api.enterprise.apigee.com/v1/organizations/$org_name/environments/$env_name/apis/$api_name/revisions/$rev_num/deployments"

curl -X DELETE --header "Authorization: Bearer $accessToken_SAML" "https://api.enterprise.apigee.com/v1/organizations/$org_name/apis/$api_name/revisions/$rev_num"

echo ""
echo "Successfully undeployed current revision : '$rev_num'"

curl -X POST --header "Content-Type: application/x-www-form-urlencoded" --header "Authorization: Bearer $accessToken_SAML" "https://api.enterprise.apigee.com/v1/organizations/$org_name/environments/$env_name/apis/$api_name/revisions/$stable_revision_number/deployments"

echo ""
echo "Successfully deployed stable revision : '$stable_revision_number'"
fi

