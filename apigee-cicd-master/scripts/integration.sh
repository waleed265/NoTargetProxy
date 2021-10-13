#!/bin/bash

# ORG=$1
# base64encoded=$2
echo "ORG: $ORG"
echo "base64encoded: $base64encoded"
echo "api_product: $api_product"
echo "developer: $developer"
echo "app: $app"

client_id=$(curl -H "Authorization: Basic $base64encoded" "https://api.enterprise.apigee.com/v1/organizations/$ORG/apiproducts/$api_product?query=list&entity=keys")

id=$(jq -r .[0] <<< "${client_id}" )
echo "client_id at script: '$id'"

client_secret=$(curl -H "Authorization: Basic $base64encoded" "https://api.enterprise.apigee.com/v1/organizations/$ORG/developers/$developer/apps/$app/keys/$id")

secret=$(jq -r .consumerSecret <<< "${client_secret}" )
echo "client_secret at script: '$secret'"

sudo npm install -g newman
newman run $GITHUB_WORKSPACE/apigee-cicd-master/test/integration/$NEWMAN_TARGET_URL --reporters cli,junit --reporter-junit-export junitReport.xml --env-var client_id=$id --env-var client_secret=$secret --export-environment env.json
#cat env.json

accessToken=$(cat env.json | jq -r '.values[] | select(.key=="accessToken").value')
#echo "accessToken at script: $accessToken"
bearer_token="Bearer "$accessToken"" 
echo "bearer_token at script: $bearer_token"
echo "bearer_token=$bearer_token" >> $GITHUB_ENV