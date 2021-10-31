#!/bin/bash

# ORG=$1
# base64encoded=$2
# ProxyName=$3
# ENV=$4

echo "ORG: $ORG"
#echo "base64encoded: $base64encoded"
echo "ProxyName: $ProxyName"
echo "machine_apigeeUsername: $machine_apigeeUsername" 

token_response=$(curl -s -X POST "https://majid-al-futtaim-group.login.apigee.com/oauth/token" -H "Content-Type:application/x-www-form-urlencoded;charset=utf-8" -H "accept: application/json;charset=utf-8" -H "authorization: Basic ZWRnZWNsaTplZGdlY2xpc2VjcmV0" -d "grant_type=password&username=$machine_apigeeUsername&password=$machine_apigeePassword")

accessToken_SAML=$(jq -r '.access_token' <<< "${token_response}")
echo "SAML Access Token: $accessToken_SAML"

revision_info=$(curl -H "Authorization: Bearer $accessToken_SAML" "https://api.enterprise.apigee.com/v1/organizations/$ORG/environments/$ENV/apis/$ProxyName/deployments")

stable_revision_number=$(jq -r .revision[0].name <<< "${revision_info}" )  

echo "stable revision: $stable_revision_number"
echo "stable_revision_number=$stable_revision_number" >> $GITHUB_ENV
#echo "##vso[task.setvariable variable=stable_revision_number;isOutput=true]$stable_revision_number"
