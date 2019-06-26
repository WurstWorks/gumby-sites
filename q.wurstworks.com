server {
    server_name q.wurstworks.com;

    access_log  /var/log/nginx/q.wurstworks.com-access.log;
    error_log   /var/log/nginx/q.wurstworks.com-error.log;

    location / {
        proxy_set_header    Host $host;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto $scheme;

        # Fix reverse proxy error.
        proxy_pass          http://localhost:8161;
        proxy_redirect      http://localhost:8161 http://q.wurstworks.com;
        proxy_read_timeout  90s;
    }


    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/q.wurstworks.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/q.wurstworks.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}

server {
    if ($host = q.wurstworks.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    server_name q.wurstworks.com;
    listen 80;
    return 404; # managed by Certbot


}