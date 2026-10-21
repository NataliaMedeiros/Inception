# Base image: Debian 12, fixed version (never latest)
FROM debian:bookworm

# PHP-FPM, PHP extensions used by WordPress, and tools to download files
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        php8.2-fpm php8.2-cli php8.2-mysql php8.2-curl php8.2-gd \
        php8.2-mbstring php8.2-xml php8.2-zip \
        curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

#php*.2-mysql - Allow PHP to connect whit MariaDB

# WP-CLI: installs and configures WordPress from the command line
RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
        -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

# Make php-fpm listen on port 9000 (reachable from other containers)
COPY conf/zz-docker.conf /etc/php/8.2/fpm/pool.d/zz-docker.conf

# Startup script
COPY tools/init-wp.sh /usr/local/bin/init-wp.sh

RUN chmod +x /usr/local/bin/init-wp.sh \
    && mkdir -p /run/php /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/init-wp.sh"]
