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
#echo "client_id at script: '$id'"

client_secret=$(curl -H "Authorization: Basic $base64encoded" "https://api.enterprise.apigee.com/v1/organizations/$ORG/developers/$developer/apps/$app/keys/$id")

secret=$(jq -r .consumerSecret <<< "${client_secret}" )
#echo "client_secret at script: '$secret'"

sudo npm install -g newman 
sudo npm install -g newman-reporter-htmlextra
newman run $GITHUB_WORKSPACE/apigee-cicd-master/test/integration/$NEWMAN_TARGET_URL --reporters cli,junit --reporter-junit-export junitReport.xml,--reporter-htmlextra-export $GITHUB_WORKSPACE/newman_report.html --env-var client_id=$id --env-var client_secret=$secret --export-environment env.json
#cat env.json

accessToken=$(cat env.json | jq -r '.values[] | select(.key=="accessToken").value')

accessToken="Bearer ${accessToken}"
#foo="${foo} World"
# echo "accessToken at script: $accessToken"
# echo "accessToken=$accessToken" >> $GITHUB_ENV

echo  "replacer.full_list(0).replacement=$accessToken" >> $GITHUB_WORKSPACE/apigee-cicd-master/zap/options.prop
cat $GITHUB_WORKSPACE/apigee-cicd-master/zap/options.prop
