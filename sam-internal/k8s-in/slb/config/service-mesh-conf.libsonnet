{
    local slbconfigs = import "slbconfig.jsonnet",

    data: |||
    # Envoy port reference: https://git.soma.salesforce.com/servicelibs/sherpa#ports
    upstream service_mesh_http1 {
        check interval=3000 rise=2 fall=5 timeout=1000 type=tcp port=7013;
        server 127.0.0.1:7013 max_fails=3 fail_timeout=30s;
    }
    upstream service_mesh_http1_tls {
        check interval=3000 rise=2 fall=5 timeout=1000 type=tcp port=5442;
        server 127.0.0.1:5442 max_fails=3 fail_timeout=30s;
    }
    upstream service_mesh_http2 {
        check interval=3000 rise=2 fall=5 timeout=1000 type=tcp port=7011;
        server 127.0.0.1:7011 max_fails=3 fail_timeout=30s;
    }
    upstream service_mesh_http2_tls {
        check interval=3000 rise=2 fall=5 timeout=1000 type=tcp port=5443;
        server 127.0.0.1:5443 max_fails=3 fail_timeout=30s;
    }

    # http1 server
    server {
        listen %(envoyVip)s:7013;
        access_log /host/data/slb/logs/slb-envoy.access.slb_envoy_proxy_service_sam_system_9115.log combined buffer=64k gzip=1 flush=5m;
        location ~ ^/(?<service>[^\/]+) {
            set $mesh_host $service.localhost.mesh.force.com;
            rewrite ^/[^\/]+$ / break;
            rewrite ^/[^\/]+/(.*) /$1 break;
            proxy_http_version 1.1;
            proxy_pass http://service_mesh_http1;
            real_ip_header X-Forwarded-For;real_ip_recursive on;set_real_ip_from 10.252.240.0/25;set_real_ip_from 10.252.247.32/27;
            proxy_set_header HOST $mesh_host;proxy_set_header X-Forwarded-Proto $scheme;proxy_set_header X-Real-IP $remote_addr;proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;proxy_set_header X-Salesforce-SIP $remote_addr;proxy_set_header X-Client-Verify $ssl_client_verify;proxy_set_header X-Client-Cert $ssl_client_escaped_cert;proxy_set_header X-Client-Fingerprint $ssl_client_fingerprint;proxy_set_header CipherSuite "$ssl_cipher $ssl_protocol $server_port";proxy_set_header SSL_CIPHER $ssl_cipher;proxy_set_header SSL_CLIENT_S_DN $ssl_client_s_dn;proxy_set_header SSL_CLIENT_I_DN $ssl_client_i_dn;proxy_set_header SSL_CLIENT_M_SERIAL $ssl_client_serial;proxy_set_header SSL_SESSION_ID $ssl_session_id;proxy_set_header SSL_SHA1_HASH $ssl_client_fingerprint;proxy_set_header SSL_PROTOCOL $ssl_protocol;proxy_set_header SSL_CLIENT_V_START $ssl_client_v_start;proxy_set_header SSL_CLIENT_V_END $ssl_client_v_end;proxy_set_header SSL_CLIENT_V_REMAIN $ssl_client_v_remain;
            proxy_set_header Connection "";proxy_set_header X-Client-Verify "";proxy_set_header X-Client-Cert "";proxy_set_header X-Client-Fingerprint "";proxy_set_header CipherSuite "";proxy_set_header SSL_CIPHER "";proxy_set_header SSL_CLIENT_S_DN "";proxy_set_header SSL_CLIENT_I_DN "";proxy_set_header SSL_CLIENT_M_SERIAL "";proxy_set_header SSL_SESSION_ID "";proxy_set_header SSL_SHA1_HASH "";proxy_set_header SSL_PROTOCOL "";proxy_set_header SSL_CLIENT_V_START "";proxy_set_header SSL_CLIENT_V_END "";proxy_set_header SSL_CLIENT_V_REMAIN "";
            http2_push_preload on;
        }
    }

    # http1-tls server
    server {
        listen %(envoyVip)s:5442 ssl;
        access_log /host/data/slb/logs/slb-envoy.access.slb_envoy_proxy_service_sam_system_9115.log combined buffer=64k gzip=1 flush=5m;
        location ~ ^/(?<service>[^\/]+) {
            set $mesh_host $service.localhost.mesh.force.com;
            rewrite ^/[^\/]+$ / break;
            rewrite ^/[^\/]+/(.*) /$1 break;
            proxy_http_version 1.1;
            proxy_pass http://service_mesh_http1_tls;
            real_ip_header X-Forwarded-For;real_ip_recursive on;set_real_ip_from 10.252.240.0/25;set_real_ip_from 10.252.247.32/27;
            proxy_set_header HOST $mesh_host;proxy_set_header X-Forwarded-Proto $scheme;proxy_set_header X-Real-IP $remote_addr;proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;proxy_set_header X-Salesforce-SIP $remote_addr;proxy_set_header X-Client-Verify $ssl_client_verify;proxy_set_header X-Client-Cert $ssl_client_escaped_cert;proxy_set_header X-Client-Fingerprint $ssl_client_fingerprint;proxy_set_header CipherSuite "$ssl_cipher $ssl_protocol $server_port";proxy_set_header SSL_CIPHER $ssl_cipher;proxy_set_header SSL_CLIENT_S_DN $ssl_client_s_dn;proxy_set_header SSL_CLIENT_I_DN $ssl_client_i_dn;proxy_set_header SSL_CLIENT_M_SERIAL $ssl_client_serial;proxy_set_header SSL_SESSION_ID $ssl_session_id;proxy_set_header SSL_SHA1_HASH $ssl_client_fingerprint;proxy_set_header SSL_PROTOCOL $ssl_protocol;proxy_set_header SSL_CLIENT_V_START $ssl_client_v_start;proxy_set_header SSL_CLIENT_V_END $ssl_client_v_end;proxy_set_header SSL_CLIENT_V_REMAIN $ssl_client_v_remain;
            proxy_set_header Connection "";proxy_set_header X-Client-Verify "";proxy_set_header X-Client-Cert "";proxy_set_header X-Client-Fingerprint "";proxy_set_header CipherSuite "";proxy_set_header SSL_CIPHER "";proxy_set_header SSL_CLIENT_S_DN "";proxy_set_header SSL_CLIENT_I_DN "";proxy_set_header SSL_CLIENT_M_SERIAL "";proxy_set_header SSL_SESSION_ID "";proxy_set_header SSL_SHA1_HASH "";proxy_set_header SSL_PROTOCOL "";proxy_set_header SSL_CLIENT_V_START "";proxy_set_header SSL_CLIENT_V_END "";proxy_set_header SSL_CLIENT_V_REMAIN "";
            http2_push_preload on;
        }
        ssl_certificate /cert1/server/certificates/server.pem; ssl_certificate_key /cert1/server/keys/server-key.pem;
        ssl_client_certificate /cert1/ca.pem; ssl_verify_client optional; ssl_verify_depth 10;
    }

    # http2 server
    server {
        listen %(envoyVip)s:7011 http2;
        access_log /host/data/slb/logs/slb-envoy.access.slb_envoy_proxy_service_sam_system_9115.log combined buffer=64k gzip=1 flush=5m;
        location ~ ^/(?<service>[^\/]+) {
            set $mesh_host $service.localhost.mesh.force.com;
            rewrite ^/[^\/]+$ / break;
            rewrite ^/[^\/]+/(.*) /$1 break;
            proxy_http_version 1.1;
            proxy_pass http://service_mesh_http2;
            real_ip_header X-Forwarded-For;real_ip_recursive on;set_real_ip_from 10.252.240.0/25;set_real_ip_from 10.252.247.32/27;
            proxy_set_header HOST $mesh_host;proxy_set_header X-Forwarded-Proto $scheme;proxy_set_header X-Real-IP $remote_addr;proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;proxy_set_header X-Salesforce-SIP $remote_addr;proxy_set_header X-Client-Verify $ssl_client_verify;proxy_set_header X-Client-Cert $ssl_client_escaped_cert;proxy_set_header X-Client-Fingerprint $ssl_client_fingerprint;proxy_set_header CipherSuite "$ssl_cipher $ssl_protocol $server_port";proxy_set_header SSL_CIPHER $ssl_cipher;proxy_set_header SSL_CLIENT_S_DN $ssl_client_s_dn;proxy_set_header SSL_CLIENT_I_DN $ssl_client_i_dn;proxy_set_header SSL_CLIENT_M_SERIAL $ssl_client_serial;proxy_set_header SSL_SESSION_ID $ssl_session_id;proxy_set_header SSL_SHA1_HASH $ssl_client_fingerprint;proxy_set_header SSL_PROTOCOL $ssl_protocol;proxy_set_header SSL_CLIENT_V_START $ssl_client_v_start;proxy_set_header SSL_CLIENT_V_END $ssl_client_v_end;proxy_set_header SSL_CLIENT_V_REMAIN $ssl_client_v_remain;
            proxy_set_header Connection "";proxy_set_header X-Client-Verify "";proxy_set_header X-Client-Cert "";proxy_set_header X-Client-Fingerprint "";proxy_set_header CipherSuite "";proxy_set_header SSL_CIPHER "";proxy_set_header SSL_CLIENT_S_DN "";proxy_set_header SSL_CLIENT_I_DN "";proxy_set_header SSL_CLIENT_M_SERIAL "";proxy_set_header SSL_SESSION_ID "";proxy_set_header SSL_SHA1_HASH "";proxy_set_header SSL_PROTOCOL "";proxy_set_header SSL_CLIENT_V_START "";proxy_set_header SSL_CLIENT_V_END "";proxy_set_header SSL_CLIENT_V_REMAIN "";
            http2_push_preload on;
        }
    }

    # http2-tls server
    server {
        listen %(envoyVip)s:5443 ssl http2;
        access_log /host/data/slb/logs/slb-envoy.access.slb_envoy_proxy_service_sam_system_9115.log combined buffer=64k gzip=1 flush=5m;
        location ~ ^/(?<service>[^\/]+) {
            set $mesh_host $service.localhost.mesh.force.com;
            rewrite ^/[^\/]+$ / break;
            rewrite ^/[^\/]+/(.*) /$1 break;
            proxy_http_version 1.1;
            proxy_pass http://service_mesh_http2_tls;
            real_ip_header X-Forwarded-For;real_ip_recursive on;set_real_ip_from 10.252.240.0/25;set_real_ip_from 10.252.247.32/27;
            proxy_set_header HOST $mesh_host;proxy_set_header X-Forwarded-Proto $scheme;proxy_set_header X-Real-IP $remote_addr;proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;proxy_set_header X-Salesforce-SIP $remote_addr;proxy_set_header X-Client-Verify $ssl_client_verify;proxy_set_header X-Client-Cert $ssl_client_escaped_cert;proxy_set_header X-Client-Fingerprint $ssl_client_fingerprint;proxy_set_header CipherSuite "$ssl_cipher $ssl_protocol $server_port";proxy_set_header SSL_CIPHER $ssl_cipher;proxy_set_header SSL_CLIENT_S_DN $ssl_client_s_dn;proxy_set_header SSL_CLIENT_I_DN $ssl_client_i_dn;proxy_set_header SSL_CLIENT_M_SERIAL $ssl_client_serial;proxy_set_header SSL_SESSION_ID $ssl_session_id;proxy_set_header SSL_SHA1_HASH $ssl_client_fingerprint;proxy_set_header SSL_PROTOCOL $ssl_protocol;proxy_set_header SSL_CLIENT_V_START $ssl_client_v_start;proxy_set_header SSL_CLIENT_V_END $ssl_client_v_end;proxy_set_header SSL_CLIENT_V_REMAIN $ssl_client_v_remain;
            proxy_set_header Connection "";proxy_set_header X-Client-Verify "";proxy_set_header X-Client-Cert "";proxy_set_header X-Client-Fingerprint "";proxy_set_header CipherSuite "";proxy_set_header SSL_CIPHER "";proxy_set_header SSL_CLIENT_S_DN "";proxy_set_header SSL_CLIENT_I_DN "";proxy_set_header SSL_CLIENT_M_SERIAL "";proxy_set_header SSL_SESSION_ID "";proxy_set_header SSL_SHA1_HASH "";proxy_set_header SSL_PROTOCOL "";proxy_set_header SSL_CLIENT_V_START "";proxy_set_header SSL_CLIENT_V_END "";proxy_set_header SSL_CLIENT_V_REMAIN "";
            http2_push_preload on;
        }
        ssl_certificate /cert1/server/certificates/server.pem; ssl_certificate_key /cert1/server/keys/server-key.pem;
        ssl_client_certificate /cert1/ca.pem; ssl_verify_client optional; ssl_verify_depth 10;
    }
||| % slbconfigs
}