server {
    server_name wurstworks.com www.wurstworks.com;
    root /home/rherrick/html/www.wurstworks.com;

    access_log  /var/log/nginx/www.wurstworks.com-access.log;
    error_log   /var/log/nginx/www.wurstworks.com-error.log;

    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }


    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/www.wurstworks.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/www.wurstworks.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot



}
server {
    if ($host = www.wurstworks.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    if ($host = wurstworks.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    server_name wurstworks.com www.wurstworks.com;
    listen 80;
    return 404; # managed by Certbot




}