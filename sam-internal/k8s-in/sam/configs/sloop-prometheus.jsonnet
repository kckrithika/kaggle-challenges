local configs = import "config.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";
local sloop = import "configs/sloop-config.jsonnet";

local promconfig(estate) = {
    job_name: "sloop-" + estate,
    metrics_path: "/metrics",
    scheme: "http",
    static_configs: [
        {
            targets: [
                "localhost:" + sloop.estateConfigs[estate].containerPort,
            ],
        },
    ],
};

{
    global: {
        scrape_interval: "15s",
        scrape_timeout: "10s",
        evaluation_interval: "15s",
    },
    scrape_configs: [
        promconfig(est)
        for est in samfeatureflags.sloopEstates[configs.estate]
    ],
}
