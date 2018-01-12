local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = import "slbimages.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
            labels: {
                name: "slb-vip-watchdog",
            },
            name: "slb-vip-watchdog",
           namespace: "sam-system",
                    annotations: {
                             "scheduler.alpha.kubernetes.io/affinity": "{   \"nodeAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": {\n      \"nodeSelectorTerms\": [\n        {\n          \"matchExpressions\": [\n            {\n              \"key\": \"slb-service\",\n              \"operator\": \"NotIn\",\n              \"values\": [\"slb-ipvs\", \"slb-nginx\"]\n            }\n          ]\n        }\n      ]\n    }\n  }\n}\n",
                    },
     },
    spec: {
        replicas: 1,
        template: {
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                   slbconfigs.slb_volume,
                   slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-vip-watchdog",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-vip-watchdog",
                            "--configDir=" + slbconfigs.configDir,
                            "--funnelEndpoint=" + configs.funnelVIP,
                            "--archiveSvcEndpoint=" + configs.tnrpArchiveEndpoint,
                            "--smtpServer=" + configs.smtpServer,
                            "--sender=" + slbconfigs.sdn_watchdog_emailsender,
                            "--recipient=" + slbconfigs.sdn_watchdog_emailrec,
                            "--emailFrequency=12h",
                            "--watchdogFrequency=60s",
                            "--alertThreshold=700s",
                            "--vipLoop=10",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--optOutNamespace=kne",
                        ],
                        volumeMounts: configs.filter_empty([
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                        ]),
                    },
                ],
                nodeSelector: {
                                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "slb-vip-watchdog",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
    },
} else "SKIP"
