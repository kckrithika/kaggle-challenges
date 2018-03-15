{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "certs-to-secrets",
        namespace: "flowsnake",
    },
    data: {
          targetConfigs:
            "flowsnake-tls.config
            sfdc-ca.config",
          "flowsnake-tls.config":
            "secretName=flowsnake-tls
            secretType=tls
            certificatePath=/certs/server/certificates/server.pem
            keyPath=/certs/server/keys/server-key.pem",
          "sfdc-ca.config":
            "secretName=sfdc-ca
            secretType=generic
            certificatePath=/certs/ca.pem",
          "master.config": std.toString(import "cert-secretizer-master-config.jsonnet"),
    },
}
