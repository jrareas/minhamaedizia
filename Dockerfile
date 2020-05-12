FROM jrareas/magento

# Make sure an .env file exists before you run docker-compose up

ARG magento_db_host
ARG magento_db_name
ARG magento_db_user
ARG magento_db_pass

#COPY ./etc/php/php.ini /usr/local/etc/php/
COPY ./app/etc/env.php /app/app/etc/env.php
#COPY ./app/etc/config.php ./app/etc/config.php

RUN mkdir -p /etc/apache2/ssl

COPY ./app/etc/apache2/ssl/* /etc/apache2/ssl/
COPY ./app/etc/apache2/sites-available/* /etc/apache2/sites-available/
COPY ./app/etc/cron/crontab /etc/cron.d/

ENV MAGENTO_DB_HOST ${magento_db_host}
ENV MAGENTO_DB_NAME ${magento_db_name}
ENV MAGENTO_DB_USER ${magento_db_user}
ENV MAGENTO_DB_PASS ${magento_db_pass}

RUN echo $magento_db_host

RUN apt-get update && apt-get install -y wget

RUN wget https://github.com/mageplaza/magento-2-portuguese-brazil-language-pack/raw/master/pt_BR.csv
RUN php bin/magento i18n:pack -d -m replace pt_BR.csv pt_BR
RUN php bin/magento setup:static-content:deploy pt_BR -f

# envs
ENV INSTALL_DIR /app

WORKDIR $INSTALL_DIR

#RUN php bin/magento cron:install
RUN php bin/magento cache:clean
RUN php bin/magento cache:flush

RUN a2enmod ssl
RUN a2ensite default-ssl
RUN a2ensite minhamaedizia

CMD [ "sh", "-c", "cron && apache2-foreground" ]