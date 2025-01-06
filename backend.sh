#!/bin/bash

USERID=$(id -u)

LOGS_FOLDER="/var/log/expense-logs"
LOGS_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOGS_FILE-$TIMESTAMP.log"

VALIDATE() {
            if [ $1 -ne 0 ]
            then 
              echo "$2....Failure"
            else 
              echo "$2....Success"
            fi
}


CHECK_ROOT() {
if [ $USERID -ne 0 ]
then 
    echo "ERROR:Please make sure that you are a root user"
    exit 1
fi
}
echo "Script started executing at $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling old nodejs SERVER"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enabling nodejs SERVER"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "installing nodejs SERVER"

id expense &>>$LOG_FILE_NAME
if [$? -ne 0 ]
then 
    useradd expense &>>$LOG_FILE_NAME
    VALIDATE $? "Adding user to expense"
else 
    echo " User already exist.....SKIPING "
fi 

mkdir -p /app &>>$LOG_FILE_NAME
VALIDATE $? "creating a directory to download"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading backend app"

cd /app 

rm -rf /app/*


unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzip backend"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

#Prepare mysql schema 

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing MySql Client"

mysql -h 172.31.86.109 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "setting up transactions schema & table"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Daemon reload"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "Enabling backend"

systemctl restart backend &>>$LOG_FILE_NAME
VALIDATE $? "starting backend"







