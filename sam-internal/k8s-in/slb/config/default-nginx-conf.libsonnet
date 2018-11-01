{
    data: |||
    server {
        listen       12080;
        server_name  localhost;

        location /_slb/status {
            vhost_traffic_status_display;
        }

        location /_slb/health {
            healthcheck_status;
        }

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

        location /logs {
            autoindex on;
            root /host/data/slb/;
        }

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
|||
}