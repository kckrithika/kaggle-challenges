local configs = import "config.jsonnet";
local rsyslogConf = importstr "configs/rsyslog.conf";
local generalConf = importstr "configs/general.conf.erb";
local containerConf = importstr "configs/container.conf.erb";
local journalConf = importstr "configs/journal.conf.erb";
local solrConf = importstr "configs/solr/solr.conf.erb";
local jettyConf = importstr "configs/solr/jetty.conf.erb";

if configs.kingdom == "mvp" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "rsyslog-configmap",
        namespace: "sam-system",
        labels: {} + configs.pcnEnableLabel
    },
    data: {
        "rsyslog.conf": rsyslogConf,
        "general.conf.erb": generalConf,
        "container.conf.erb": containerConf,
        "journal.conf.erb": journalConf,
        "solr.conf.erb": solrConf,
        "jetty.conf.erb": jettyConf
    },
} else "SKIP"