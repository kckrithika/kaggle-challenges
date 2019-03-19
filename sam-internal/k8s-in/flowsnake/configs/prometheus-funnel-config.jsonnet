local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");

{
    "global": {
        "scrape_interval": "60s"
    },
    "remote_write": [
        {
            "url": "http://localhost:8000"
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
        /*
        {
          "bearer_token_file": "/var/run/secrets/kubernetes.io/serviceaccount/token",
          "job_name": "pod_metrics",
          "scheme": "https",
          "kubernetes_sd_configs": [
            {
              "role": "node"
            }
          ],
          "relabel_configs": [
              { "target_label": "__address__",
                "replacement": "kubernetes.default.svc:443",
              },
              {
                "source_labels": [
                  "__meta_kubernetes_node_name"
                ],
                "replacement": "/api/v1/nodes/${1}/proxy/metrics/cadvisor",
                "target_label": "__metrics_path__",
              },
                {
                  "source_labels": [
                    "__meta_kubernetes_node_name"
                  ],
                  "target_label": "device"
                }
          ],
          "metric_relabel_configs": [
                { "source_labels": ["namespace"],
                  "action": "keep",
                  "regex" : "flowsnake*"
                },
                { "regex": "id",
                  "action": "labeldrop"
                },
                { "regex": "image",
                  "action": "labeldrop"
                },
                { "regex": "instance",
                  "action": "labeldrop"
                },
                { "regex": "interface",
                  "action": "labeldrop"
                },
                { "regex": "name",
                  "action": "labeldrop"
                },
                { "source_labels": ["pod_name"],
                  "target_label": "pod_name",
                  "regex": "([a-z0-9-]*)-[a-z0-9]*",
                  "replacement": "${1}"
                },
                { "source_labels": ["flowsnakeRole"],
                  "target_label": "subservice"
                },
                { "source_labels": ["flowsnakeEnvironmentName"],
                  "target_label": "flowsnake_environment"
                },
                { "source_labels": ["flowsnakeOwner"],
                  "target_label": "owner"
                }
          ],
          "scrape_interval": "60s",
          "tls_config": {
            "ca_file": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
          }
        }
        */
    ]
}