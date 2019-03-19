local configs = import "config.jsonnet";

# NOTE: For some odd reason, jsonnet sometimes outputs multi-line strings with actual newlines and sometimes with escaped newlines.
# The output looks way better with actual newlines.  It seems to be related to the start of a multi-line string.  Something like this is ok:
#
#   foo = @'abc
#   def'
#
# But this is not ok:
#
#   foo = @'
#   abc
#   def'
#
# When working on this file, make sure no multi-line string starts with a carrage return.

# Prd-sam is insecure because we dont know who we will break yet.  Prd-samdev is insecure for e2e.  No reason to mess with sdc/storage.
# All new estates in PRD and XRD should be secure mostly-read-only by default
local use_insecure = (if configs.estate == "prd-sam" || configs.estate == "prd-samdev" || configs.estate == "prd-sdc" || configs.estate == "prd-sam_storage" || configs.estate == "prd-sam_storagedev" then true else false);

{
# In prd-sam we ran a wide-open proxy for a long time, and we dont yet know who will break if we lock down writes
# For now keeping it mostly open.
  legacy_insecure_sandbox:: @'    # Empty
',
# By default we dont want to allow writes, and users should use GIT manifests and CI APIs for everything.  XRD is the first
# to be set up this way.
  somewhat_secure_mostly_read_only:: @'    # Block deletes except for pods
    acl pod-kind url_reg /api/v1/namespaces/[a-z0-9-]+/pods/
    acl delete-method method DELETE
    http-request deny if delete-method !pod-kind !sam_api

    # Block post (create) except for exec to non-system namespaces
    acl post-method method POST
    acl exec url_reg /api/v1/namespaces/[a-z0-9-]+/pods/[a-z0-9-]+/exec?
    acl sam-system-ns url_reg /api/v1/namespaces/sam-system/
    acl kube-system-ns url_reg /api/v1/namespaces/kube-system/
    acl kube-public-ns url_reg /api/v1/namespaces/kube-public/
    http-request deny if post-method !exec !sam_api
    http-request deny if post-method exec sam-system-ns
    http-request deny if post-method exec kube-system-ns
    http-request deny if post-method exec kube-public-ns

    # Block put and patch for everything
    acl other-methods method PUT PATCH
    http-request deny if other-methods !sam_api
',
# This is the root of the haProxy config
  data: std.toString(@'global
    maxconn 1024
    # TODO: where should logs go? Local syslog for now.
    # http://cbonte.github.io/haproxy-dconv/1.6/configuration.html#3.1-log
    log 127.0.0.1 syslog

defaults
    option tcplog
    option dontlognull
    option tcpka

frontend localhost
    bind *:5000
    mode http

    # Block secret access
    acl secrets url_reg /api/v1/secrets
    acl secrets_namespace url_reg /api/v1/namespaces/[a-z0-9-]+/secrets
    # The E2E test downloads this secret from sam-system namespace and uploads to the new
    # e2e namespce.  For now just allow this one secret through.
    # TODO: Remove this if we remove statufl ceph from E2E
    acl e2e_secret1 url_reg /api/v1/namespaces/sam-system/secrets/ceph-sec-user-rdi
    acl e2e_secret2 url_reg /api/v1/namespaces/e2e-[a-z0-9-]+/secrets
    http-request deny if secrets !e2e_secret1 !e2e_secret2
    http-request deny if secrets_namespace !e2e_secret1 !e2e_secret2

    # Define this early so it can be referenced in additional ACLs
    acl sam_api url_reg /apis/samcrd.salesforce.com/v1/namespaces/.*/samapps.*

    # Begin additional ACLs
' + (if use_insecure then $.legacy_insecure_sandbox else $.somewhat_secure_mostly_read_only) + @'    # End additional ALCs

    # Redirect API access to CI CRD so traffic goes through the validating proxy
    use_backend sam_api_proxy_server if sam_api

    timeout client 50s
    timeout client-fin 30s
    log global
    default_backend kubernetes-apiserver
    # Enable the sending of TCP keepalive packets on the client side
    option clitcpka

backend sam_api_proxy_server
    mode http
    timeout server 50s
    timeout connect 5s
    timeout tunnel  50s
    option httpchk HEAD /healthz HTTP/1.1\r\nHost:\ localhost
    default-server inter 5s fall 3 rise 2
    option srvtcpka
    # Nodeport for sam api proxy
    server proxy localhost:39872

backend kubernetes-apiserver
    mode http
    timeout server 50s
    timeout connect 5s
    timeout tunnel  50s
    option httpchk HEAD /healthz HTTP/1.1\r\nHost:\ localhost
    default-server inter 5s fall 3 rise 2
    option srvtcpka

    # Connect to local HAProxy, preferring the one on this host
    # TODO: The below host specific cert will be called hostcert-chain.pem and will work on any host
    # Change this after the filename is available through puppet.
    server proxy localhost:8000 ssl ca-file /etc/pki_service/ca/cabundle.pem crt ' + configs.chainFile + @'
'),
}
