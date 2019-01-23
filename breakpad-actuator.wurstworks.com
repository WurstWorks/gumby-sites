server {
    server_name breakpad-actuator.wurstworks.com;

    access_log  /var/log/nginx/breakpad-actuator.wurstworks.com-access.log;
    error_log   /var/log/nginx/breakpad-actuator.wurstworks.com-error.log;

    location / {
        proxy_set_header    Host $host;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto $scheme;

        # Fix reverse proxy error.
        proxy_pass          http://localhost:9001;
        proxy_redirect      http://localhost:9001 http://breakpad-actuator.wurstworks.com;
        proxy_read_timeout  90s;
    }


    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/breakpad-actuator.wurstworks.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/breakpad-actuator.wurstworks.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot


}
server {
    if ($host = breakpad-actuator.wurstworks.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    server_name breakpad-actuator.wurstworks.com;
    listen 80;
    return 404; # managed by Certbot


}