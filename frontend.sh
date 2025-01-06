#!/bin/Bash

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

mkdir -p $LOGS_FOLDER
echo "Script started executing at $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT

dnf install nginx -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing nginx server"

systemctl enable nginx &>>$LOG_FILE_NAME
VALIDATE $? "Enabling nginx server"

systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "Starting nginx server"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE_NAME
VALIDATE $? "Removing existing version of code"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading latest version of code"

cd /usr/share/nginx/html &>>$LOG_FILE_NAME
VALIDATE $? "Moving to html directory"

unzip /tmp/frontend.zip &>>$LOG_FILE_NAME
VALIDATE $? "unzipping front end app"

systemctl restart nginx &>>$LOG_FILE_NAME
VALIDATE $? "restarting nginx"


