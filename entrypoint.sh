#!/bin/bash

# Stop on error
set -e

# -------------------
# DEBUG information
# -------------------
if [ "$DEBUG" = "true" ]; then
  echo "DEBUG MODE ENABLED"
  echo "MAPPINGS: $MAPPINGS"
  echo "SSL_ENABLED: $SSL_ENABLED"
  echo "Let's encrypt email: ${LETSENCRYPT_EMAIL:-contact@domain.com}"
  echo "==========================="
fi

# -------------------
# Split the MAPPINGS
# -------------------
IFS=',' read -ra MAPPING_LIST <<< "$MAPPINGS"

# Clear out any old default config(s) (optional)
rm -f /etc/nginx/conf.d/*.conf

# For each mapping: domain=host:port
for MAPPING in "${MAPPING_LIST[@]}"; do

  # Extract the domain, host, port
  DOMAIN="$(echo "$MAPPING" | cut -d= -f1)"
  HOSTPORT="$(echo "$MAPPING" | cut -d= -f2)"

  PROXY_HOST="$(echo "$HOSTPORT" | cut -d: -f1)"
  PROXY_PORT="$(echo "$HOSTPORT" | cut -d: -f2)"

  # Export these so envsubst can substitute them
  export PROXY_DOMAIN="$DOMAIN"
  export PROXY_HOST="$PROXY_HOST"
  export PROXY_PORT="$PROXY_PORT"

  # -------------------------
  # Render Nginx config
  # -------------------------
  if [ "$DEBUG" = "true" ]; then
    echo "Generating config for:"
    echo "  Domain: $PROXY_DOMAIN"
    echo "  Host:   $PROXY_HOST"
    echo "  Port:   $PROXY_PORT"
  fi

  # Use envsubst to produce a .conf per domain
  envsubst '$PROXY_DOMAIN,$PROXY_HOST,$PROXY_PORT' \
    < /app/default.conf.template \
    > "/etc/nginx/conf.d/${PROXY_DOMAIN}.conf"

  # -------------------------
  # Issue or Install SSL Cert
  # -------------------------
  if [ "$SSL_ENABLED" = "true" ]; then

    # Check whether a cert exists for this domain
    if certbot certificates | grep -q "$PROXY_DOMAIN"; then
      echo "Certificate already exists for $PROXY_DOMAIN"
      certbot --cert-name "$PROXY_DOMAIN" install
    else
      echo "Creating certificate for $PROXY_DOMAIN..."
      certbot --nginx \
              --email "${LETSENCRYPT_EMAIL:-contact@domain.com}" \
              --agree-tos \
              --no-eff-email \
              -d "$PROXY_DOMAIN"
    fi
  fi

  if [ "$DEBUG" = "true" ]; then
    echo "-------------------------------------------"
  fi
done

# -------------------------
# Debug / Verification
# -------------------------
if [ "$DEBUG" = "true" ]; then
  echo "Final Nginx Config(s):"
  cat /etc/nginx/conf.d/*.conf
  echo "-------------------------------------------"

  echo "Existing certificates:"
  certbot certificates || true
  echo "-------------------------------------------"
fi

# Stop nginx if it's already running (ignore error if not running)
nginx -s stop || true

# Start nginx in foreground
exec nginx -g "daemon off;"
