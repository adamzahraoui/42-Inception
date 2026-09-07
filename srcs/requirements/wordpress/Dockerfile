FROM debian:bookworm
RUN apt-get update && apt-get install -y \
    php \
    php8.2-fpm \
    php-mysql \
    php-mbstring \
    php-curl \
    php-gd \
    php-intl \
    wget \
    unzip

RUN mkdir -p /run/php
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp
COPY tools/wordpress.sh /wordpress.sh
RUN chmod +x /wordpress.sh
EXPOSE 9000
CMD [ "/wordpress.sh" ]