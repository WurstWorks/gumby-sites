server {
    server_name wurstworks.com;
    return 301 $scheme://www.wurstworks.com$request_uri;
}
