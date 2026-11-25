#!/bin/sh

# URL Variables
SECRET_PATH="a61eb280a92237b19a0c7320429fdb1d" # openssl rand -hex 16
DOMAIN="api.kufox.su"

# TG Variables
TOKEN="9150390033:AAG5UzFgnK0_UFHPCKs6M_oJRucK8pR6_wA" 
CHAT_ID="-1004412698731" 
ALERT_THREAD_ID="8" # May be not set, message will be send in chat_id
KEEPALIVE_THREAD_ID="22" # May be not set, message will be send in chat_id



### Code
send() {
  thread_id="$1"; silent="$2"; text="$3"
  
  set -- --data-urlencode "chat_id=${CHAT_ID}" \
         --data-urlencode "disable_notification=${silent}" \
         --data-urlencode "text=${text}"

  if [ -n "$thread_id" ]; then
    set -- "$@" --data-urlencode "message_thread_id=${thread_id}"
  fi

  code=$(/usr/local/bin/curl -s --max-time 15 -o /dev/null -w "%{http_code}" -X POST \
  "https://${DOMAIN}/${SECRET_PATH}/bot${TOKEN}/sendMessage" "$@" )

  if [ "$code" != 200 ]; then
    logger -t tg_alert "Send failed! HTTP code: ${code}"
	return 1
  fi
	}

if [ -n "$MONIT_EVENT" ]; then
  MESSAGE="HOST: $MONIT_HOST
SERVICE: $MONIT_SERVICE
EVENT: $MONIT_EVENT
DETAILS: $MONIT_DESCRIPTION"

  send "$ALERT_THREAD_ID" "false" "$MESSAGE"
else
  send "$KEEPALIVE_THREAD_ID" "true" "KeepAlive: $(hostname) [$(date '+%Y-%m-%d %H:%M')]"
fi
 