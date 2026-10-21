# Base image: Debian 12, fixed version (never latest)
FROM debian:bookworm

# NGINX, OpenSSL (to create the certificate), envsubst (to fill in the domain)
RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx openssl gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Config template and startup script
COPY conf/nginx.conf.template /etc/nginx/nginx.conf.template
COPY tools/init-nginx.sh /usr/local/bin/init-nginx.sh

# Make the script executable, create folders, remove Debian's default site
RUN chmod +x /usr/local/bin/init-nginx.sh \
    && mkdir -p /etc/nginx/ssl /var/www/html \
    && rm -f /etc/nginx/sites-enabled/default

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/init-nginx.sh"]
