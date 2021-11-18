#!/bin/bash

echo "SOURCE_BRANCH_NAME:$SOURCE_BRANCH_NAME"
echo "TARGET_BRANCH_NAME:$TARGET_BRANCH_NAME"
        
	if [["${TARGET_BRANCH_NAME}" -eq "uat" && "${SOURCE_BRANCH_NAME}" -ne "dev"]];
	then
         {
            echo "Cannot create pull request from $SOURCE_BRANCH_NAME to $TARGET_BRANCH_NAME"
            exit 1
          }
    fi