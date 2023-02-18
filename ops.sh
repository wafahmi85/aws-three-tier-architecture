#!/bin/bash

while true
do

    read -p "Please type 'deploy' to deploy resources or 'destroy' to terminate resources:" OPERATION

    if [ "$OPERATION" == "deploy" ]
    then
        terraform init
        terraform apply --auto-approve
        break
    elif [ "$OPERATION" == "destroy" ]
    then
        terraform destroy
        break
    else
        echo "Please define what you need to do correctly!!"
    fi

done