FROM nginx:latest
LABEL authors="rohittp0"

WORKDIR /app

RUN apt-get update

# Install dependencies
RUN apt-get install -y certbot python3-certbot-nginx gettext

RUN mkdir -p /etc/nginx/sites-enabled
RUN ln -s /etc/nginx/default.conf /etc/nginx/sites-enabled/default.conf

EXPOSE 80 443

COPY entrypoint.sh .
COPY default.conf.template .

RUN chmod +x entrypoint.sh

STOPSIGNAL SIGQUIT

ENTRYPOINT ["./entrypoint.sh"]
