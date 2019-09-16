local estate = std.extVar("estate");
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";
local enabled = std.objectHas(flowsnake_images.feature_flags, "spark_operator");
local madkub_common = import "madkub_common.jsonnet";
local cert_name = "spark-webhook";
local autodeployer = import "auto_deployer.jsonnet";
local new_std = import "stdlib_0.12.1.jsonnet";
local pki_kingdom = (if "upcase_pki_kingdom" in flowsnake_images.feature_flags then new_std.asciiUpper(std.extVar("kingdom")) else std.extVar("kingdom"));


{
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
      name: "spark-operator",
      namespace: "flowsnake",
      labels: {
        "app.kubernetes.io/name": "spark-operator",
        "app.kubernetes.io/version": "v2.4.0-v1beta1",
      },
    },
    spec: {
        replicas: 3,
        selector: {
            matchLabels: {
                "app.kubernetes.io/name": "spark-operator",
                "app.kubernetes.io/version": "v2.4.0-v1beta1",
            },
        },
        template: {
            metadata: {
                labels: {
                    "app.kubernetes.io/name": "spark-operator",
                    "app.kubernetes.io/version": "v2.4.0-v1beta1",
                },
                annotations: {
                    "madkub.sam.sfdc.net/allcerts": std.toString({"certreqs": [{
                        "cert-type": "server",
                        "kingdom": pki_kingdom,
                        "name": cert_name,
                        "role": "flowsnake.spark-operator",
                        "san": ["spark-webhook.flowsnake", "spark-webhook.flowsnake.svc", "spark-webhook.flowsnake.svc.cluster.local"]
                    }]})
                }
            },
            spec: {
                serviceAccountName: "spark-operator-serviceaccount",
                containers: [
                    {
                        name: "spark-operator",
                        image: flowsnake_images.spark_operator,
                        imagePullPolicy: "Always",
                        command: ["/usr/bin/spark-operator"],
                        args: ["-logtostderr",
                            "-v=3",
                            "-enable-metrics=true",
                            "-metrics-endpoint=/metrics",
                            "-metrics-port=10254",
                            "-enable-webhook=true",
                            "-enable-resource-quota-enforcement=true",
                            "-webhook-svc-namespace=flowsnake",
                            "-webhook-port=8443",
                            "-webhook-fail-on-error=true",
                            "-webhook-server-cert=/certs/server/certificates/server.pem",
                            "-webhook-server-cert-key=/certs/server/keys/server-key.pem",
                            "-webhook-ca-cert=/certs/ca/cabundle.pem",
                            "-leader-election",
                            "-leader-election-lock-namespace=" + (if autodeployer.samcontroldeployer["delete-orphans"] then "spark-operator-lock" else "flowsnake"),
                            "-webhook-namespace-selector=spark-operator-webhook=enabled",
                        ],
                        ports: [{
                            containerPort: 10254,
                            name: "metrics",
                            protocol: "TCP",
                        },{
                            containerPort: 8443,
                            name: "webhook",
                            protocol: "TCP",
                        }],
                        volumeMounts: madkub_common.cert_mounts(cert_name),
                        },
                        madkub_common.refresher_container(cert_name)
                ],
                volumes: madkub_common.cert_volumes(cert_name),
                initContainers: [madkub_common.init_container(cert_name)],
            } ,
        },
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 1,
            },
        },
    },
}
