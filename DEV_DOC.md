# Developer Documentation

## Prerequisites

Use a Linux virtual machine with Docker Engine and Docker Compose v2. The learner domain must resolve to the VM IP. This repository is configured for the login `adzahrao` and the domain `adzahrao.42.fr`.

## Configuration and secrets

1. Keep the non-sensitive variables in `srcs/.env`.
2. Create the four ignored files in `secrets/`:
   - `ps_database.txt`
   - `pw_root_db.txt`
   - `pw_admin.txt`
   - `pw_user.txt`
3. Put one password in each file and protect them with restrictive permissions, for example `chmod 600 secrets/*`.
4. Ensure `/home/adzahrao/data/mariadb` and `/home/adzahrao/data/wordpress` can be used by Docker.

Compose mounts the password files as Docker secrets under `/run/secrets/`. Passwords are not stored in Dockerfiles or `srcs/.env`.

## Build and launch

```sh
make
```

The Makefile invokes `srcs/docker-compose.yml`, builds each image locally, creates the named volumes, and starts the three services in detached mode.

Useful commands:

```sh
docker compose -f srcs/docker-compose.yml config --quiet
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs -f nginx
docker compose -f srcs/docker-compose.yml restart wordpress
make down
make clean
```

## Services and networking

The `nginx`, `wordpress`, and `mariadb` services use the `inception` bridge network. NGINX publishes only port 443. It reaches PHP-FPM at `wordpress:9000`, while WordPress reaches MariaDB at `mariadb:3306`.

Each service has its own Dockerfile under `srcs/requirements/`. Entrypoint scripts launch the actual foreground daemon. WordPress initialization checks whether WordPress is already installed, so container restarts do not create duplicate users.

## Persistent data

The named volumes are:

- `mariadb_data`, mounted at `/var/lib/mysql` and stored on the host under `/home/adzahrao/data/mariadb`.
- `wordpress_data`, mounted at `/var/www/html` and stored on the host under `/home/adzahrao/data/wordpress`.

`make down` preserves these volumes. `make clean` removes the Compose volumes and clears the host directories, so it is destructive for project data.
