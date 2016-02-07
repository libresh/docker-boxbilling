#!/bin/bash
set -e

if [ ! -e '/var/www/html/index.php' ]; then
  tar cf - --one-file-system -C /usr/src/boxbilling . | tar xf -
  chown -R www-data /var/www/html
else
  rm -rf /var/www/html/install
fi

chfn -f 'BoxBilling Admin' www-data

cat > /etc/ssmtp/ssmtp.conf << EOF
UseTLS=Yes
UseSTARTTLS=Yes
root=${MAIL_USER}
mailhub=${MAIL_HOST}:${MAIL_PORT}
hostname=${MAIL_USER}
AuthUser=${MAIL_USER}
AuthPass=${MAIL_PASS}
EOF

echo "www-data:${MAIL_USER}:${MAIL_HOST}:${MAIL_PORT}" >> /etc/ssmtp/revaliases

while /bin/true; do
  /usr/local/bin/php /var/www/html/bb-cron.php
  sleep 300
done &

exec "$@"
