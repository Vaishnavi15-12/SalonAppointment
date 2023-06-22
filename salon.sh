#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"
MAIN_MENU(){
    
    SERVICES_OFFERED=$($PSQL "select  * from services")
    echo "$SERVICES_OFFERED" | while read SERVICE_ID BAR NAME
    do
        echo "$SERVICE_ID) $NAME"
    done
    read SERVICE_ID_SELECTED


    if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]+$ ]]
    then
         echo -e "\nI could not find that service. What would you like today?"
         MAIN_MENU
    else 
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
        then
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME
            INSERTED_TO_CUSTOMERS=$($PSQL "insert into customers(phone,name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
            SERVICE
        else 
             SERVICE
        fi
    
    fi
}
SERVICE(){
    SERVICE_TYPE=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    echo -e "\nWhat time would you like your $(echo $SERVICE_TYPE | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
    read SERVICE_TIME
    echo -e "\nI have put you down for a $(echo $SERVICE_TYPE | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    APPOINTMENT
}

APPOINTMENT()
{
    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    
    INSERTED_TO_APPOINTMENTS=$($PSQL "insert into appointments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
}

MAIN_MENU
