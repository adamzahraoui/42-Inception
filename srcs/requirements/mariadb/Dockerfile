FROM debian:bookworm
RUN apt-get update && apt-get install mariadb-server -y
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/mariadb.sh /mariadb.sh
RUN chmod +x /mariadb.sh
CMD [ "/mariadb.sh" ]