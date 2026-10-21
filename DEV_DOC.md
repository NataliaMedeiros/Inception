# Developer Documentation

## 1. Virtual Machine Setup

### 1.1 Choices
- **Hypervisor:** Oracle VirtualBox (installed on the campus computers).
- **VM operating system:** Debian 13 "trixie" (stable), file `debian-13.7.0-amd64-netinst.iso` from debian.org.
- **Why Debian:** widely documented, glibc-based (software behaves as documented), easier to debug than Alpine.
- **Storage:** VM files are kept in the shared campus storage (`sgoinfre`) to avoid filling the home quota.
- **Resources:** 4096 MB RAM, 2 CPUs, 30 GB dynamically allocated disk.
- **Containers' base image:** the penultimate stable Debian release (`bookworm`), never the `latest` tag.

### 1.2 Creating the VM (VirtualBox Manager > New)
1. Name: `inception`; Folder: personal folder in `sgoinfre`; ISO Image: the Debian netinst ISO.
2. Type: Linux; Version: Debian (64-bit).
3. Check **Skip Unattended Installation**, so user, hostname and partitioning are chosen manually.
4. Hardware: Base Memory 4096 MB, Processors 2.
5. Hard disk: Create a Virtual Hard Disk Now, 30 GB, VDI. Leave **Pre-allocate Full Size** unchecked.
6. Click Finish, select the VM and click **Start**.

### 1.3 Installing Debian
1. Installer menu: **Graphical install**
2. Language: English. Location: other > Europe > Netherlands. Locale: `en_US.UTF-8`.
3. Keyboard: American English.
4. Hostname: `<login>`. Domain name: empty.
5. Set a root password and create a user named `<login>` with its own password (passwords are never stored in the repository).
6. Partitioning: Guided - use entire disk > All files in one partition (no LVM, no encryption) > Finish partitioning and write changes to disk > Yes.
7. Package manager: no extra installation media, country Netherlands, mirror `deb.debian.org`, no proxy.
8. Package usage survey: No.
9. Software selection: only **Xfce**, **SSH server** and **standard system utilities**. Uncheck "Debian desktop environment" and GNOME.
10. Install GRUB on `/dev/sda`.
11. After the reboot, choose "Debian GNU/Linux" in the GRUB menu (it is selected automatically after a few seconds) and log in.
12. Take a snapshot of the clean installation (`clean-install`, in Tools > Snapshots).

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
2. Add Docker's repository (one-line version, because multi-line pasting into the VM was not possible):
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

### 2.4 Git and SSH setup
1. Generate an SSH key pair (the private key stays on the VM and is never
   shared or committed):
```
ssh-keygen -t ed25519 -C "<login>@codam"
cat ~/.ssh/id_ed25519.pub      # public key, the one to register
```
2. Register the **public** key (`id_ed25519.pub`) in the Git account used for
   the repository (the SSH keys section of the profile or settings page).
3. Tell Git who you are (labels your commits; `--global` applies to every
   repository of this VM user):
```
git config --global user.name "<name>"
git config --global user.email "<email>"
git config --global --list     # check
```
4. Clone the repository (the URL is on the project page) and check it:
```
git clone <repository-url> inception
cd inception && git status
```
5. On the first connection, SSH asks to trust the host: answer `yes`.
