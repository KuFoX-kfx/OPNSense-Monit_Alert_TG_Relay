#!/bin/sh

# URL Variables
SECRET_PATH="" # openssl rand -hex 16
DOMAIN="" # api.example.com

# TG Variables
TOKEN="" 
CHAT_ID="" 
THREAD_ID=""


# TG Message
MESSAGE="HOST: $MONIT_HOST
SERVICE: $MONIT_SERVICE
EVENT: $MONIT_EVENT
DETAILS: $MONIT_DESCRIPTION"



# Execution
/usr/local/bin/curl -s --max-time 15 -X POST "https://${DOMAIN}/${SECRET_PATH}/bot${TOKEN}/sendMessage" \
  --data-urlencode "chat_id=${CHAT_ID}" \
  --data-urlencode "message_thread_id=${THREAD_ID}" \
  --data-urlencode "text=${MESSAGE}"
