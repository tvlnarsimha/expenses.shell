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

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling the deafult node js"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling node js 20 version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing Node JS"

id expense -y &>>$LOGFILE
if [ $? -ne 0 ]
then 
  useradd expense -y &>>$LOGFILE
  VALIDATE $? "creating expense user"
else
  echo -e "Expense user already created...$Y SKIPPING $N"
fi 

