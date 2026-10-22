#FROM tells Docker which base image to start from
#If the image isn’t on your machine yet, Docker downloads (allowed by subject)
#FROM takes the debian imagem and specify the version using the codename bookworm
#if I don't specify the version and write only debian it will take the latest version
FROM debian:bookworm

#RUN install MariaDB
#Since the commands are joined by && they run in order and make one layer.
#apt-get update downloads the list of available packages.
#apt-get install -y --no-install-recommends mariadb-server installs the database.
	#-y answers “yes” automatically, because nobody can type during a build.
	#--no-install-recommends skips optional extras, which keeps the image smaller.
#rm -rf /var/lib/apt/lists/* deletes the package list we no longer need.
#Doing it in the same RUN matters: if it were a separate instruction, the list
#would still exist in the earlier layer and the image wouldn’t get smaller.
RUN apt-get update \
    && apt-get install -y --no-install-recommends mariadb-server \
    && rm -rf /var/lib/apt/lists/* /var/lib/mysql/*

#They copy files from your repo into the image.
#50-server.cnf - It tells the MariaDB server which network interface to listen on
#bind-address = 127.0.0.1 (Debian’s default):
	#the server only accepts connections that start inside its own container.
#bind-address = 0.0.0.0 (your file): the server accepts connections arriving
	#through any network interface of the container, including the one
	#connected to the Docker network.
#The file is identical everywhere. It only changes the “door” the server opens.
#init-db.sh - It is a script with instructions: “when the container starts,
	#read the names and passwords from the environment variables and the
	#secrets, then create the database and users, then start the server.”
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init-db.sh /usr/local/bin/init-db.sh

#Runs a command while the image is being built, and saves the result as a new layer.
#Use it to install software, create folders, set permissions.
#It runs once, at build time. It does not run when a container starts.
#chmod +x - Make the script executable
#mkdir -p /run/mysqld - create /run/mysqld
#chown -R mysql:mysql /run/mysqld - give it to the mysql user.
RUN chmod +x /usr/local/bin/init-db.sh \
    && mkdir -p /run/mysqld \
    && chown -R mysql:mysql /run/mysqld

#Documents which port the service listens on:
#It does not open or publish the port. It is only a note for people and tools reading the Dockerfile.
#Containers on the same Docker network can reach each other’s ports anyway, with or without EXPOSE.
EXPOSE 3306

#Defines what runs when a container starts.
#That process becomes PID 1, so the container lives as long as it runs.
ENTRYPOINT ["/usr/local/bin/init-db.sh"]
