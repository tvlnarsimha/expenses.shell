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

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing MySql Server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling Mysql server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Start Mysql server"

#mysql_secure_installation --set-root-pass ExpenseApp@1
#VALIDATE $? "Setting up the root password"

#Below command will be useful for idempotent nature
mysql -h db.tvlnarsimha.online -uroot -p${mysql_root_password} -e 'SHOW DATABASES;' &>>$LOGFILE

if [ $? -ne 0 ]
then 
   mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
   VALIDATE $? "Mysql root password set up"
 else
   echo -e "Mysql root password is already setup...$Y SKIPPING $N"
fi

 
