#!/bin/bash

echo "SOURCE_BRANCH_NAME:$SOURCE_BRANCH_NAME"
echo "TARGET_BRANCH_NAME:$TARGET_BRANCH_NAME"
        
	if [[ "${TARGET_BRANCH_NAME}" == "uat" && "${SOURCE_BRANCH_NAME}" != "dev" ]];
	then
         {
            echo "Cannot create Pull Request from '$SOURCE_BRANCH_NAME' to '$TARGET_BRANCH_NAME' branch...!!!"
            exit 1
          }
	
	elif [[ "${TARGET_BRANCH_NAME}" == "prod" && "${SOURCE_BRANCH_NAME}" != "uat" ]];
	then
         {
            echo "Cannot create Pull Request from '$SOURCE_BRANCH_NAME' to '$TARGET_BRANCH_NAME' branch...!!!"
            exit 1
          }
	
    fi 