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

dnf module disable nodejs -y &>> $LOGS_FILE
validate $? "Disabling nodejs module"

dnf module enable nodejs:20 -y &>> $LOGS_FILE
validate $? "Enabling nodejs module"

dnf install nodejs -y &>> $LOGS_FILE
validate $? "Installing nodejs" 

id reboshop &>> $LOGS_FILE
if [ $? -ne 0 ]; then
    echo -e "$Y roboshop user is not present. Creating roboshop user$N" | tee -a $LOGS_FILE
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "Adding roboshop user"
 else
    echo -e "$B roboshop user is already present. Skipping roboshop user creation$N" | tee -a $LOGS_FILE
 fi

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
validate $? "Adding roboshop user"

mkdir -p /app 
validate $? "Creating /app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
validate $? "Downloading catalogue code"

cd /app 
validate $? "Changing directory to /app"

unzip /tmp/catalogue.zip
validate $? "Extracting catalogue code"
