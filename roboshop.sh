#!/bin/bash

SG_ID="sg-0fb54d735c2e0463c"
AMI-ID="ami-0220d79f3f480ecf5"

for instance in $@
do 

    INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI-ID \
    --instance-type "t3.micro" \
    --key-name roboshop \
    --security-group-ids $SG_ID \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=$instance}]' \
    --query 'Instances[0].InstanceId' \
    --output text)

    if [ $instance == "frontend" ]; then
      IP=$(
            aws ec2 describe-instances \
                --instance-ids $INSTANCE_ID \ 
                --query 'Reservations[].Instances[].PublicIpAddress' \  
                --output text    
      )
    else 
      IP=$(
            aws ec2 describe-instances \
                --instance-ids $INSTANCE_ID \ 
                --query 'Reservations[].Instances[].PrivateIpAddress' \  
                --output text    
      )
    fi
    echo "IP Address: $IP"
done

