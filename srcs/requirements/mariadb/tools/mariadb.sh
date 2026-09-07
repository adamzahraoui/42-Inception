#!/bin/bash
set -e

MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

mysqld_safe &
until mariadb-admin ping --silent; do
    sleep 1
done

if mariadb -e "SELECT 1" >/dev/null 2>&1; then
    mariadb_root() { mariadb "$@"; }
else
    mariadb_root() { mariadb -uroot -p"$MYSQL_ROOT_PASSWORD" "$@"; }
fi

mariadb_root -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"
mariadb_root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
mariadb_root -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
mariadb_root -e "ALTER USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
mariadb_root -e "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';"
mariadb_root -e "FLUSH PRIVILEGES;"

mysqladmin -uroot -p"$MYSQL_ROOT_PASSWORD" shutdown
exec mariadbd --user=mysql --console