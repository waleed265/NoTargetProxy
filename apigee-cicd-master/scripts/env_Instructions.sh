#!/bin/bash
cd $GITHUB_WORKSPACE/apigee-cicd-master/instructions/env_instructions/$ENV
echo "Status = $(cat Env_Instruction.json | jq -r '.[].status')"
if [[ "$(cat Env_Instruction.json | jq -r '.[].status')" == "EXECUTE" ]]
then
   for row in $(cat Env_Instruction.json | jq -r '.[].ExecuteFiles[] | @base64'); do
      echo "in Loop"
     _jq() {
      echo ${row} | base64 --decode | jq -r ${1}
     }
     echo $(_jq '.fileDir')
     #filePathArray=($(echo $(_jq '.filePath') | tr "/" " "))
     #echo "${#filePathArray[@]}"
     echo "mvn apigee-config:$(_jq '.fileDir') -P$ENV -Dusername=$machine_apigeeUsername -Dpassword=$machine_apigeePassword -Dorg=$ORG -Dapigee.config.file=$GITHUB_WORKSPACE/Env_Config/$ENV/$(_jq '.fileDir')/$(_jq '.filename') -Dapigee.config.options=$(_jq '.action')"
   done
else
   echo "Status = $(cat Env_Instruction.json | jq -r '.[].status')"
fi
