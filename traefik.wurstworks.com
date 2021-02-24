server {
    server_name traefik.wurstworks.com;

    access_log  /var/log/nginx/traefik.wurstworks.com-access.log;
    error_log   /var/log/nginx/traefik.wurstworks.com-error.log;

    include snippets/security.conf;

    location / {
        proxy_set_header    Host $host;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto $scheme;

        # Fix reverse proxy error.
        proxy_pass          http://localhost:9081;
        proxy_redirect      http://localhost:9081 http://traefik.wurstworks.com;
        proxy_read_timeout  90s;
    }


    listen 443 ssl http2; # managed by Certbot
    listen [::]:443 ssl http2; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/traefik.wurstworks.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/traefik.wurstworks.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if ($host = traefik.wurstworks.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    server_name traefik.wurstworks.com;
    listen 80 http2;
    listen [::]:80 http2;
    return 404; # managed by Certbot
}
