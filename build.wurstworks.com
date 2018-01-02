server {
    listen 80;
    listen [::]:80;
    server_name build.wurstworks.com;

    access_log  /var/log/nginx/jenkins.access.log;
    error_log   /var/log/nginx/jenkins.error.log;

    location / {
        proxy_set_header    Host $host;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto $scheme;

        # Fix reverse proxy error.
        proxy_pass          http://localhost:8080;
        proxy_redirect      http://localhost:8080 http://build.wurstworks.com;
        proxy_read_timeout  90s;
    }

    listen 443 ssl; # managed by Certbot

    ssl_certificate     /etc/letsencrypt/live/build.wurstworks.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/build.wurstworks.com/privkey.pem; # managed by Certbot
    include             /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam         /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    if ($scheme != "https") {
        return 301 https://$host$request_uri;
    } # managed by Certbot
}
