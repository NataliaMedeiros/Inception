*This project has been created as part of the 42 curriculum by nmedeiro.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. The goal is to set up a small web infrastructure with **Docker Compose**, inside a **virtual machine**, where every service runs in its own container and every image is built from our own Dockerfile.

The stack is made of:

- **NGINX**: the only entrypoint of the infrastructure, reachable on port 443 with TLSv1.2 or TLSv1.3 only.
- **WordPress + php-fpm**: the website and the PHP engine that runs it (no NGINX inside this container).
- **MariaDB**: the database used by WordPress (no NGINX inside this container).
- **Two named volumes**: one for the WordPress database and one for the WordPress website files, both stored in `/home/<login>/data` on the host.
- **A Docker network** connecting the containers.

The website is available at `https://nmedeiro.42.fr`.

## Instructions

### Prerequisites

- A virtual machine running Linux, with `docker`, `docker compose` and `make` installed.
- The domain name pointing to the local IP address. Add this line to `/etc/hosts` (replace the IP and the login):

```
127.0.0.1   <login>.42.fr
```

### Configuration

1. Create `srcs/.env` from the template and fill in your values (domain name, database name, usernames, emails):
```bash
   cp srcs/.env.example srcs/.env
```
2. Create the `secrets/` folder with four files, each containing only a password:
   `db_root_password.txt`, `db_password.txt`, `wp_admin_password.txt` and `wp_user_password.txt`.
3. `.env` and `secrets/` are ignored by Git. Never commit them.

See [DEV_DOC.md](DEV_DOC.md) for the full setup of the virtual machine.

### Build and run

```bash
make          # create the data folders, build the images and start the stack
make stop     # stop the containers without removing them
make start    # start them again
make down     # remove the containers and the network (data is kept)
make clean    # also remove the volumes and images (data in /home/<login>/data is kept)
make fclean   # clean, then erase the stored data (asks for the sudo password)
make re       # fclean, then rebuild everything
make ps       # status of the containers
make logs     # logs of the containers
```

Then open `https://<login>.42.fr` in a browser. The browser will warn about the
self-signed certificate: accept it to continue.

### More documentation

- [USER_DOC.md](USER_DOC.md): how to use and administer the stack.
- [DEV_DOC.md](DEV_DOC.md): how to set up, build and maintain the project as a developer.

## Project Description

### Use of Docker and project sources

Docker is used to run each service in an isolated container. The project is organized as follows:

.
├── Makefile                  # builds and starts everything through docker compose
├── README.md
├── USER_DOC.md               # user documentation
├── DEV_DOC.md                # developer documentation
├── .gitignore                # keeps secrets/ and srcs/.env out of Git
├── secrets/                  # passwords (ignored by Git)
└── srcs/
    ├── docker-compose.yml    # services, network and volumes
    ├── .env                  # non-sensitive variables (ignored by Git)
    ├── .env.example          # template for .env (committed)
    └── requirements/
        ├── mariadb/          # Dockerfile, conf/, tools/
        ├── nginx/            # Dockerfile, conf/, tools/
        └── wordpress/        # Dockerfile, conf/, tools/

- Each service has its **own Dockerfile**, and each image has the same name as its service.
- The Makefile calls `docker compose`, which builds the images from these Dockerfiles and starts the containers.
- No ready-made images are pulled, except the Alpine/Debian base image.

### Main design choices

- **Base image:** `debian:bookworm` (Debian 12), the penultimate stable release, as required by the subject. The `latest` tag is never used.
- **Why Debian:** it is widely documented, uses glibc so software behaves as documented, and is easier to debug than Alpine for a beginner.
- **PID 1:** every service runs in the foreground as PID 1 (via `exec` in the entrypoint script). No `tail -f`, `sleep infinity`, `while true` or `bash` hacks.
- **Restart policy:** containers restart automatically if they crash.
- **Single entrypoint:** only NGINX publishes a port (443). WordPress and MariaDB are only reachable inside the Docker network.
- **Credentials:** non-sensitive values in `.env`, passwords in Docker secrets. No password appears in any Dockerfile.
- **WordPress users:** two users, one of them an administrator whose name does not contain "admin" or "administrator".

#### Debian vs Alpine

| | Debian | Alpine |
|---|---|---|
| Type | General-purpose, one of the oldest and most stable | Minimal, built for small size and security |
| C library | glibc | musl |
| Package manager | `apt` | `apk` |
| Shell | bash available | BusyBox, `/bin/sh` |
| Image size | Larger, slower builds | Tiny, fast builds and pulls |
| Attack surface | Larger (more packages) | Smaller |
| Compatibility | Software behaves as expected, most tutorials match | Rare musl compatibility or performance bugs, different commands and paths |
| Debugging | Easier, more tools | Harder for beginners |

### Comparisons

#### Virtual Machines vs Docker

**Virtualization** is a technique that allows running multiple environments on a single physical server. It is mainly done with virtual machines or containers.

A **virtual machine** virtualizes the *hardware*. A **hypervisor** allocates resources such as CPU cores and storage to each VM, and each VM runs its own operating system, applications and dependencies. Because of this, VMs use more CPU and RAM and take longer to start. In return, they offer stronger isolation: a security threat in one VM does not affect another. VMs are a good fit for legacy applications that need old operating systems, multi-OS environments and security-critical workloads.

A **container** virtualizes at the *operating system* level. Containers do not have their own OS: they share the host kernel and only package the application and its dependencies. This makes them lightweight, fast to start (seconds) and very portable, so they can move between development, testing and production with minimal effort. They fit microservices architectures and CI/CD pipelines well. **Docker** is the most widely used platform to build and run containers.

The two can be combined: running containers inside VMs adds an isolation layer, gives more control over resource allocation, and makes scaling and deployment easier. This is the setup of this project.

| | Virtual Machine | Docker container |
|---|---|---|
| Virtualizes | Hardware | Operating system (shared kernel) |
| Has its own OS | Yes | No |
| Startup time | Slow | Seconds |
| Resource usage | High | Low |
| Isolation | Very strong | Weaker (shared kernel) |
| Portability | Heavy | Very portable |

#### Secrets vs Environment Variables

| | Environment variables | Docker secrets |
|---|---|---|
| Defined in | `.env` file or `environment:` in Compose | Files in `secrets/`, declared in Compose |
| Visibility | Visible with `docker inspect` and in the process environment | Mounted as files in `/run/secrets/<name>`, only inside the services that need them |
| Best for | Non-sensitive configuration (domain name, database name, usernames) | Passwords and confidential data |

In this project, non-sensitive settings are in `.env` and passwords are in secrets. Neither is committed to Git.

#### Docker Network vs Host Network

| | Docker (bridge) network | Host network |
|---|---|---|
| Isolation | Containers get their own network namespace | Container shares the host network stack |
| Name resolution | Containers reach each other by service name | No service-name DNS between containers |
| Port exposure | Only explicitly published ports | Every port the process opens is exposed on the host |
| In this project | **Used** (custom network in `docker-compose.yml`) | **Forbidden** (`network: host`, `links`) |

#### Docker Volumes vs Bind Mounts

| | Docker named volume | Bind mount |
|---|---|---|
| Managed by | Docker | The user (any host path) |
| Portability | High, independent of the host folder layout | Depends on the host path existing |
| In this project | **Required** for the database and the WordPress files, with data stored in `/home/<login>/data` | Not allowed for these two storages |
The two named volumes are declared with `driver_opts` (`type: none`, `o: bind`, `device: /home/<login>/data/...`), so Docker manages them as named volumes while the data is physically stored in the required host folder.

## Concepts Explained

### Images

A **container image** is a standardized package that includes all the files, binaries, libraries and configuration needed to run a container. An image is **immutable**: once created, it cannot be modified, but you can build a new image on top of an existing one.

- **Image** = the template.
- **Container** = a running instance of an image.

Public images are stored and distributed through registries such as Docker Hub, the default global marketplace with over 100,000 images. In this project, pulling ready-made images is forbidden (only the Alpine/Debian base is allowed), so every service image is built from our own Dockerfile.

### Layers

An image is composed of **layers**. Each layer is a read-only snapshot of the filesystem changes (additions, deletions, modifications) made by one Dockerfile instruction. For example:

```dockerfile
FROM debian:bookworm          # layer 1: the Debian files
RUN apt install -y nginx      # layer 2: files added by the nginx install
COPY nginx.conf /etc/nginx/   # layer 3: our config file
```

Only `FROM`, `RUN`, `COPY` and `ADD` create filesystem layers. `EXPOSE`, `ENV`, `ENTRYPOINT` and `CMD` only add metadata.

When a container starts, Docker adds one thin **writable layer** on top of the read-only layers. It is the only place the container can write, and it is deleted with the container. This is why persistent data needs **volumes**.

Layers are useful for:

- **Build cache.** If only `nginx.conf` changes, Docker reuses layers 1 and 2 and rebuilds only layer 3. This is why rarely-changing instructions (installing packages) come *before* frequently-changing ones (copying files).
- **Sharing.** Images starting from the same base share its layers on disk, and containers from the same image share all read-only layers.
- **Smaller transfers.** Pulling an image downloads only the layers you do not already have.

### Dockerfile and `docker build`

A **Dockerfile** is the recipe that builds an image.

| Instruction | What it does |
|---|---|
| `FROM` | Sets the base image. It is the first instruction. |
| `RUN` | Executes a command **at build time** and saves the result as a new layer (e.g. installing packages). |
| `COPY` | Copies files from the build context into the image. |
| `EXPOSE` | Documents the port the container listens on. Metadata only: it does **not** publish the port. Publishing is done with `ports:` in Compose. |
| `ENTRYPOINT` | The main executable, the fixed part of the start command. Runs **at container start**. |
| `CMD` | Default arguments for `ENTRYPOINT`, or the default command if there is no `ENTRYPOINT`. Easy to override from `docker run` or Compose `command:`. |

`docker build` is the command that builds an image from a Dockerfile:

```bash
docker build -t mariadb:inception ./requirements/mariadb
```

It reads the Dockerfile, executes the instructions in order (`FROM`, `RUN`, `COPY`, ...), creates one layer per instruction and delivers the finished image. The folder passed to the command is the **build context**. In this project the build is not run by hand: Docker Compose does it, called by the Makefile.

### Docker Compose

`docker-compose.yml` describes the whole application in one file: the **services** (nginx, wordpress, mariadb), the **networks** and the **volumes**. The Makefile uses it to build the images and start the containers.

### PID 1 and foreground processes

The first process of a container (PID 1) *is* the container: when it exits, the container stops. So the main service must run **in the foreground** as PID 1. Hacks like `tail -f`, `sleep infinity`, `while true` or a bare `bash` only keep the container alive artificially while the real service may be dead or running in the background, so they are forbidden. An entrypoint script should end with `exec <service in foreground>`, so the service replaces the shell, becomes PID 1 and receives signals correctly (for example from `docker stop`).

### The services

#### MariaDB

MariaDB is a **relational database management system (RDBMS)** that you talk to using **SQL** (Structured Query Language). It is a fork of MySQL, which is why many commands and config names still say `mysql` (the `mysql` user, `/var/lib/mysql`, `MYSQL_USER`).

- **Relational:** data is stored in tables with rows and columns, and tables can be linked to each other.
- **SQL:** the language used to create, read, change and delete data, for example `CREATE DATABASE`, `SELECT`, `INSERT`.
- **Server:** MariaDB runs as a program that listens on **port 3306**. Clients (like WordPress) connect to it over the network and send SQL commands.

#### WordPress

WordPress is a website system written in **PHP**. PHP code does not run by itself on a web page: something has to execute it and return the resulting HTML.

#### php-fpm

**php-fpm** (FastCGI Process Manager) is the program that executes PHP code. It runs as a service, waits for requests on **port 9000**, runs the requested PHP file and sends the result back.

#### NGINX and TLS

**NGINX** is the web server and the only entrypoint of the infrastructure. It terminates TLS on port 443, serves static files, and forwards PHP requests to php-fpm using the FastCGI protocol.

**TLS** encrypts the connection between the browser and the server. A **self-signed certificate** is signed by ourselves instead of by a trusted Certificate Authority: it provides encryption, but browsers show a warning because the identity is not verified by a third party.

### How the services work together

```
Browser --HTTPS (443, TLSv1.2/1.3)--> NGINX
                                        |
                                FastCGI (port 9000)
                                        v
                              WordPress + php-fpm
                                        |
                                SQL (port 3306)
                                        v
                                     MariaDB
```

## Resources

### Documentation and articles

### Documentation and articles

**Docker and containers**
- Docker Docs, *Dockerfile reference*: https://docs.docker.com/reference/dockerfile/
- Docker Docs, *Docker Compose*: https://docs.docker.com/compose/
- Docker Docs, *What is an image?*: https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-an-image/
- Docker Docs, *Understanding image layers*: https://docs.docker.com/get-started/docker-concepts/building-images/understanding-image-layers/
- DataCamp, *Containers vs Virtual Machines*: https://www.datacamp.com/blog/containers-vs-virtual-machines

**Services**
- NGINX Documentation: https://nginx.org/en/docs/
- MariaDB Documentation: https://mariadb.com/kb/en/documentation/
- WP-CLI Commands: https://developer.wordpress.org/cli/commands/
- WordPress Hosting Handbook, *Server environment*: https://github.com/WordPress/hosting-handbook/blob/main/server-environment.md
- WordPress Hosting Team, *Server environment: PHP extensions*: https://make.wordpress.org/hosting/handbook/server-environment/#php-extensions

**Debian**
- Debian Releases (stable and oldstable): https://www.debian.org/releases/

### Use of AI

AI was used to help me to understand some concepts that I was still in doubt, to debug errors, and to review the documentation.
