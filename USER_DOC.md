# User Documentation

## Services

The stack provides a WordPress website through NGINX over HTTPS. WordPress runs with PHP-FPM, and MariaDB stores the WordPress database. Only NGINX is reachable from the host on port 443.

## Start and stop

From the repository root:

```sh
make       # build images and start the services
make down  # stop and remove the containers
```

The persistent data is kept in `/home/adzahrao/data/` and is not removed by `make down`.

## Access

Add `adzahrao.42.fr` and the VM IP address to `/etc/hosts` if local DNS is not configured. Visit:

- Website: `https://adzahrao.42.fr/`
- Administration: `https://adzahrao.42.fr/wp-admin/`

The TLS certificate is self-signed for local use.

## Credentials

Passwords are kept locally in the ignored `secrets/` directory:

- `pw_root_db.txt`: MariaDB root password
- `ps_database.txt`: WordPress database user password
- `pw_admin.txt`: WordPress administrator password
- `pw_user.txt`: WordPress secondary user password

Do not commit these files. Non-sensitive usernames, database name, domain, and email addresses are configured in `srcs/.env`.

## Check the stack

```sh
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

A healthy stack shows all three containers running. A browser response from the HTTPS URL confirms that NGINX and WordPress are reachable.
