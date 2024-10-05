#! /bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M%S)
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
     then
      echo -e "$R Please run the script using root preveliges $N" | tee -a $LOGS_FILE
      exit 1 
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is...$R FAILED $N"  | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

echo "Script started executing at:$(date)" | tee -a $LOGS_FILE
CHECK_ROOT

dnf install mysql-server -y &>> $LOGS_FILE
VALIDATE $? "Installing Mysql Server"

systemctl enable mysqld &>> $LOGS_FILE
VALIDATE $? "Enabling Mysql Server"

systemctl start mysqld &>> $LOGS_FILE
VALIDATE $? "Starting Mysql Server"

#In place of hostname we  should give Ip address or Domain name
mysql -h 44.201.174.43 -u root -pExpenseApp@1 -e 'show databases' &>> $LOGS_FILE

if [ $? -ne 0 ]
then
echo "Mysql server root password is not setup, setting up now" &>> $LOGS_FILE
mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting up mysql root password done"
else
echo -e "MySQL root password is already setup...$Y SKIPPING $N" | tee -a $LOG_FILE
fi