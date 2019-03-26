local configs = import "config.jsonnet";
local rsyslogConf = importstr "configs/rsyslog/rsyslog.conf";
local generalConf = importstr "configs/rsyslog/general.conf.erb";
local containerConf = importstr "configs/rsyslog/container.conf.erb";
local journalConf = importstr "configs/rsyslog/journal.conf.erb";
local casamConf = importstr "configs/rsyslog/core.conf.erb";
local manifestsYaml = importstr "configs/rsyslog/manifests.yaml.erb";

if configs.kingdom == "mvp" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "rsyslog-configmap",
        namespace: "sam-system",
        labels: {} + configs.pcnEnableLabel,
    },
    data: {
        "rsyslog.conf": rsyslogConf,
        "general.conf.erb": generalConf,
        "container.conf.erb": containerConf,
        "journal.conf.erb": journalConf,
        "core.conf.erb": casamConf,
        "manifests.yaml": manifestsYaml,
    },
} else "SKIP"
