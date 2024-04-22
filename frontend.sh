#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


VALIDATE(){
   if [ $1 -ne 0 ]
    then
      echo -e "$2 ...$R Failure $N"
      exit 1
    else
     echo -e "$2...$G Success $N"
   fi
}

if [ $USERID -ne 0 ]
then
 echo "Please run this script with root access"
 exit 1 # manually exit if error comes
else
 echo "you are the super user"
fi

dnf install nginx -y  &>>$LOGFILE
VALIDATE $? "Installing ngnix"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "enabling ngnix"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "starting ngnix"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "removing exisitng content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading frontend code"

cd /usr/share/nginx/html &>>$LOGFILE
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "extracting frontend code"

#check your repo and path
cp /home/ec2-user/expenses.shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "copied expense conf"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "restarting ngnix"



