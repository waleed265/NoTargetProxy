#!/bin/bash -xv

ORG=$1
base64encoded=$2
ProxyName=$3
ENV=$4

echo "ORG: $ORG"
echo "base64encoded: $base64encoded"
echo "ProxyName: $ProxyName"

revision_info=$(curl -H "Authorization: Basic $base64encoded" "https://api.enterprise.apigee.com/v1/organizations/$ORG/environments/$ENV/apis/$ProxyName/deployments")

stable_revision_number=$(jq -r .revision[0].name <<< "${revision_info}" )  

echo "stable revision: $stable_revision_number"

echo "##vso[task.setvariable variable=stable_revision_number;isOutput=true]$stable_revision_number"
