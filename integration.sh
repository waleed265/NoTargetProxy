#!/bin/bash

# ORG=$1
# base64encoded=$2
echo "ORG: $ORG"
echo "base64encoded: $base64encoded"

client_id=$(curl -H "Authorization: Basic $base64encoded" "https://api.enterprise.apigee.com/v1/organizations/$ORG/apiproducts/Cicd-Prod-Product?query=list&entity=keys")

id=$(jq -r .[0] <<< "${client_id}" )
echo "client_id at script: '$id'"

client_secret=$(curl -H "Authorization: Basic $base64encoded" "https://api.enterprise.apigee.com/v1/organizations/$ORG/developers/hr@api.com/apps/hrapp/keys/$id")

secret=$(jq -r .consumerSecret <<< "${client_secret}" )
echo "client_secret at script: '$secret'"

sudo npm install -g newman
newman run $NEWMAN_TARGET_URL --reporters cli,junit --reporter-junit-export junitReport.xml --env-var client_id=$id --env-var client_secret=$secret