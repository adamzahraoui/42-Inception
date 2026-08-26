#!/bin/bash

sleep 5
mkdir -p /var/www/html
cd /var/www/html
rm -rf *
wp core download --allow-root

wp config create --allow-root \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="mariadb:3306"

wp core install --allow-root \
    --url="$DOMAIN_NAME" \
    --title="Inception 42" \
    --admin_user="$WP_ADMIN_USER" \
    --admin_password="$WP_ADMIN_PASSWORD" \
    --admin_email="$WP_ADMIN_EMAIL"

wp user create --allow-root \
    "$WP_USER" "$WP_USER_EMAIL" \
    --user_pass="$WP_USER_PASSWORD" \
    --role=author

exec php-fpm7.4 -F