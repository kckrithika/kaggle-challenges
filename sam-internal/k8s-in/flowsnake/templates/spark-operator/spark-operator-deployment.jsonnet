local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";
local enabled = std.objectHas(flowsnake_images.feature_flags, "spark_operator");
local quota_enforcement = std.objectHas(flowsnake_images.feature_flags, "spark_application_quota_enforcement");
local madkub_common = import "madkub_common.jsonnet";
local cert_name = "spark-webhook";

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
        replicas: 1,
        selector: {
            matchLabels: {
                "app.kubernetes.io/name": "spark-operator",
                "app.kubernetes.io/version": "v2.4.0-v1beta1",
            },
        },
        strategy: {
            type: "Recreate",
        },
        template: {
            metadata: {
                labels: {
                    "app.kubernetes.io/name": "spark-operator",
                    "app.kubernetes.io/version": "v2.4.0-v1beta1",
                }
            } + (if quota_enforcement then {annotations: {
                    "madkub.sam.sfdc.net/allcerts": std.toString({"certreqs": [{
                        "cert-type": "server",
                        "kingdom": kingdom,
                        "name": cert_name,
                        "role": "flowsnake.spark-operator",
                        "san": ["spark-webhook.flowsnake", "spark-webhook.flowsnake.svc", "spark-webhook.flowsnake.svc.cluster.local"]
                    }]})
                }} else {}),
            spec: {
                serviceAccountName: "spark-operator-serviceaccount",
                containers: [
                    {
                        name: "spark-operator",
                        image: flowsnake_images.spark_operator,
                        imagePullPolicy: "Always",
                        command: ["/usr/bin/spark-operator"],
                        args: ["-logtostderr", "-v=2",
                            "-enable-metrics=true",
                            "-metrics-endpoint=/metrics",
                            "-metrics-port=10254",
                        ]
                        + (if quota_enforcement then [
                            "-enable-webhook=true",
                            "-enable-resource-quota-enforcement=true",
                            "-webhook-svc-namespace=flowsnake",
                            "-webhook-port=8443",
                            "-webhook-fail-on-error=true",
                            "-webhook-server-cert=/certs/server/certificates/server.pem",
                            "-webhook-server-cert-key=/certs/server/keys/server-key.pem",
                            "-webhook-ca-cert=/certs/ca/cabundle.pem",
                        ] else []),
                        ports: [{
                            containerPort: 10254,
                            name: "metrics",
                            protocol: "TCP",
                        }] + (if quota_enforcement then [{
                            containerPort: 8443,
                            name: "webhook",
                            protocol: "TCP",
                        }] else [])
                    } + (if quota_enforcement then {
                        volumeMounts: madkub_common.cert_mounts(cert_name),
                    } else {}),
                ] + (if quota_enforcement then [madkub_common.refresher_container(cert_name)] else []),
            } + (if quota_enforcement then {
                volumes: madkub_common.cert_volumes(cert_name),
                initContainers: [madkub_common.init_container(cert_name)],
            } else {}),
        },
    },
}
