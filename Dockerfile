FROM nginx:latest
LABEL authors="rohittp0"

WORKDIR /app

RUN apt-get update

# Install certbot
RUN apt-get install -y certbot

# Install certbot nginx plugin
RUN apt-get install -y python3-certbot-nginx

EXPOSE 80 443

COPY entrypoint.sh .

STOPSIGNAL SIGQUIT

ENTRYPOINT ["./entrypoint.sh"]
