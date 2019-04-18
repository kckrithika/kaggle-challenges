local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
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
    ] + (if std.objectHas(flowsnake_images.feature_flags, "ksm_to_prometheus") then
        [{
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
        }] else []
    )
}