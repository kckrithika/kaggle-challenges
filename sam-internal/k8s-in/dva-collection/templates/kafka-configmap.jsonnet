local configs = import "config.jsonnet";

if configs.kingdom == "mvp" then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "kafka-cm",
        namespace: "sam-system",
        labels: {} + configs.pcnEnableLabel
    },
    data: {
        "broker.vip": "ajna-kafka.ajnalocal1.vip.core.test.us-central2.gcp.sfdc",
        "generic_topic": "sfdc.test.rsyslog__gcp.us-central1.core.ajnalocal1__logs.sam",
        "solr_topic": "sfdc.test.rsyslog__gcp.us-central1.core.ajnalocal1__logs.solr"
    },
} else "SKIP"