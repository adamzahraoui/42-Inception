FROM debian:bullseye

# 1. Update w installation dial nginx w openssl
RUN apt-get update && apt-get install -y \
    nginx \
    openssl

# 2. Création dial dossier فين ghan-7ttou SSL certificates
RUN mkdir -p /etc/nginx/ssl

# 3. Génération d'un certificat SSL self-signed (TLSv1.3)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/inception.key \
    -out /etc/nginx/ssl/inception.crt \
    -subj "/C=MA/ST=Rabat/L=Salé/O=42/OU=42Salé/CN=akira.42.fr"

# 4. Copier l'fichier de configuration dial NGINX lli ghadi n-criywiw
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# 5. Création dial dossier run (ila kan darouri l nginx)
RUN mkdir -p /var/run/nginx

# 6. Ouvrir port 443 (HTTPS)
EXPOSE 443

# 7. L'process l-rissi (CMD) bach NGINX y-b9a f l'foreground (bla daemon)
CMD ["nginx", "-g", "daemon off;"]