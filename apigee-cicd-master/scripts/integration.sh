#!/bin/bash

# ORG=$1
# base64encoded=$2
echo "ORG: $ORG"
echo "base64encoded: $base64encoded"
echo "api_product: $api_product"
echo "developer: $developer"
echo "app: $app"

token_response=$(curl -s -X POST "https://majid-al-futtaim-group.login.apigee.com/oauth/token" -H "Content-Type:application/x-www-form-urlencoded;charset=utf-8" -H "accept: application/json;charset=utf-8" -H "authorization: Basic ZWRnZWNsaTplZGdlY2xpc2VjcmV0" -d "grant_type=password&username=apigee.cicduser1@maf.ae&password=cicduser$")

accessToken_SAML=$(jq -r '.access_token' <<< "${token_response}")
echo "SAML Access Token: $accessToken_SAML"

client_id=$(curl -H "Authorization: Bearer $accessToken_SAML" "https://api.enterprise.apigee.com/v1/organizations/$ORG/apiproducts/$api_product?query=list&entity=keys")

id=$(jq -r .[0] <<< "${client_id}" )
#echo "client_id at script: '$id'"

client_secret=$(curl -H "Authorization: Bearer $accessToken_SAML" "https://api.enterprise.apigee.com/v1/organizations/$ORG/developers/$developer/apps/$app/keys/$id")

secret=$(jq -r .consumerSecret <<< "${client_secret}" )
#echo "client_secret at script: '$secret'"

sudo npm install -g newman 
sudo npm install -g newman-reporter-htmlextra

newman run $GITHUB_WORKSPACE/apigee-cicd-master/test/integration/$NEWMAN_TARGET_URL -r htmlextra --reporter-htmlextra-export ./reports/newman_report.html --env-var client_id=$id --env-var client_secret=$secret --export-environment env.json

cat env.json

accessToken=$(cat env.json | jq -r '.values[] | select(.key=="accessToken").value')

#foo="${foo} World"
# echo "accessToken at script: $accessToken"
# echo "accessToken=$accessToken" >> $GITHUB_ENV

accessToken="Bearer ${accessToken}"


echo  "replacer.full_list(0).replacement=$accessToken" >> $GITHUB_WORKSPACE/apigee-cicd-master/zap/options.prop
cat $GITHUB_WORKSPACE/apigee-cicd-master/zap/options.prop

newman run $GITHUB_WORKSPACE/apigee-cicd-master/test/integration/$NEWMAN_TARGET_URL --reporters cli,junit --reporter-junit-export junitReport.xml --env-var client_id=$id --env-var client_secret=$secret 

