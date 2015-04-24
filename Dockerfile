# =============================================================================
# jdeathe/centos-ssh-mysql
# 
# CentOS-6, MySQL 5.1
# 
# RUN:
#	docker run -d --name mysql.pool-1.1.1 -p 3306:3306 \
#		jdeathe/centos-ssh-mysql:latest
# LOGS:
#	docker logs mysql.pool-1.1.1
# ACCESS: 
#	sudo /usr/bin/nsenter -m -u -i -n -p -t $(/usr/bin/docker inspect \
#		--format '{{ .State.Pid }}' mysql.pool-1.1.1) /bin/bash
#
# =============================================================================
FROM jdeathe/centos-ssh:centos-6

MAINTAINER James Deathe <james.deathe@gmail.com>

# -----------------------------------------------------------------------------
# Install MySQL
# -----------------------------------------------------------------------------
RUN yum --setopt=tsflags=nodocs -y install \
	mysql-server \
	; rm -rf /var/cache/yum/* \
	; yum clean all

# -----------------------------------------------------------------------------
# Copy files into place
# -----------------------------------------------------------------------------
RUN mkdir -p /etc/services-config/mysql
ADD etc/mysql-bootstrap /etc/
ADD etc/services-config/supervisor/supervisord.conf /etc/services-config/supervisor/
ADD etc/services-config/mysql/my.cnf /etc/services-config/mysql/
ADD etc/services-config/mysql/mysql-bootstrap.conf /etc/services-config/mysql/

RUN chmod +x /etc/mysql-bootstrap \
	&& ln -sf /etc/services-config/supervisor/supervisord.conf /etc/supervisord.conf \
	&& chmod 600 /etc/services-config/mysql/{my.cnf,mysql-bootstrap.conf} \
	&& ln -sf /etc/services-config/mysql/my.cnf /etc/my.cnf \
	&& ln -sf /etc/services-config/mysql/mysql-bootstrap.conf /etc/mysql-bootstrap.conf

EXPOSE 3306

# -----------------------------------------------------------------------------
# Create Database
# -----------------------------------------------------------------------------
RUN mysql -e "create database docker;"

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

CMD ["/usr/bin/supervisord", "--configuration=/etc/supervisord.conf"]
