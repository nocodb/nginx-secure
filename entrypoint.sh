#!/bin/bash

# Hydrate default.conf.template PROXY_HOST and PROXY_PORT PROXY_DOMAIN with environment variables
envsubst '$PROXY_HOST,$PROXY_PORT,$PROXY_DOMAIN' < /app/default.conf.template > /etc/nginx/conf.d/default.conf

if [ "$DEBUG" = "true" ]; then
  echo "DEBUG MODE ENABLED"

  echo "Nginx configuration:"
  cat /etc/nginx/conf.d/default.conf
  echo -e "\n==========================="

  echo "Existing certificates:"
  certbot certificates
  echo -e "\n==========================="

  echo "Environment variables:"
  echo " PROXY_HOST: $PROXY_HOST"
  echo " PROXY_PORT: $PROXY_PORT"
  echo " PROXY_DOMAIN: $PROXY_DOMAIN"
  echo " SSL_ENABLED: $SSL_ENABLED"
  echo "==========================="
fi

if [ "$SSL_ENABLED" = "true" ]; then
  # check if certbot certificates already exist for $PROXY_DOMAIN
  if certbot certificates | grep -q $PROXY_DOMAIN; then
    echo "Certificate already exists for $PROXY_DOMAIN"
    certbot --cert-name $PROXY_DOMAIN install
  else
    echo "Certificate does not exist for $PROXY_DOMAIN, creating..."
    certbot --nginx --email "contact@domain.com" --agree-tos --no-eff-email -d $PROXY_DOMAIN
  fi
fi

if [ "$DEBUG" = "true" ]; then
  echo "Updated Nginx configuration:"
  cat /etc/nginx/conf.d/default.conf
  echo -e "\n==========================="

  echo "Certbot log:"
  cat /var/log/letsencrypt/letsencrypt.log
  echo -e "\n==========================="
fi

# Stop nginx if it's already running
nginx -s stop

# Start nginx
nginx -g "daemon off;"
