#!/bin/bash

while true
do

    read -p "Please type 'deploy' to deploy resources or 'destroy' to terminate resources:" OPERATION
    lowerstr=$(echo $i | tr '[:upper:]' '[:lower:]')

    if [ "$lowerstr" == "deploy" ]
    then
        terraform init
        terraform apply --auto-approve
        break
    elif [ "$lowerstr" == "destroy" ]
    then
        terraform destroy
        break
    else
        echo -e "\nPlease define correct operation!\n"
    fi

done