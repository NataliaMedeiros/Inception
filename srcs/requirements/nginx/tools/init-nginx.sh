#!/bin/sh
set -e

# Create the self-signed certificate on the first start
if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/CN=${DOMAIN_NAME}"
fi

# Fill in the domain name from the environment
envsubst '${DOMAIN_NAME}' < /etc/nginx/nginx.conf.template > /etc/nginx/conf.d/default.conf

# Run NGINX in the foreground as PID 1
exec nginx -g 'daemon off;'
