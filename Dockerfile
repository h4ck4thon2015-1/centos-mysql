# =============================================================================
# jdeathe/centos-ssh-mysql
# 
# CentOS-6, MySQL 5.1
# 
# RUN:
# docker run -d --name mysql.pool-1.1.1 -p 3306:3306 \
#   jdeathe/centos-ssh-mysql:latest
# LOGS:
# docker logs mysql.pool-1.1.1
# ACCESS: 
# sudo /usr/bin/nsenter -m -u -i -n -p -t $(/usr/bin/docker inspect \
#   --format '{{ .State.Pid }}' mysql.pool-1.1.1) /bin/bash
#
# =============================================================================
FROM jdeathe/centos-ssh-apache-php

MAINTAINER H4CK1THON <jh4ck4thon@gmail.com>

# -----------------------------------------------------------------------------
# INSTALL yum install php-mysql.x86_64
# -----------------------------------------------------------------------------
RUN yum install php-mysql.x86_64

# -----------------------------------------------------------------------------
# Create Table in Database
# -----------------------------------------------------------------------------
RUN mysql -e "use docker; CREATE TABLE docker_data (id INT(12) NOT NULL auto_increment, description TEXT, image BLOB, primary KEY (id));"

# -----------------------------------------------------------------------------
# Insert Data in Database
# -----------------------------------------------------------------------------
RUN mysql -e "use docker; INSERT into docker_data VALUES (NULL, \"This is a first insert\", NULL);"

# -----------------------------------------------------------------------------
# Allow access from outside to Database
# -----------------------------------------------------------------------------
RUN mysql -e "GRANT ALL PRIVILEGES ON docker.* TO 'root'@'%'; FLUSH PRIVILEGES;"
