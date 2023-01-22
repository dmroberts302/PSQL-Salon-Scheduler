#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

DISPLAY_SERVICES () {
  # retreive salon services
  SERVICES=$($PSQL "SELECT * FROM services")
  # list services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
}

MAIN_MENU () {
  
  if [[ $1 ]]
  then
    # print redirect message
    echo -e "\n$1"
  fi

  DISPLAY_SERVICES

  # read service from user
  read SERVICE_ID_SELECTED

  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  
  if [[ -z $SERVICE ]]
  then
    # if service id result is null send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    # read user phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
  

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      # read customer name if not in database
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # retreive customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

# welcome users
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU
