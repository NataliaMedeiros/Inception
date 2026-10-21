Starting to understanding the subject and concepts involved

Rules:
- Project need to be done in a virtual machine
- All the files required for the configuration of your project must be placed in a srcs
folder
- Makefile - must set up your entire application (i.e., it has to build the Docker images using
docker-compose.yml).


Mandatory part
Do in a **virtual machine** and use **docker compose**
Each Docker image must have the same name as its corresponding service.
Each service has to run in a dedicated container.

For performance reasons, the containers must be built either from the penultimate stable version of **Alpine or Debian**. The choice is yours


Debian x Alpine

**Debian** is a general-purpose Linux distribution, one of the oldest and most stable. It uses the glibc C library and the apt package manager.

Debian advantages:

Most tutorials and Stack Overflow answers match it
Software behaves as expected (glibc)
Easier debugging, with more tools available

Debian disadvantages:

Bigger images and slower builds
Larger attack surface (more installed packages)

**Alpine** is a minimal Linux distribution built for small size and security. It uses musl (a lighter C library), apk as package manager, and BusyBox for basic tools.

Alpine advantages:

Tiny images, fast builds and pulls
Minimal, so fewer things to attack

Alpine disadvantages:

musl can cause rare compatibility or performance bugs
Different commands and paths from what tutorials show (apk add, /bin/sh instead of bash)
Harder for beginners to troubleshoot


VM X Docker

Virtualization, a technique that allows running multiple environments on a single physical server. Virtualization is primarly implemente using or virtual machine or container.

Virtual Machine
A virtual Machine is a technology that enables virtualization at the hardware level. Each virtual machine acts as a isolated system with it ons opperating system, application and dependencies.This is made possible by “hypervisor” software, which is responsible for allocating hardware resources like CPU cores and storage to each VM.
Since they have their own OS, VMs consumes more resorses including CPU and RAM and have a longer startup time. Overall, VMs provides greater security than containers due to their isolate level (complete isolation because of has it own OS), them a secutirty treat in on VM doesn't affect another VM.
Overall, VMs have more down sides than containers, however it has specific use cases that worth it, including running legacy applications, supporting multi-OS environments, and handling security-critical workloads.

Running legacy applications
VMs are ideal for running legacy applications that require older or outdated operating systems. Since VMs can have their own OS environments, teams can continue using their older applications that may not be compatible with modern operating systems.

Containers
A container is a way of virtualization that operates at system level. Diferently from VM, containers don't have they own operational System, instead they share the host OS, which makes them significantly ligthweight and efficient.
Since container only package application and dependencies, they are much more portable than VMs. This makes moving containers across different environments (e.g., development to production) easy without compromising compatibility. **Docker** is the top platform that developers use to build and run container applications.
Since containers do not need to emulate their own OS, they can start up in seconds. This quick startup time makes containers popular in **Continuous Integration/Continuous Deployment (CI/CD)** pipelines, where speed and efficiency are required.
Conteiners are higly portable dues their ligthweight nature.They can be moved between environments with minimal effort. And, since they are designed to run consistently across different environments, they eliminate compatibility issues.
Containers’ lightweight nature makes them powerful assets in modern software development.
Microservices architecture - Since containers are application-independent, they allow microservices to coexist while ensuring that issues in one service do not impact others. As microservices architecture has gained popularity, engineering teams increasingly rely on containers to deploy their applications.
CI/CD and DevOps pipelines

Portability across environments - Containers make it easy for developers to move code from development to testing to production. They are designed to package applications that run successfully across different systems, which reduces compatibility issues.

Combining containers and VMs
The VMs provide robust isolation that adds a layer of security, reducing the risk of threats to the application. By placing containers in VMs, you can have greater control over resource allocation, making it easier to ensure that each group of containers can access sufficient resources for their application.

Furthermore, this combination makes scaling and handling deployments easier across different environments.

What to study in the sequence:
Image vs container: an image is the template, a container is a running instance.
Dockerfile: what FROM, RUN, COPY, EXPOSE, ENTRYPOINT and CMD do.
Docker Compose: how one docker-compose.yml describes several services, networks and volumes.
PID 1 and foreground processes: why tail -f and sleep infinity are forbidden, and why a daemon must run in the foreground.
Volumes vs bind mounts, Docker network vs host network, secrets vs environment variables. These are also required in your README.
How the three services work together: NGINX → (FastCGI, port 9000) → php-fpm/WordPress → MariaDB (port 3306). TLS and what a self-signed certificate is.

Container imagem
 A container image is a standardized package that includes all of the files, binaries, libraries, and configurations to run a container.
A image is immutable, after created cannot be modified. It is possible use a image create other things over it and them create my image with the combination.
The image contains everything that is need to run a container
Container images are composed of layers. Each layer represents a set of file system changes that add, remove, or modify files.

Finding images
Docker Hub is the default global marketplace for storing and distributing images. It has over 100,000 images created by developers that you can run locally. You can search for Docker Hub images and run them directly from Docker Desktop.

Image layers
Each layer in an imagem add, remove some configuration.
Each layer in an image contains a set of filesystem changes - additions, deletions, or modifications.
Examples:
The first layer adds basic commands and a package manager, such as apt.
The second layer installs a Python runtime and pip for dependency management.
The third layer copies in an application’s specific requirements.txt file.
The fourth layer installs that application’s specific dependencies.
The fifth layer copies in the actual source code of the application.
This is beneficial because it allows layers to be reused between images. For example, imagine you wanted to create another Python application. Due to layering, you can leverage the same Python base. This will make builds faster and reduce the amount of storage and bandwidth required to distribute the images.
Each instruction that changes the filesystem (FROM, RUN, COPY, ADD) creates a new layer on top of the previous one. Instructions like EXPOSE, ENTRYPOINT, CMD, ENV only add metadata (no filesystem change).
An image layer is a saved snapshot of the changes made by one Dockerfile instruction.

How it works: when Docker builds an image, each instruction (FROM, RUN, COPY...) creates a new layer holding only the files that instruction added or changed. The image is all those layers stacked in order.

FROM debian:bookworm          → layer 1: the Debian files
RUN apt install -y nginx      → layer 2: files added by nginx install
COPY nginx.conf /etc/nginx/   → layer 3: your config file

Layers are read-only. When you start a container, Docker adds one thin writable layer on top, and that’s the only place the container can write. Delete the container and that top layer is gone, which is why the data is lost.
What layers are used for:

Build cache. If you change only nginx.conf, Docker reuses layers 1 and 2 from the cache and rebuilds only layer 3. Builds become much faster. This is why you put rarely-changing instructions (installing packages) before frequently-changing ones (copying your files).
Sharing. If three images start FROM debian:bookworm, the Debian layer is stored once on disk and shared. Ten containers from the same image also share all the read-only layers, so they are cheap.
Smaller transfers. When pulling an image, Docker downloads only the layers you don’t already have.

The instructions

FROM: sets the base image. It is always the first instruction and gives you the first layers.
RUN: executes a command at build time and saves the result as a new layer. Used to install packages.
COPY: copies files from your build context (the folder next to the Dockerfile) into the image. New layer.
EXPOSE: documents which port the container listens on. Metadata only. It does not publish the port; publishing is done with ports: in Compose.
ENTRYPOINT and CMD: define what runs at container start (not at build time).

ENTRYPOINT = the main executable, the fixed part of the command.
CMD = default arguments for the ENTRYPOINT, or the default command if there is no ENTRYPOINT. Easy to override from docker run or Compose command:.

Project:
First install virtual machine using virtualBox and debian ISO, dowload at Debian.org

Parte 1: criar a VM

Abra o Oracle VirtualBox Manager e clique em New.
Preencha:
Name: inception
Folder: sua pasta no sgoinfre
ISO Image: escolha o debian-13.7.0-amd64-netinst.iso (provavelmente em Downloads)
Type: Linux
Version: Debian (64-bit)
Marque Skip Unattended Installation
Clique em Next. Em Hardware: Base Memory: 4096 MB e Processors: 2.
Clique em Next. Em Hard Disk: Create a Virtual Hard Disk Now, tamanho 30 GB. Não marque Pre-allocate Full Size.
Clique em Finish e depois em Start.

## Why `secrets/` and `srcs/.env` are in `.gitignore`

The project needs passwords (MariaDB root password, database user password,
WordPress users' passwords) and other configuration values. These must **never**
be committed to the Git repository, so the two places that hold them are
excluded from version control:

```
srcs/.env
secrets/
```

### Reasons
- **Subject requirement:** any credential, API key or password found in the Git
  repository (outside of properly configured secrets) causes the project to fail.
- **Git history is permanent:** a file that is committed once stays in the
  history, even if it is deleted in a later commit. Anyone with access to the
  repository can recover it.
- **Repositories get shared:** the code is read by peers, evaluators and
  possibly recruiters. Passwords are specific to one deployment and are not
  part of the source code.
- **Separation of code and configuration:** the same Dockerfiles and
  `docker-compose.yml` can run on any machine, with different passwords for each
  one.

Parte 2: instalar o Debian
6. No menu azul, escolha Install (modo texto).
7. Select a language: English. Select your location: sua região (Netherlands, ou other > Europe). Configure the keyboard: o layout que você realmente usa.
8. Hostname: seu login. Domain name: deixe vazio.
9. Root password: defina uma senha. Depois, crie seu usuário: Full name e Username com o seu login 42, e uma senha.
10. Partition disks: escolha Guided - use entire disk, selecione o disco, depois All files in one partition (recommended for new users), depois Finish partitioning and write changes to disk, e responda Yes. Não escolha as opções com “encrypted”.
11. Scan extra installation media? No. Package manager: país Netherlands e deb.debian.org. Proxy: deixe vazio. Popularity contest: No.
12. Software selection: marque Xfce, SSH server e standard system utilities. Desmarque GNOME se estiver marcado.
13. Install the GRUB boot loader: Yes, e escolha /dev/sda.
14. Em Installation complete, clique em Continue. A VM reinicia.
15. Se voltar ao instalador, desligue a VM e vá em Settings > Storage, clique no ISO e remova-o.
16. Faça login com seu usuário.
17. Tire um snapshot: Machine > Take Snapshot (ou aba Snapshots no Manager).

## Virtual Machine Setup

### Choices
- **Hypervisor:** Oracle VirtualBox (installed on the campus computers).
- **VM operating system:** Debian 13 "trixie" (stable), `netinst` ISO, amd64.
- **Why Debian:** widely used, so documentation and troubleshooting help are easy to find; uses glibc, so software behaves as documented; easier to debug for beginners than Alpine.
- **Storage:** VM files are stored in the shared campus storage (`sgoinfre`) to avoid filling the home quota.
- **Containers' base image (later):** the penultimate stable Debian release (`bookworm`), never `latest`.

### Steps
1. Download `debian-13.7.0-amd64-netinst.iso` from debian.org.
2. In VirtualBox, click **New** and set:
   - Name: `inception`; Folder: personal folder in `sgoinfre`
   - ISO image: the Debian netinst ISO
   - Type: Linux; Version: Debian (64-bit)
   - Check **Skip Unattended Installation** (so the user, hostname and partitioning are chosen manually)
3. Hardware: Base Memory 4096 MB, 2 processors.
4. Hard disk: new VDI, 30 GB, dynamically allocated (do not pre-allocate).
5. Click **Finish**, then **Start**.
6. In the installer menu, choose **Graphical install**.
7. Language: English. Location: other > Europe > Netherlands. Locale: en_US.UTF-8. Keyboard: American English.
8. Hostname: `<login>`; domain name: empty.
9. Set a root password and create a user named `<login>` with its own password (passwords are not stored in the repository).
10. Partitioning: Guided - use entire disk > All files in one partition (no LVM, no encryption) > Finish partitioning and write changes to disk > Yes.
11. Wait for "Installing the base system".
12. Package manager: no extra installation media, country Netherlands, mirror `deb.debian.org`, no proxy.
13. Package usage survey: No.
14. Software selection: Xfce desktop, SSH server, standard system utilities.
15. Install GRUB on `/dev/sda`.
16. Reboot, remove the ISO from the VM storage settings if the installer restarts, and log in.
17. Take a VM snapshot of the clean installation.

## 2. Preparing the VM

### 2.1 Base tools and sudo
```
su -
apt update && apt install -y sudo make git curl ca-certificates
usermod -aG sudo <login>
exit
```
Log out and log in again (group changes only apply to new sessions), then check:
```
sudo whoami        # must print: root
```

### 2.2 Installing Docker Engine and Docker Compose
Based on the official guide: https://docs.docker.com/engine/install/debian

1. Add Docker's GPG key:
```
sudo apt update
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
ls -l /etc/apt/keyrings/docker.asc     # check: -rw-r--r--, about 3.8 KB
```
2. Add Docker's repository (one-line version, because pasting multi-line text into the VM was not possible):
```
printf 'Types: deb\nURIs: https://download.docker.com/linux/debian\nSuites: trixie\nComponents: stable\nSigned-By: /etc/apt/keyrings/docker.asc\n' | sudo tee /etc/apt/sources.list.d/docker.sources
cat /etc/apt/sources.list.d/docker.sources   # check: 5 lines, "Suites: trixie"
sudo apt update
apt-cache policy docker-ce                    # check: Candidate is a version number, not (none)
```
3. Install Docker:
```
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
4. Use Docker without sudo, then log out and log in again:
```
sudo usermod -aG docker $USER
```
5. Verify:
```
docker --version            # Docker version 29.9.1
docker compose version      # Docker Compose version v5.6.0
docker run hello-world      # must print "Hello from Docker!"
```
6. Clean up the test (pulling ready-made images is forbidden in the project itself; this was only a test):
```
docker rm $(docker ps -aq)
docker rmi hello-world
```

### 2.3 Host configuration (required by the subject)
```
mkdir -p ~/data/mariadb ~/data/wordpress
echo "127.0.0.1 <login>.42.fr" | sudo tee -a /etc/hosts
ls ~/data                   # check: mariadb  wordpress
cat /etc/hosts              # check: the new line is at the end
```
`~/data` is `/home/<login>/data`, the path required for the two named volumes.

## 3. Troubleshooting notes
- **Mouse stuck in the VM window:** press the host key (Right Ctrl).
- **Window too small:** Right Ctrl + F (full screen) or View > Scaled Mode.
- **Cannot copy/paste into the VM:** enable Devices > Shared Clipboard > Bidirectional (may need `virtualbox-guest-x11`); paste in the terminal with Ctrl + Shift + V. Otherwise type commands by hand, one line at a time.
- **Multi-line `<<EOF` command typed as a single line:** it does not work; use the `printf` one-liner above.
- **`Invalid value set for option Signed-By ... (not a fingerprint)`:** a stray character in `docker.sources`; rewrite the file with the `printf` command and check it with `cat -A`.
- **`Unable to locate package`:** typo in a package name (`containerd.io`, `docker-buildx-plugin`).

### Troubleshooting notes
- **Mouse stuck inside the VM window:** press the host key (Right Ctrl) to release it.
- **Text installer language list cannot be scrolled:** use the Graphical install instead; the result is identical.
- **Country list has no Netherlands when English is selected:** choose "other", then Europe, then Netherlands.
- **Keyboard layout:** the "international" layout uses dead keys that break quotes in the terminal, so the plain American layout was chosen. Check with Shift+2: `@` means US layout, `"` means Dutch layout.

### Why persistent data folders and `/etc/hosts`

- **Data folders (`/home/<login>/data/mariadb` and `/home/<login>/data/wordpress`):**
  containers are disposable: deleting one deletes everything written inside it.
  The WordPress database and website files must survive, so they are stored in
  two Docker named volumes whose data lives in these host folders. Docker needs
  the folders to exist before it mounts the volumes, so the Makefile creates
  them (`mkdir -p`) before starting the stack. This also makes the project work
  on a clean VM.
- **`/etc/hosts` entry (`127.0.0.1 <login>.42.fr`):** this file maps names to
  IP addresses and is read before any DNS server. The line makes
  `<login>.42.fr` point to the VM itself (loopback), where NGINX listens on
  port 443. It lives on the VM, not in the repository, so it must be added
  manually when setting up a new VM.

fonte:
https://www.datacamp.com/blog/containers-vs-virtual-machines?utm_cid=23552157103&utm_aid=188237542930&utm_campaign=230119_1-ps-other~dsa-tofu~data-eng_2-b2c_3-europe_4-prc_5-na_6-na_7-le_8-pdsh-go_9-nb-e_10-na_11-na&utm_loc=9064298-&utm_mtd=-c&utm_kw=&utm_source=google&utm_medium=paid_search&utm_content=ps-other~europe-en~dsa~tofu~blog~data-engineering&gad_source=1&gad_campaignid=23552157103&gbraid=0AAAAADQ9WsEGVU7SbCStmexZtsbW5rp8z&gclid=CjwKCAjw3NHWBhANEiwAtpwId2zEN1elcoD1sSDMFioSieXmym7Q4TOY7IJajQ1gtpt0YYdGiWtwmxoCRC8QAvD_BwE

https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-an-image/

https://docs.docker.com/get-started/docker-concepts/building-images/understanding-image-layers/
