local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
            labels: {
                name: "slb-nginxdata-watchdog",
            },
            name: "slb-nginxdata-watchdog",
            namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            spec: {
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    slbconfigs.slb_volume,
                    slbconfigs.logs_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    configs.sfdchosts_volume,
                 ]),
                containers: [
                    {
                        name: "slb-nginxdata-watchdog",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-nginxdata-watchdog",
                            "--funnelEndpoint=" + configs.funnelVIP,
                            "--archiveSvcEndpoint=" + configs.tnrpArchiveEndpoint,
                            "--smtpServer=" + configs.smtpServer,
                            "--sender=" + slbconfigs.sdn_watchdog_emailsender,
                            "--recipient=" + slbconfigs.sdn_watchdog_emailrec,
                            "--emailFrequency=12h",
                            "--watchdogFrequency=180s",
                            "--alertThreshold=300s",
                            "--k8sapiserver=",
                            "--connPort=" + portconfigs.slb.slbConfigDataPort,
                            "--retryPeriod=2m",
                            "--maxretries=2",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--namespace=sam-system",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--hostname=$(NODE_NAME)",
                            configs.sfdchosts_arg,
                        ],
                        volumeMounts: configs.filter_empty([
                            configs.maddog_cert_volume_mount,
                            slbconfigs.slb_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.cert_volume_mount,
                            configs.kube_config_volume_mount,
                            configs.sfdchosts_volume_mount,
                         ]),
                         env: [
                            {
                               name: "NODE_NAME",
                               valueFrom: {
                                   fieldRef: {
                                       fieldPath: "spec.nodeName",
                                   },
                               },
                            },
                            configs.kube_config_env,
                        ],
                    },
                ],
                nodeSelector: {
                                    pool: configs.estate,
                },
            },
            metadata: {
                labels: {
                    name: "slb-nginxdata-watchdog",
                    apptype: "monitoring",
                },
                namespace: "sam-system",
            },
        },
    },
} else "SKIP"
