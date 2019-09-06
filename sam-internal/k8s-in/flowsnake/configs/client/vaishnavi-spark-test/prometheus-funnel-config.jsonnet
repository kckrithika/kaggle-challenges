local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local hosts = import "flowsnake_hosts.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnake_config = import "flowsnake_config.jsonnet";

{
    "global": {
        "scrape_interval": "60s"
    },
    "remote_write": [
        {
            "url": "http://localhost:8000",
            "queue_config": {
                "capacity": 100000
            },
        },
    ],
    "scrape_configs": [
        {
            "bearer_token_file": "/var/run/secrets/kubernetes.io/serviceaccount/token",
            "job_name": "kube_dns_scrape",
            "kubernetes_sd_configs": [
            {
                "namespaces": {
                    "names": [
                       "kube-system"
                    ]
                },
                "role": "pod"
            }
            ],
            "relabel_configs": [
                {
                    "action": "keep",
                    "regex": "kube-dns-.*;kubedns;10055",
                    "source_labels": [
                         "__meta_kubernetes_pod_name",
                         "__meta_kubernetes_pod_container_name",
                         "__meta_kubernetes_pod_container_port_number"
                    ]
                },
                {
                    "replacement": "kubedns",
                    "target_label": "subservice"
                },
                {
                    "replacement": kingdom,
                    "target_label": "datacenter"
                },
                {
                    "replacement": estate,
                    "target_label": "estate"
                },
                {
                    "source_labels": [
                      "__meta_kubernetes_pod_node_name"
                    ],
                    "target_label": "device"
                }
            ],
            "tls_config": {
                "ca_file": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
            }
        },
        {
            "bearer_token_file": "/var/run/secrets/kubernetes.io/serviceaccount/token",
            "job_name": "spark-op-metrics",
            "kubernetes_sd_configs": [
                {
                   "role": "pod"
                }
            ],
            "relabel_configs": [
                {
                    "action": "keep",
                    "regex": "spark-operator;10254",
                    "source_labels": [
                        "__meta_kubernetes_pod_container_name",
                        "__meta_kubernetes_pod_container_port_number"
                    ]
                },
                {
                    "replacement": "spark-operator",
                    "target_label": "subservice"
                },
                {
                    "replacement": kingdom,
                    "target_label": "datacenter"
                },
                {
                    "replacement": estate,
                    "target_label": "estate"
                },
                {
                    "source_labels": [
                        "__meta_kubernetes_pod_node_name"
                    ],
                    "target_label": "device"
               }
            ],
            "scrape_interval": "60s",
            "tls_config": {
               "ca_file": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
            }
        },
        {
            "bearer_token_file": "/var/run/secrets/kubernetes.io/serviceaccount/token",
            "job_name": "prometheus_metrics",
            "kubernetes_sd_configs": [
                {
                    "role": "pod",
                     "namespaces": {
                         "names": [
                             "flowsnake"
                         ]
                    },
                }
            ],
            "relabel_configs": [
              {
                  "action": "keep",
                  "source_labels": [
                      "__meta_kubernetes_pod_label_flowsnakeRole",
                      "__meta_kubernetes_pod_container_name",
                  ],
                  "regex": "PrometheusScraper;prometheus"
              },
              {
                  "replacement": "prometheus",
                  "target_label": "subservice"
              },
              {
                  "replacement": kingdom,
                  "target_label": "datacenter"
              },
              {
                  "replacement": estate,
                  "target_label": "estate"
              },
              {
                  "source_labels": [
                      "__meta_kubernetes_pod_node_name"
                  ],
                  "target_label": "device"
              }
            ],
            "scrape_interval": "60s",
            "tls_config": {
                "ca_file": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
            }
        },
        {
            "bearer_token_file": "/var/run/secrets/kubernetes.io/serviceaccount/token",
            "job_name": "kube_state_metrics",
            "kubernetes_sd_configs": [
                {
                    "role": "pod",
                    "namespaces": {
                        "names": [
                            "kube-system"
                        ]
                    },
                }
            ],
            "relabel_configs": [
                {
                    "action": "keep",
                    "source_labels": ["__meta_kubernetes_pod_container_name","__meta_kubernetes_pod_container_port_number"],
                    "regex": "kube-state-metrics;8080"
                },
            ],
            "metric_relabel_configs": [
                { "regex": "instance",
                  "action": "labeldrop"
                },
                { "source_labels": ["pod"],
                  "target_label": "pod_name"
                },
                { "regex": "pod",
                  "action": "labeldrop"
                },
                { "source_labels": ["node"],
                  "target_label": "device"
                },
                { "regex": "node",
                  "action": "labeldrop"
                },
                { "source_labels": ["service"],
                  "target_label": "spark_service",
                },
                { "regex": "service",
                  "action": "labeldrop"
                },
            ],
            "scrape_interval": "60s",
            "tls_config": {
              "ca_file": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
            }
        },
        {
            "job_name": "etcd",
            "static_configs": [
                {
                    "targets": [h.hostname + ":2379" for h in hosts.hosts if h.estate == estate && h.kingdom == kingdom && h.devicerole == "samkubeapi"],
                },
            ],
            "scheme": "https",
            "tls_config": {
                "ca_file": "/certs/ca/cabundle.pem",
                "cert_file": "/certs/client/certificates/client.pem",
                "key_file": "/certs/client/keys/client-key.pem",
            }
        },
        {
            "job_name": "kubernetes-apiserver",
            "static_configs": [
                {
                    "targets": [h.hostname + ":6443" for h in hosts.hosts if h.estate == estate && h.kingdom == kingdom && h.devicerole == "samkubeapi"],
                },
            ],
            "scheme": "https",
            "tls_config": {
                "ca_file": "/etc/pki_service/kubernetes/k8s-client/certificates/k8s-client.pem",
                "cert_file": "/etc/pki_service/kubernetes/k8s-client/certificates/k8s-client.pem",
                "key_file": "/etc/pki_service/kubernetes/k8s-client/keys/k8s-client-key.pem",
            },
        },
    ]
}
