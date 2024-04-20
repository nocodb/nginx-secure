#!/bin/bash

# if SSL_DOMAIN is set run certbot

if [ -n "$SSL_DOMAIN" ]; then
  certbot -d "$SSL_DOMAIN" --email "contact@${SSL_DOMAIN}" --agree-tos --no-eff-email
  systemctl restart nginx
fi

nginx -g "daemon off;"
