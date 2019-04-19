local flowsnake_config = import "flowsnake_config.jsonnet";
local std_new = import "stdlib_0.12.1.jsonnet";

std_new.strReplace(|||
    apiVersion: v1
    clusters:
    - cluster:
        certificate-authority: /certs/ca.pem
        server: https://{{KUBEAPI}}
      name: kubernetes
    contexts:
    - context:
        cluster: kubernetes
        user: kubernetes
      name: default-context
    current-context: default-context
    kind: Config
    preferences: {}
    users:
    - name: kubernetes
      user:
        client-certificate: /certs/client/certificates/client.pem
        client-key: /certs/client/keys/client-key.pem
|||,"{{KUBEAPI}}",flowsnake_config.api_slb_fqdn)
