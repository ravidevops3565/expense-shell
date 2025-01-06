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

dnf install mysql-server -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing MySql SERVER"

systemctl enable mysqld >>$LOG_FILE_NAME
VALIDATE $? "Enable  MySql SERVER"

systemctl start mysqld >>$LOG_FILE_NAME
VALIDATE $? "starting  MySql SERVER"

mysql -h 172.31.86.109 -u root -p ExpenseApp@1 -e 'show databases' &>>$LOG_FILE_NAME

if [ $? -ne 0 ]
then 
    echo "MySql root password is not been set up" &>>$LOG_FILE_NAME
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "setting up root password"
else 
    echo "MySql root password already has been setup.... SKIPPING"
fi







#
#for package in $@
#do 
 #   dnf list installed $package &>>$LOG_FILE_NAME
 #   if [ $? -ne 0 ] 
  #  then 
  #        dnf install $package -y &>>$LOG_FILE_NAME
  #        VALIDATE $? "Installing $package"
  #  else 
  #        echo "$package already INSTALLED"
  #  fi

#done
