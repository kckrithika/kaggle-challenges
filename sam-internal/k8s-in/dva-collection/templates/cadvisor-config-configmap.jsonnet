local configs = import "config.jsonnet";
local rsyslogConf = importstr "configs/cadvisor/rsyslog.conf";
local scraperYaml = importstr "configs/cadvisor/scraper.yaml.erb";
local forwarderConf = importstr "configs/cadvisor/forwarder.conf.erb";

if configs.kingdom == "mvp" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "cadvisor-configmap",
        namespace: "sam-system",
        labels: {} + configs.pcnEnableLabel,
    },
    data: {
        "rsyslog.conf": rsyslogConf,
        "scraper.yaml.erb": scraperYaml,
        "forwarder.conf.erb": forwarderConf,
    },
} else "SKIP"
