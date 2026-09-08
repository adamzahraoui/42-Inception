# Inception

> A complete WordPress infrastructure built with Docker Compose.

This project is part of the 42 Inception curriculum. It runs a WordPress stack inside a Linux virtual machine using three dedicated Docker containers: NGINX, WordPress with PHP-FPM, and MariaDB.

It demonstrates container isolation, private networking, HTTPS termination, persistent storage, Docker secrets, and repeatable service initialization.

## Architecture

```text
Browser -- HTTPS:443 --> NGINX -- FastCGI:9000 --> WordPress/PHP-FPM
                                                     |
                                             MariaDB:3306
```

All services share the private `inception` bridge network. Only NGINX publishes a host port.

| Service | Responsibility | Public port |
| --- | --- | --- |
| `nginx` | HTTPS, static files, WordPress routing, and PHP-FPM proxying | `443` |
| `wordpress` | WordPress files, WP-CLI initialization, and PHP-FPM | None |
| `mariadb` | WordPress database and database users | None |

### Request flow

1. The browser resolves `adzahrao.42.fr` to the VM.
2. NGINX accepts HTTPS on port `443`.
3. NGINX serves static files or routes requests to `index.php`.
4. PHP requests are sent to `wordpress:9000` through FastCGI.
5. WordPress connects to `mariadb:3306` using Docker internal DNS.

## Project Structure

```text
.
├── Makefile
├── README.md
├── DEV_DOC.md
├── USER_DOC.md
├── secrets/                 # ignored password files
└── srcs/
    ├── .env                 # non-sensitive configuration
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/         # image, config, and entrypoint
        ├── nginx/           # HTTPS image and virtual host
        └── wordpress/       # PHP-FPM image and WP-CLI entrypoint
```

## Requirements

- Linux virtual machine.
- Docker Engine and Docker Compose v2 (`docker compose`).
- `make` and permission to run Docker commands.
- A hostname pointing to the VM IP. This project uses `adzahrao.42.fr`.

```sh
docker --version
docker compose version
make --version
```

## Configuration

### Non-sensitive variables

`srcs/.env` contains the domain, database name and user, and the initial WordPress users:

| Variable | Purpose |
| --- | --- |
| `DOMAIN_NAME` | WordPress URL and NGINX server name |
| `MYSQL_DATABASE` | Database created for WordPress |
| `MYSQL_USER` | Database user used by WordPress |
| `WP_ADMIN_USER`, `WP_ADMIN_EMAIL` | Initial administrator |
| `WP_USER`, `WP_USER_EMAIL` | Initial secondary user |

The current configuration uses `adzahrao.42.fr`, the `wordpress` database, and `wordpress_user`.

### Password secrets

Create one password per file. Use private values and never commit them:

```sh
mkdir -p secrets
printf '%s\n' 'choose-a-database-password' > secrets/ps_database.txt
printf '%s\n' 'choose-a-root-password' > secrets/pw_root_db.txt
printf '%s\n' 'choose-an-admin-password' > secrets/pw_admin.txt
printf '%s\n' 'choose-a-user-password' > secrets/pw_user.txt
chmod 600 secrets/*
```

Compose mounts these files inside containers under `/run/secrets/` as `db_password`, `db_root_password`, `wp_admin_password`, and `wp_user_password`. Passwords are not stored in Dockerfiles or `.env`.

## Installation

1. Clone the repository and enter its directory.
2. Create the four secret files above.
3. Add the VM address to `/etc/hosts` if local DNS is not configured:

   ```text
   <VM_IP> adzahrao.42.fr
   ```

4. Build and start the stack:

   ```sh
   make
   ```

5. Check the containers:

   ```sh
   docker compose -f srcs/docker-compose.yml ps
   ```

6. Open the website at <https://adzahrao.42.fr/> or the administration panel at <https://adzahrao.42.fr/wp-admin/>.

The NGINX image generates a 365-day self-signed certificate for `adzahrao.42.fr`; a browser warning is expected locally.

## Operations

| Command | Effect | Data impact |
| --- | --- | --- |
| `make` | Creates host directories, builds images, and starts the stack | Preserves data |
| `make down` | Stops and removes containers | Preserves volumes and data |
| `make clean` | Removes containers, images, volumes, and host data | Destructive |
| `make fclean` | Alias for `make clean` | Destructive |
| `make re` | Cleans, then rebuilds and starts | Destructive |

The first startup can take longer while MariaDB becomes ready. The entrypoints are repeatable: MariaDB creates or updates its database and users; WordPress downloads core, creates `wp-config.php`, installs the site, and creates the secondary user only when needed.

Useful commands:

```sh
# Validate Compose without starting services
docker compose -f srcs/docker-compose.yml config --quiet

# Inspect status and logs
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress
docker compose -f srcs/docker-compose.yml logs -f mariadb

# Test HTTPS from the VM; -k accepts the local self-signed certificate
curl -kI https://adzahrao.42.fr/
```

## Services

### NGINX

NGINX terminates HTTPS, supports TLS 1.2 and 1.3, serves `/var/www/html`, routes WordPress URLs to `index.php`, and forwards PHP files to `wordpress:9000`. It runs in the foreground so Docker can supervise it.

### WordPress and PHP-FPM

The image installs PHP 8.2-FPM and the MySQL, cURL, GD, internationalization, and multibyte extensions, plus WP-CLI. The entrypoint waits for MariaDB through repeated configuration attempts, installs WordPress, creates the configured `author` user, and starts `php-fpm8.2 -F`.

### MariaDB

The entrypoint reads secrets, starts a temporary server, waits for readiness, creates the database, sets the root password, creates or updates the WordPress user, grants its privileges, and starts `mariadbd` in the foreground.

## Persistence and Networking

| Volume | Container path | Host path | Contents |
| --- | --- | --- | --- |
| `mariadb_data` | `/var/lib/mysql` | `/home/adzahrao/data/mariadb` | Database files |
| `wordpress_data` | `/var/www/html` | `/home/adzahrao/data/wordpress` | Core, themes, plugins, uploads, and config |

Named volumes preserve state when containers are removed. `make down` keeps this state; `make clean` explicitly removes it.

The `inception` bridge network provides service-name DNS. NGINX reaches `wordpress:9000` and WordPress reaches `mariadb:3306`. PHP-FPM and MariaDB have no host port mappings.

## Security

- Passwords use ignored Docker secret files rather than normal environment variables.
- Host traffic enters through HTTPS only.
- MariaDB and PHP-FPM are not exposed on host ports.
- The self-signed certificate is suitable for local learning, not public production.
- Protect secrets with `chmod 600 secrets/*`; never put them in commits or logs.

For public production use, replace the certificate, review container privileges, pin dependencies, add backups, and apply a complete hardening policy.

## Troubleshooting

### The domain does not resolve

Run `getent hosts adzahrao.42.fr`. If it returns nothing, add the VM IP and hostname to `/etc/hosts` or configure local DNS.

### A container exits or restarts

Check status and logs:

```sh
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs --tail=100 nginx
docker compose -f srcs/docker-compose.yml logs --tail=100 wordpress
docker compose -f srcs/docker-compose.yml logs --tail=100 mariadb
```

Common causes are missing secret files, wrong permissions, or Docker being unable to access `/home/adzahrao/data/`.

### WordPress cannot connect to MariaDB

Confirm that MariaDB is running, `.env` values match the intended database and user, `secrets/ps_database.txt` exists, and both services are on the `inception` network.

### Changes to `.env` or secrets do not appear

Existing `wp-config.php` and database data are persistent. Changing input values does not rewrite an existing installation. Use `make re` for a clean reset, knowing that it deletes all project data.

## Resetting the Project

Restart while preserving data:

```sh
make down
make
```

Start completely from zero:

```sh
make re
```

`make clean` and `make re` remove images, Compose volumes, and both host data directories. Back up anything important first.

## Technical Choices

| Decision | Reason |
| --- | --- |
| One service per container | Clear ownership and independent lifecycles |
| Debian Bookworm | Predictable package base for all images |
| NGINX plus PHP-FPM | Separates HTTPS/static delivery from PHP execution |
| Compose secrets | Keeps passwords out of images and `.env` |
| Named volumes with host-backed storage | Preserves state while using Docker volume management |
| User-defined bridge network | Private traffic and service-name DNS |

## Learning Resources

- [Docker Compose](https://docs.docker.com/compose/)
- [Docker volumes](https://docs.docker.com/engine/storage/volumes/)
- [Docker Compose secrets](https://docs.docker.com/compose/how-tos/use-secrets/)
- [NGINX](https://nginx.org/en/docs/)
- [PHP-FPM](https://www.php.net/manual/en/install.fpm.php)
- [WP-CLI](https://developer.wordpress.org/cli/commands/)

Created as part of the 42 curriculum by `adzahrao`.
