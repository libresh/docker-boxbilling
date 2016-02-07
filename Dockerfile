FROM php:5.6-fpm

RUN apt-get update && apt-get install -y \
      locales \
      bzip2 \
      cron \
      libcurl4-openssl-dev \
      libmcrypt-dev \
      mysql-client \
      ssmtp \
      unzip \
 && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo_mysql curl mbstring gettext mcrypt

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=60'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/opcache-recommended.ini

# PECL extensions
RUN pecl install APCu-4.0.10 \
 && docker-php-ext-enable apcu

ENV BOXBILLING_VERSION 4.20
VOLUME /var/www/html

RUN mkdir -p /usr/src/boxbilling \
 && cd /usr/src/boxbilling \
 && curl -fsSL -o boxbilling.zip \
      "https://github.com/boxbilling/boxbilling/releases/download/${BOXBILLING_VERSION}/BoxBilling.zip" \
 && unzip boxbilling.zip \
 && rm boxbilling.zip

# Set the locale
RUN locale-gen en_US.UTF-8 en_us \
 && locale-gen C.UTF-8 \
 && locale-gen fr_FR.UTF-8 \
 && dpkg-reconfigure locales \
 && /usr/sbin/update-locale LANG=C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8
ENV LC_ALL C.UTF-8

COPY docker-entrypoint.sh /entrypoint.sh
COPY php.ini /usr/local/etc/php/php.ini

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
