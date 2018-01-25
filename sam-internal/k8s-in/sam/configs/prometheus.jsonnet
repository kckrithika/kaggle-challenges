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
      job_name: "prometheus",
      scrape_interval: "15s",
      scrape_timeout: "10s",
      metrics_path: "/metrics",
      scheme: "http",
      static_configs: [
        {
          targets: [
            "localhost:9090",
          ],
        },
      ],
    },
    {
      job_name: "test-etcd",
      static_configs: [
        {
          targets: [h.hostname for h in hosts.hosts if h.estate == std.extVar("estate") && h.kingdom == std.extVar("kingdom") && h.devicerole == "samkubeapi"],
        },
      ],
      scheme: "https",
      tls_config: {
        ca_file: "/etc/pki_service/ca/cabundle.pem",
        cert_file: "/etc/pki_service/etcd/etcd-client/certificates/etcd-client.pem",
        key_file: "/etc/pki_service/etcd/etcd-client/keys/etcd-client-key.pem",
      },
    },
  ],
}
