# OPNSense-Monit_Alert_TG_Relay

Репозиторий в котором описывается как настроить уведомления в ТГ для OPNsense если вы из РФ

## Зачем это надо

Telegram API в РФ недоступен напрямую, алёрты из Monit в TG можно отправлять только через свой сервер за рубежом. Можно использовать VPN или Zapret для обхода ТСПУ, но это очень громоздко и нестабильно. Поэтому на зарубежном сервере стоит Caddy, который проксирует запросы в `api.telegram.org`, но только если в URL есть секретный путь. На любой другой запрос он отдаёт заглушку, так что при active probing сервер выглядит как обычный сайт.

## Как это работает

```
OPNsense (Monit)
   │  tg_alert.sh → curl
   │  https://example.com/<SECRET>/bot<TOKEN>/sendMessage
   ▼
Сервер за рубежом (Caddy)
   ├─ /<SECRET>/*   → срезает /<SECRET> и проксирует на api.telegram.org
   ├─ /             → заглушка "Reverse Proxy is work!" (200)
   └─ всё остальное → 404
   ▼
Telegram API → чат / топик
```

## Установка на сервере

1. Создать DNS запись которая будет ссылаться на сервер. Для удобства можно сделать домен третьего уровня. Нельзя использовать слова по типу `vpn proxy tg telegram`. Порты 80 и 443 должны быть открыты и доступны.
2. Создайте директорию `/opt/tg-relay/`, положите `Caddyfile` в неё. Замените `example.com` в `Caddyfile` на свой домен.
3. Сгенерируйте секрет:

  ```sh
  openssl rand -hex 16
  ```

  Дальше передайте его как переменную `RELAY_SECRET`:

  - **Чистый Docker Compose:** создайте `.env` рядом с `docker-compose.yml`:

    ```sh
    echo "RELAY_SECRET=<ваш секрет>" > /app/tg-relay/.env
    ```

  - **Dockhand, Portainer, Dockge и подобные:** добавьте `RELAY_SECRET` в переменные окружения стека в веб-интерфейсе, `.env` создавать не нужно.

4. Запустите:

   - **Чистый Docker Compose:** через команду
 
   ```sh
   cd /opt/tg-relay
   docker compose up -d
   ```

 - **Dockhand, Portainer, Dockge и подобные:** Через веб интерфейс

5. Проверьте:

   ```sh
   curl https://example.com/                 # заглушка
   curl https://example.com/test             # 404
   curl https://example.com/<SECRET>/bot<TOKEN>/getMe   # ответ от Telegram
   ```
   И/или запустите уже настроенный `tg-alert.sh`, он должен отправить сообщение

## Настройка на OPNsense

1. Скопируйте `tg-alert.sh` на opnsense, например в `/usr/local/bin/tg-alert.sh`, и сделайте исполняемым:

   ```sh
   chmod +x /usr/local/bin/tg-alert.sh
   ```

2. Заполните переменные в начале скрипта:

   | Переменная | Что указать |
   |---|---|
   | `DOMAIN` | домен вашего сервера |
   | `SECRET_PATH` | секрет который мы ранее генерировали |
   | `TOKEN` | токен бота от @BotFather |
   | `CHAT_ID` | ID чата |
   | `THREAD_ID` | ID топика |

3. В Monit (Services > Monit > Service Test Settings) создайте тест, выберите действие `Execute` и укажите путь до скрипта. 

4. Запустите скрипт вручную и убедитесь, что сообщение пришло. Для проверки можно подставить значения переменных:

   ```sh
   MONIT_HOST=test MONIT_SERVICE=test MONIT_EVENT=test MONIT_DESCRIPTION=test /usr/local/bin/tg-alert.sh
   ```