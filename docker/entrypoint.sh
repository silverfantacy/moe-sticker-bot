#!/bin/sh
set -eu

: "${PORT:=8080}"
: "${LOG_LEVEL:=info}"
: "${DATA_DIR:=/data}"
: "${WEBAPP_DATA_DIR:=/webapp/data}"
: "${WEBAPP_PROXY_BASE:=127.0.0.1:3921/webapp}"
: "${WEBAPP_LISTEN_ADDR:=127.0.0.1:3921}"

if [ -z "${BOT_TOKEN:-}" ]; then
  echo "BOT_TOKEN is required" >&2
  exit 1
fi

mkdir -p "$DATA_DIR" "$WEBAPP_DATA_DIR"
envsubst '${PORT} ${WEBAPP_DATA_DIR} ${WEBAPP_PROXY_BASE}' \
  < /etc/nginx/templates/default.conf.template \
  > /etc/nginx/conf.d/default.conf

args="
  --bot_token=$BOT_TOKEN
  --log_level=$LOG_LEVEL
  --data_dir=$DATA_DIR
"

if [ -n "${DB_ADDR:-}" ]; then
  args="$args --db_addr=$DB_ADDR --db_user=${DB_USER:-} --db_pass=${DB_PASS:-}"
fi

if [ -n "${WEBAPP_URL:-}" ]; then
  args="$args --webapp_url=$WEBAPP_URL --webapp_data_dir=$WEBAPP_DATA_DIR --webapp_listen_addr=$WEBAPP_LISTEN_ADDR"
fi

moe-sticker-bot $args &
bot_pid=$!

nginx -g 'daemon off;' &
nginx_pid=$!

trap 'kill "$bot_pid" "$nginx_pid" 2>/dev/null || true; wait' INT TERM

while kill -0 "$bot_pid" 2>/dev/null && kill -0 "$nginx_pid" 2>/dev/null; do
  sleep 2
done

kill "$bot_pid" "$nginx_pid" 2>/dev/null || true
wait
