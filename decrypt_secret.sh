#!/bin/bash

echo "ProxyName: $ProxyName"
echo "LARGE_SECRET_PASSPHRASE: $LARGE_SECRET_PASSPHRASE"
# Decrypt the file
#mkdir $HOME/secrets
# --batch to prevent interactive command
# --yes to assume "yes" for questions
gpg --quiet --batch --yes --decrypt --passphrase="$LARGE_SECRET_PASSPHRASE" \
--output ${{ github.workspace }}/apigee-cicd-master/$ProxyName/edge.json ${{ github.workspace }}/apigee-cicd-master/$ProxyName/edge.json.gpg

cd ${{ github.workspace }}/apigee-cicd-master/$ProxyName && ls