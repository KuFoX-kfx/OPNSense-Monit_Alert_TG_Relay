#!/bin/sh

# URL Variables
SECRET_PATH="" # openssl rand -hex 16
DOMAIN="" # api.example.com

# TG Variables
TOKEN="" 
CHAT_ID="" 
ALERT_THREAD_ID="" # May be not set, message will be send in chat_id
KEEPALIVE_THREAD_ID="" # May be not set, message will be send in chat_id


# TG Message
MESSAGE="HOST: $MONIT_HOST
SERVICE: $MONIT_SERVICE
EVENT: $MONIT_EVENT
DETAILS: $MONIT_DESCRIPTION"



### Code
send() {
  thread_id="$1"; silent="$2"; text="$3"
  
  set -- --data-urlencode "chat_id=${CHAT_ID}" \
         --data-urlencode "disable_notification=${silent}" \
         --data-urlencode "text=${MESSAGE}"

  if [ -n "$thread_id" ]; then
    set -- --data-urlencode "message_thread_id=${THREAD_ID}"
  fi

  code=$(/usr/local/bin/curl -s --max-time 15 -o /dev/null -w "%{http_code}" -X POST \
  "https://${DOMAIN}/${SECRET_PATH}/bot${TOKEN}/sendMessage" "$@" )

  if [ "$code" != 200 ]; then
    logger -t tg_alert "Send failed! HTTP code: ${code}"
	return 1
  fi
	}

if [ -n "$MONIT_EVENT" ]; then
  send "$ALERT_THREAD_ID" "false" "$MESSAGE"
else
  send "$KEEPALIVE_THREAD_ID" "true" "KeepAlive: $(hostname) [$(date '+%Y-%m-%d %H:%M')]"