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
    ]
}
