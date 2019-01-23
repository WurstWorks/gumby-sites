server {
    server_name elk.wurstworks.com;

    access_log  /var/log/nginx/elk.wurstworks.com-access.log;
    error_log   /var/log/nginx/elk.wurstworks.com-error.log;

    location / {
        proxy_set_header    Host $host;
        proxy_set_header    X-Real-IP $remote_addr;
        proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Proto $scheme;

        # Fix reverse proxy error.
        proxy_pass          http://localhost:5601;
        proxy_redirect      http://localhost:5601 http://elk.wurstworks.com;
        proxy_read_timeout  90s;
    }


    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/elk.wurstworks.com/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/elk.wurstworks.com/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if ($host = elk.wurstworks.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    server_name elk.wurstworks.com;
    listen 80;
    return 404; # managed by Certbot


}