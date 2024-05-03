# Nginx Secure

This repository provides a Dockerized Nginx setup that integrates with Certbot for automatic SSL certificate deployment. It's designed to facilitate secure HTTP and HTTPS traffic forwarding with minimal manual configuration.

## Features

- **Automatic SSL Certificates**: Utilizes Certbot to automatically retrieve and renew SSL certificates from Let's Encrypt.
- **Nginx as a Reverse Proxy**: Configured to act as a reverse proxy, forwarding requests to your application.
- **Dockerized for Ease of Deployment**: Everything runs inside Docker, ensuring consistency across different environments.

## Usage

You can use the pre-built Docker image `nocodb/nginx-secure` as: 

```yaml
services:
    nginx:
      image: nocodb/nginx-secure
      ports:
        - "80:80"
        - "443:443"
      volumes:
        - ./certs:/etc/letsencrypt/
      restart: unless-stopped
      env_file: docker.env

    application:
      image: your-application
      restart: unless-stopped
```

Checkout `docker.env.sample` for the required environment variables.

## Building the Image

If you need custom nginx configurations, you can build the image yourself:

1. Clone this repository.
2. Modify the `default.conf.template` file as needed.
3. Run `docker build -t nginx-secure .` in the repository root.
