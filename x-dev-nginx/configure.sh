#!/bin/bash -e

if [ -n "$PORT" ]; then
  echo "Configuring nginx: ${PORT}"

  envsubst '${PORT}' \
    < /etc/nginx/templates/nginx.conf.template \
    > /etc/nginx/conf.d/nginx.conf
else
  echo "Missing \$PORT"
  exit 1
fi

if [ -n "$HOST_SERVER" ] && [ -n "$PORT_SERVER" ]; then
  echo "Configuring server: ${HOST_SERVER} ${PORT_SERVER}"

  envsubst '${HOST_SERVER} ${PORT_SERVER}' \
    < /etc/nginx/templates/server.conf.template \
    > /etc/nginx/conf.d/server.conf.inc
else
  echo "" > /etc/nginx/conf.d/server.conf.inc
fi

if [ -n "$HOST_CLIENT" ] && [ -n "$PORT_CLIENT" ]; then
  echo "Configuring client: ${PORT} ${HOST_CLIENT} ${PORT_CLIENT}"

  envsubst '${PORT} ${HOST_CLIENT} ${PORT_CLIENT}' \
    < /etc/nginx/templates/client.conf.template \
    > /etc/nginx/conf.d/client.conf.inc
else
  echo "" > /etc/nginx/conf.d/client.conf.inc
fi

nginx -g 'daemon off;'
