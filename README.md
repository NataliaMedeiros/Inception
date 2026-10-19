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

fonte:
https://www.datacamp.com/blog/containers-vs-virtual-machines?utm_cid=23552157103&utm_aid=188237542930&utm_campaign=230119_1-ps-other~dsa-tofu~data-eng_2-b2c_3-europe_4-prc_5-na_6-na_7-le_8-pdsh-go_9-nb-e_10-na_11-na&utm_loc=9064298-&utm_mtd=-c&utm_kw=&utm_source=google&utm_medium=paid_search&utm_content=ps-other~europe-en~dsa~tofu~blog~data-engineering&gad_source=1&gad_campaignid=23552157103&gbraid=0AAAAADQ9WsEGVU7SbCStmexZtsbW5rp8z&gclid=CjwKCAjw3NHWBhANEiwAtpwId2zEN1elcoD1sSDMFioSieXmym7Q4TOY7IJajQ1gtpt0YYdGiWtwmxoCRC8QAvD_BwE

