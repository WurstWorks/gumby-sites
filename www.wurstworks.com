server {
    server_name www.wurstworks.com;
    root /home/rherrick/html/www.wurstworks.com;

    access_log  /var/log/nginx/www.wurstworks.com-access.log;
    error_log   /var/log/nginx/www.wurstworks.com-error.log;

    index index.html;

    include snippets/security.conf; 

    location /wghs {
        root /backup/transfer;
        autoindex on;
    }

    location / {
        try_files $uri $uri/ =404;
    }

    listen 443 ssl http2; # managed by Certbot
    listen [::]:443 ssl http2; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/www.wurstworks.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/www.wurstworks.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
    if ($host = www.wurstworks.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    server_name www.wurstworks.com;
    listen 80 http2;
    listen [::]:80 http2;
    return 404; # managed by Certbot
}
