local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";
local sloop = import "configs/sloop-config.jsonnet";

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
                    "localhost:" + sloop.estateConfigs[est].containerPort
                    for est in samfeatureflags.sloopEstates[configs.estate]
                ] + (if configs.estate != "prd-samtest" then ["localhost:31938"] else []),  // TODO: remove this section once test changes are verified
              },
            ],
        },
    ],
}
