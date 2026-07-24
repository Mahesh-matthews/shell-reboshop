#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-reboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"
SCRIPT_DIR=$PWD



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

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOGS_FILE
    validate $? "Adding roboshop user"
 else
    echo -e "$B roboshop user is already present. $Y Skipping roboshop user creation$N"
 fi

mkdir -p /app &>> $LOGS_FILE
validate $? "Creating /app directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOGS_FILE
validate $? "Downloading catalogue code"

cd /app 
validate $? "Changing directory to /app"

rm -rf /app/* &>> $LOGS_FILE
validate $? "Cleaning /app directory"

unzip /tmp/catalogue.zip
validate $? "Extracting catalogue code"

npm install &>> $LOGS_FILE
validate $? "Installing nodejs dependencies"

cp catalogue.service /etc/systemd/system/catalogue.service &>> $LOGS_FILE
validate $? "Created systemctl service"

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
validate $? "Starting and enabling catalogue service"

