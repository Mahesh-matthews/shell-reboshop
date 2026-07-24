#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-reboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"



if [ $USERID -ne 0 ]; then
    echo -e "$R You are not running as root.$N" | tee -a $LOGS_FILE
    exit 1
 fi  

 mkdir -p $LOGS_FOLDER

   validate(){

    if [ $1 -ne 0 ]; then
        echo -e "$R $2 ... Failure$N" | tee -a $LOGS_FILE
        exit 1
    else
        echo -e "$G $2 ... Success$N" | tee -a $LOGS_FILE
    fi
   }

   cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGS_FILE
    validate $? "Copying mongo repo"

    dnf install mongodb-org -y &>> $LOGS_FILE
    validate $? "Installing mongodb-Server"

    systemctl enable mongod &>> $LOGS_FILE
    validate $? "Enabling mongodb service"

    systemctl start mongod &>> $LOGS_FILE
    validate $? "Starting mongodb service"

    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGS_FILE
    validate $? "Allowing remote connection to mongodb"

    systemctl restart mongod &>> $LOGS_FILE
    validate $? "Restarting mongodb service"

