# Developer Documentation

## 1. Virtual Machine Setup

### 1.1 Choices
- **Hypervisor:** Oracle VirtualBox (installed on the campus computers).
- **VM operating system:** Debian 13 "trixie" (stable), file `debian-13.7.0-amd64-netinst.iso` from debian.org.
- **Why Debian:** widely documented, glibc-based (software behaves as documented), easier to debug than Alpine.
- **Storage:** VM files are kept in the shared campus storage (`sgoinfre`) to avoid filling the home quota.
- **Containers' base image:** the penultimate stable Debian release (`bookworm`), never the `latest` tag.

### 1.2 Required software
The project runs inside a virtual machine with Linux and:
- `sudo`, `make` and `git`
- Docker Engine and the Docker Compose plugin
  (official guide: https://docs.docker.com/engine/install/debian)

Check the installation:
```
docker --version
docker compose version
```
Your user must be able to run Docker without `sudo`
(`sudo usermod -aG docker $USER`, then log out and log in again).

### 1.3 Host configuration
These items live on the machine, not in the repository, so they must be created on
every new VM:
```
mkdir -p ~/data/mariadb ~/data/wordpress
echo "127.0.0.1 <login>.42.fr" | sudo tee -a /etc/hosts
```
- The data folders hold the two named volumes. Docker needs them to exist, and the
  Makefile also creates them.
- The `/etc/hosts` line makes `<login>.42.fr` point to the VM itself, where NGINX
  listens on port 443.

## 2. Project configuration
### 2.1 Repository layout

```
.
├── Makefile
├── README.md / USER_DOC.md / DEV_DOC.md
├── secrets/                      (ignored by Git)
│   ├── db_root_password.txt
│   ├── db_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── .env                      (ignored by Git)
    ├── .env.example
    └── requirements/
        ├── mariadb/    Dockerfile, conf/, tools/
        ├── nginx/      Dockerfile, conf/, tools/
        └── wordpress/  Dockerfile, conf/, tools/
```
Each service has its own Dockerfile, its configuration in `conf/` and its startup
script in `tools/`. All images are built from `debian:bookworm`.

### 2.2 Environment file
`srcs/.env` is not in Git. Create it from the template and fill in your values:
```
cp srcs/.env.example srcs/.env
```
| Variable | Meaning |
|---|---|
| `DOMAIN_NAME` | `<login>.42.fr`, used in the certificate and the WordPress URL |
| `MYSQL_DATABASE` | Name of the WordPress database |
| `MYSQL_USER` | Database user used by WordPress |
| `LOGIN` | Your login, used by the Makefile and Compose for the data path |
| `WP_TITLE` | Site title (one word) |
| `WP_ADMIN_USER` | WordPress administrator name (must not contain "admin" or "administrator") |
| `WP_ADMIN_EMAIL` | Administrator email (a placeholder address is fine) |
| `WP_USER` / `WP_USER_EMAIL` | Second WordPress user (author role) |

### 2.3 Secrets
Passwords are stored in four files in `secrets/`, each containing only the password.
They are mounted in the containers as Docker secrets (`/run/secrets/<name>`).
| File | Used by |
|---|---|
| `db_root_password.txt` | MariaDB root account (init script) |
| `db_password.txt` | Database user (init script and WordPress) |
| `wp_admin_password.txt` | WordPress administrator (WordPress init script) |
| `wp_user_password.txt` | Second WordPress user (WordPress init script) |

`srcs/.env` and `secrets/` are listed in `.gitignore`, so no password reaches the
repository. Check it with:
```
git status                                       # neither must be listed
git check-ignore -v srcs/.env secrets/db_password.txt
```
On a new machine these files must be created by hand before running `make`.

## 3. Build and launch

From the repository root:
```
make
```
The Makefile reads `LOGIN` from `srcs/.env`, creates the data folders, and runs
`docker compose -f srcs/docker-compose.yml up -d --build`.

Startup sequence:
1. The three images (`mariadb:inception`, `wordpress:inception`, `nginx:inception`) are built.
2. MariaDB starts. If its data folder is empty, `init-db.sh` creates the database and
   users. A healthcheck reports when it is ready.
3. WordPress starts after MariaDB is healthy. If `wp-config.php` does not exist,
   `init-wp.sh` downloads WordPress, creates its configuration, installs the site and
   creates the two users. Then php-fpm runs as PID 1.
4. NGINX starts, creates a self-signed certificate if it is missing, and serves
   HTTPS on port 443 (TLSv1.2 / TLSv1.3).

| Target | Action |
|---|---|
| `make` / `make up` | Create data folders, build and start |
| `make start` / `make stop` | Resume / stop the containers without removing them |
| `make down` | Remove containers and network (data is kept) |
| `make clean` | Also remove volumes and images (the data in `~/data` is kept) |
| `make fclean` | `clean`, then empty the data folders (uses `sudo`) |
| `make re` | `fclean`, then `make` |
| `make ps` / `make logs` | Show status / logs |

## 4. Managing containers and volumes
```
docker compose -f srcs/docker-compose.yml ps               # status
docker compose -f srcs/docker-compose.yml logs <service>   # logs of one service
docker exec -it <container> bash                           # shell inside a container
docker images                                              # built images
docker volume ls                                           # srcs_mariadb_data, srcs_wordpress_data
docker volume inspect srcs_mariadb_data                    # shows the host folder
docker network ls                                          # srcs_inception
docker network inspect srcs_inception                      # containers on the network
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' nginx   # restart policy (always)
```
Useful checks:
```
docker exec wordpress wp user list --allow-root --path=/var/www/html
docker exec -it mariadb mariadb -u <MYSQL_USER> -p <MYSQL_DATABASE>
```

## 5. Where the data is stored and how it persists

| Data | Path in the container | Named volume | Path on the host |
|---|---|---|---|
| Database | `/var/lib/mysql` | `mariadb_data` | `/home/<login>/data/mariadb` |
| WordPress files | `/var/www/html` (WordPress and NGINX) | `wordpress_data` | `/home/<login>/data/wordpress` |

Both are Docker **named volumes**. Their `driver_opts` (`type: none`, `o: bind`)
make Docker store the data in the host folders above.

- The data **survives** `make stop`, `make down`, `make clean` and rebuilding the images.
- The data is **erased** by `make fclean` and `make re`.
- The setup scripts configure the database and WordPress only when the data is missing
  (no database folder / no `wp-config.php`). So after a rebuild with the data kept,
  the site and its passwords stay as they were.
- The TLS certificate lives inside the NGINX container, so it is regenerated when the
  container is recreated.
