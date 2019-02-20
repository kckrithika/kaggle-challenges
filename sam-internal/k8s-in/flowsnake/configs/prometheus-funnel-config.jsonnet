local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");

{
   "global": {
      "scrape_interval": "60s"
   },
   "remote_write": {
      "url": "http://localhost:8000"
   },
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
               "replacement": "NONE",
               "target_label": "superpod"
            },
            {
               "source_labels": [
                  "__meta_kubernetes_pod_node_name"
               ],
               "target_label": "device"
            }
         ],
         "scheme": "http",
         "scrape_interval": "15s",
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
               "source_labels": [
                  "__meta_kubernetes_pod_node_name"
               ],
               "target_label": "device"
            }
         ],
         "scheme": "http",
         "scrape_interval": "60s",
         "tls_config": {
            "ca_file": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
         }
      },
      {
         "bearer_token_file": "/var/run/secrets/kubernetes.io/serviceaccount/token",
         "job_name": "fs_metrics",
         "kubernetes_sd_configs": [
            {
               "role": "pod"
            }
         ],
         "relabel_configs": [
            {
               "action": "keep",
               "regex": "(.+)",
               "source_labels": [
                  "__meta_kubernetes_pod_label_flowsnakeEnvironmentName"
               ]
            },
            {
               "action": "replace",
               "regex": "(.+)",
               "source_labels": [
                  "__meta_kubernetes_pod_label_flowsnakeEnvironmentName"
               ],
               "target_label": "flowsnake_environment"
            },
            {
               "action": "replace",
               "regex": "(.+)",
               "source_labels": [
                  "__meta_kubernetes_pod_label_flowsnakeOwner"
               ],
               "target_label": "owner"
            },
            {
               "action": "replace",
               "regex": "(.+)",
               "source_labels": [
                  "__meta_kubernetes_pod_node_name"
               ],
               "target_label": "device"
            },
            {
               "action": "replace",
               "regex": "(.+)",
               "source_labels": [
                  "__meta_kubernetes_pod_label_app"
               ],
               "target_label": "container_role"
            }
         ],
         "scheme": "http",
         "scrape_interval": "60s",
         "tls_config": {
            "ca_file": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
         }
      }
   ]
}