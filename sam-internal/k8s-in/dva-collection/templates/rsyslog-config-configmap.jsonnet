local configs = import "config.jsonnet";
local rsyslogConf = importstr "configs/rsyslog.conf";
local generalConf = importstr "configs/general.conf.erb";
local containerConf = importstr "configs/container.conf.erb";
local journalConf = importstr "configs/journal.conf.erb";
local casamConf = importstr "configs/core.conf.erb";
local manifestsYaml = importstr "configs/manifests.yaml.erb";

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
        // "solr.conf.erb": solrConf,
        // "jetty.conf.erb": jettyConf,
        "core.conf.erb": casamConf,
        // "jvm.conf.erb": casamjvmConf,
        // "jvmgc.conf.erb": casamjvmgcConf,
        "manifests.yaml": manifestsYaml,
    },
} else "SKIP"
