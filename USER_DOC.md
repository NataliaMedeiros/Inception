# User documentation

This document explains, for an end user or administrator, how to use the Inception, what it provides, how to start and stop it, how to reach the website, where the credentials are and how to check that everything works.

Replace `<login>` with your 42 login everywhere below.

## 1. Services provided

The project runs three services, each in its own Docker container, connected by a private Docker network.

| Service | Role | Reachable from outside? |
|---|---|---|
| NGINX | Web server and the only entry point. Accepts HTTPS on port 443 (TLSv1.2 / TLSv1.3 only) | Yes, port 443 |
| WordPress + php-fpm | Runs the WordPress website. | No, internal only (port 9000) |
| MariaDB | Database that stores the WordPress content and users | No, internal only (port 3306) |

## 2. Start and stop the project

All commands are run from the root of the repository.

### Start

1. Start the virtual machine dedicated to this project.
2. After cloning the Git repository, create the environment file from the template and fill in the values (domain name, database name, usernames and emails):
```
   cp srcs/.env.example srcs/.env
```
3. Create the four secret files in the `secrets/` folder, each containing only a password (see section 4, "Locate and manage credentials").
4. On a new machine only: make sure the domain points to the VM. `/etc/hosts` must contain the line `127.0.0.1 <login>.42.fr`. If it is missing, add it with:
```
   echo "127.0.0.1 <login>.42.fr" | sudo tee -a /etc/hosts
```
5. Build and start the project:
```
   make
```
6. Open `https://<login>.42.fr` in a browser. Accept the certificate warning to see the website.

### Stop

- `make stop`: stops the containers without removing them.
- `make start` brings them back.
- `make down`: stops and removes the containers and the network. The data is kept.
- `make clean`: like `down`, and also removes the Docker volumes and images. The data in `/home/<login>/data` is kept.
- `make fclean`: like `clean`, and also erases the stored data (the website and the database). It asks for the sudo password. This is a full reset.

### All commands

| Command | Action |
|---|---|
|`make`| Build the images and start everything |
|`make stop`| Stop the containers without removing them |
|`make start`| Start them again |
|`make down`| Remove containers and network (data is kept) |
|`make clean`| Remove containers, network, volumes and images (data is kept) |
| `make fclean`| Remove everything, including the stored data |
| `make re`| Rebuild from scratch (erases the data) |
| `make ps`| Show the status of the containers |
| `make logs`| Show the logs |

If a container crashes, Docker restarts it automatically.

The first start can take a few minutes: the images are built, and WordPress waits for the database to be ready before installing itself.

## 3. Access the website and the administration panel

- **Website:** `https://<login>.42.fr`
- **Administration panel:** `https://<login>.42.fr/wp-admin`

The site uses a self-signed TLS certificate, so the browser shows a security warning. This is expected: accept the risk and continue. The warning can come back after the containers are rebuilt, because a new certificate is generated. Plain HTTP (port 80) is not available.

WordPress has two users:

- the **administrator**, who can manage the whole site;
- a **regular user** with the author role, who can write and publish posts.

Their usernames are defined in `srcs/.env`.

## 4. Locate and manage credentials

Credentials are **not** stored in the Git repository. They live in local files that Git ignores, and you must create them on each new machine.

| File | Content |
|---|---|
| `secrets/db_root_password.txt` | Password of the MariaDB root user |
| `secrets/db_password.txt` | Password of the WordPress database user |
| `secrets/wp_admin_password.txt` | Password of the WordPress administrator |
| `secrets/wp_user_password.txt` | Password of the second WordPress user (author) |
| `srcs/.env` | Configuration values: domain name, database name, usernames, emails |

On a new machine, create `srcs/.env` from the template (`cp srcs/.env.example srcs/.env`), fill in your values, and create the four secret files by hand. Each file contains only the password.

To change a password:

- **A WordPress user:** change it in the dashboard (Users > Profile). The content is kept.
- **From scratch:** edit the file in `secrets/` and run `make re`. This erases the website and the database, because the passwords are stored in the database and are only set the first time it starts.

Never commit these files, never paste them in chat tools and never share them.

## 5. Check that the services are running

1. **List the containers.** The three containers (`nginx`, `wordpress`, `mariadb`) must have the status `Up` (MariaDB shows `healthy`):
```
   make ps
```
2. **Check the website answers over HTTPS** (the `-k` option accepts the self-signed certificate):
```
   curl -k -I https://<login>.42.fr
```
   A `200` or `301/302` response means NGINX and WordPress are working.

3. **Check that plain HTTP is closed** (this must fail with "connection refused"):
```
   curl -I http://<login>.42.fr
```
4. **Read the logs of a service** if something looks wrong:
```
   docker logs nginx
   docker logs wordpress
   docker logs mariadb
```
5. **Check the data on the host** (files must exist in both folders):
```
   ls -la ~/data/mariadb ~/data/wordpress
```
6. **Check in the browser:** open the website, log in to `/wp-admin` with each user, and create a test post.
