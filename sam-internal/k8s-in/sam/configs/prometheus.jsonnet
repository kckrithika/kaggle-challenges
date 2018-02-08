local hosts = import "hosts.jsonnet";

{
  global: {
    scrape_interval: "15s",
    scrape_timeout: "10s",
    evaluation_interval: "15s",
  },
  alerting: {
    alertmanagers: [
      {
        static_configs: [
          {
            targets: [

            ],
          },
        ],
        scheme: "http",
        timeout: "10s",
      },
    ],
  },
  scrape_configs: [
    {
      job_name: "etcd",
      static_configs: [
        {
          targets: [h.hostname + ":2379" for h in hosts.hosts if h.estate == std.extVar("estate") && h.kingdom == std.extVar("kingdom") && h.devicerole == "samkubeapi"],
        },
      ],
      scheme: "https",
      tls_config: {
        ca_file: "/etc/pki_service/ca/cabundle.pem",
        cert_file: "/etc/pki_service/etcd/etcd-client/certificates/etcd-client.pem",
        key_file: "/etc/pki_service/etcd/etcd-client/keys/etcd-client-key.pem",
      },
    },
    # We dont use kube discovery for API servers because the UI shows the instance by IP not hostname.  Use jsonnet since we have it.a
    {
      job_name: "kubernetes-apiserver",
      static_configs: [
        {
          targets: [h.hostname + ":6443" for h in hosts.hosts if h.estate == std.extVar("estate") && h.kingdom == std.extVar("kingdom") && h.devicerole == "samkubeapi"],
        },
      ],
      scheme: "https",
      tls_config: {
        ca_file: "/etc/pki_service/ca/cabundle.pem",
        cert_file: "/etc/pki_service/kubernetes/k8s-client/certificates/k8s-client.pem",
        key_file: "/etc/pki_service/kubernetes/k8s-client/keys/k8s-client-key.pem",
      },
    },
    # We dont use kube discovery for API servers because the UI shows the instance by IP not hostname.  Use jsonnet since we have it.a
    {
      job_name: "kubernetes-controller-manager",
      static_configs: [
        {
          targets: [h.hostname + ":10252" for h in hosts.hosts if h.estate == std.extVar("estate") && h.kingdom == std.extVar("kingdom") && h.devicerole == "samkubeapi"],
        },
      ],
      scheme: "http",
    },
    # We dont use kube discovery for API servers because the UI shows the instance by IP not hostname.  Use jsonnet since we have it.a
    {
      job_name: "kubernetes-scheduler",
      static_configs: [
        {
          targets: [h.hostname + ":10251" for h in hosts.hosts if h.estate == std.extVar("estate") && h.kingdom == std.extVar("kingdom") && h.devicerole == "samkubeapi"],
        },
      ],
      scheme: "http",
    },
    # Followed example here: https://github.com/prometheus/prometheus/blob/release-2.1/documentation/examples/prometheus-kubernetes.yml
    # Rather than connecting directly to the node, the scrape is proxied though the
    # Kubernetes apiserver.  This means it will work if Prometheus is running out of
    # cluster, or can't connect to nodes for some other reason (e.g. because of
    # firewalling).
    {
      job_name: "kubernetes-kubelet",
      kubernetes_sd_configs: [{
        # This needs to be the same hostname that we are running on.  We can't use localhost or 127.0.0.1 because the certs wont match
        # Keep this in sync with host selector in ../templates/prometheus.jsonnet
        # Yes this is ugly, we need a better solution
        api_server: ([h.hostname for h in hosts.hosts if h.controlestate == std.extVar("estate") && h.kingdom == std.extVar("kingdom") && std.endsWith(std.split(h.hostname, "-")[1], "kubeapi2")][0]) + ":8000",
        role: "node",
        tls_config: {
         ca_file: "/etc/pki_service/ca/cabundle.pem",
          cert_file: "/etc/pki_service/kubernetes/k8s-client/certificates/k8s-client.pem",
          key_file: "/etc/pki_service/kubernetes/k8s-client/keys/k8s-client-key.pem",
        },
     }],
      scheme: "https",
      tls_config: {
        ca_file: "/etc/pki_service/ca/cabundle.pem",
        cert_file: "/etc/pki_service/kubernetes/k8s-client/certificates/k8s-client.pem",
        key_file: "/etc/pki_service/kubernetes/k8s-client/keys/k8s-client-key.pem",
      },
      relabel_configs: [
#        {
#          action: "labelmap",
#          regex: "__meta_kubernetes_node_label_(.+)",
#        },
#        {
#          target_label: "__address__",
#          replacement: "kubernetes.default.svc:443",
#        },
#        {
#          source_labels: ["__meta_kubernetes_node_name"],
#          regex: "(.+)",
#          target_label: "__metrics_path__",
#          replacement: "/api/v1/nodes/${1}/proxy/metrics",
#        },
      ],
    },
  ],
}
