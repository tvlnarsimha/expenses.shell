#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter the db password:"
read mysql_root_password


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

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling the deafult node js"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling node js 20 version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing Node JS"

id expense  &>>$LOGFILE
if [ $? -ne 0 ]
then 
  useradd expense  &>>$LOGFILE
  VALIDATE $? "creating expense user"
else
  echo -e "Expense user already created...$Y SKIPPING $N"
fi 

mkdir -p /app &>>$LOGFILE
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading backend code"

cd /app
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "extracted backend code"

npm install &>>$LOGFILE
VALIDATE $? "Installing nodejs dependencies"

cp /home/ec2-user/expenses.shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "copied backed service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon reload"
systemctl start backend &>>$LOGFILE
VALIDATE $? "starting backend"
systemctl enable backend &>>$LOGFILE
VALIDATE $? "enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "installing mysql client"

mysql -h db.tvlnarsimha.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "restarting backend"

