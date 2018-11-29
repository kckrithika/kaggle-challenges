# This is the configmap template for prometheus service used for resource monitoring
local hosts = import "hosts.jsonnet";
local configs = import "config.jsonnet";

{
    global: {
        scrape_interval: "60s",
        scrape_timeout: "30s",
        evaluation_interval: "30s",
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
            job_name: "kube-state-metrics",
                scheme: "http",
                static_configs: [
                {
                   targets: [
                      "kube-state-metrics.kube-system:8080",
                   ],
                },
                ],
        },
    ],
}
