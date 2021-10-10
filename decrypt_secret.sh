#!/bin/bash

echo "GITHUB_WORKSPACE: $GITHUB_WORKSPACE"
echo "ProxyName: $ProxyName"
echo "LARGE_SECRET_PASSPHRASE: $LARGE_SECRET_PASSPHRASE"
# Decrypt the file
#mkdir $HOME/secrets
# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$LARGE_SECRET_PASSPHRASE" \
--output $GITHUB_WORKSPACE/apigee-cicd-master/$ProxyName/edge.json $GITHUB_WORKSPACE/apigee-cicd-master/$ProxyName/edge.json.gpg

cd $GITHUB_WORKSPACE/apigee-cicd-master/$ProxyName && ls