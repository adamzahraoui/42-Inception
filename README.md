*This project has been created as part of the 42 curriculum by adzahrao.*

# Inception

## Description

Inception is a small WordPress infrastructure built with Docker Compose inside a virtual machine. It contains three dedicated services:

- **NGINX**: the only public entry point, exposed on HTTPS port 443 with TLS 1.2 and TLS 1.3.
- **WordPress**: WordPress with PHP-FPM, without NGINX.
- **MariaDB**: the WordPress database, without NGINX.

The images are built locally from Debian Bookworm Dockerfiles. Services communicate over a private bridge network. WordPress files and the MariaDB database use Docker named volumes backed by `/home/adzahrao/data/` on the host.

### Main design choices

- One service per container keeps responsibilities isolated.
- NGINX terminates TLS and forwards PHP requests to PHP-FPM.
- Docker secrets store passwords; `.env` stores non-sensitive configuration.
- Named volumes preserve application data independently from container lifecycles.
- The services use a user-defined Docker bridge network instead of host networking.

### Comparisons

| Choice | Project approach | Reason |
| --- | --- | --- |
| Virtual machine vs Docker | Docker containers run inside the required VM | Containers are lighter and isolate processes; the VM provides the required host boundary. |
| Secrets vs environment variables | Passwords use Docker secrets; names and URLs use `.env` | Secrets are mounted as files and are less likely to leak through process inspection or configuration output. |
| Docker network vs host network | User-defined bridge network | Containers get service-name DNS and isolated connectivity without sharing the host network namespace. |
| Docker volumes vs bind mounts | Named volumes with a local driver and host-backed storage | Docker manages the volumes while the required persistent data remains under `/home/adzahrao/data/`. |

## Instructions

### Prerequisites

- A Linux virtual machine
- Docker Engine and Docker Compose v2
- Permission to run Docker commands
- The hostname `adzahrao.42.fr` resolving to the VM IP, for example with `/etc/hosts`

### Start

Create the host storage directories and start the stack:

```sh
make
```

Then open `https://adzahrao.42.fr/`. The certificate is self-signed, so the browser will display a certificate warning during local development.

The WordPress administration panel is available at `https://adzahrao.42.fr/wp-admin/`.

### Stop and clean

```sh
make down       # stop and remove containers
make clean      # remove containers, images, volumes, and stored project data
make re         # clean and rebuild everything
```

## Resources

- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Docker volumes documentation](https://docs.docker.com/engine/storage/volumes/)
- [Docker secrets documentation](https://docs.docker.com/compose/how-tos/use-secrets/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [PHP-FPM documentation](https://www.php.net/manual/en/install.fpm.php)
- [WP-CLI documentation](https://developer.wordpress.org/cli/commands/)

AI was used to compare the implementation with the subject requirements, identify configuration and idempotency issues, and suggest focused documentation and validation steps. All changes were reviewed against the project files and validated with Docker Compose and shell syntax checks.
