local hosts = import "hosts.jsonnet";

{
    global: {
        scrape_interval: "15s",
        scrape_timeout: "10s",
        evaluation_interval: "15s",
    },
    scrape_configs: [
        {
            job_name: "sloop",
            metrics_path: "/metrics",
            scheme: "http",
            static_configs: [
              {
                targets: [
                    "localhost:8080",
                ],
              },
            ],
        },
    ],
}
