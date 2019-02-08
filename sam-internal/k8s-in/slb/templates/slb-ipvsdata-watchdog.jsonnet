local configs = import "config.jsonnet";
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: "slb-ipvsdata-watchdog" };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: "slb-ipvsdata-watchdog" };
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: "slb-ipvsdata-watchdog" };

if configs.estate == "prd-sdc" || slbconfigs.isProdEstate then configs.deploymentBase("slb") {
    metadata: {
        labels: {
            name: "slb-ipvsdata-watchdog",
        } + configs.ownerLabel.slb,
        name: "slb-ipvsdata-watchdog",
        namespace: "sam-system",
        annotations: {
            "scheduler.alpha.kubernetes.io/affinity": "{   \"nodeAffinity\": {\n    \"requiredDuringSchedulingIgnoredDuringExecution\": {\n      \"nodeSelectorTerms\": [\n        {\n          \"matchExpressions\": [\n            {\n              \"key\": \"slb-service\",\n              \"operator\": \"NotIn\",\n              \"values\": [\"slb-ipvs\", \"slb-nginx\"]\n            }\n          ]\n        }\n      ]\n    }\n  }\n}\n",
        },
    },
    spec+: {
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
                    slbconfigs.slb_config_volume,
                    slbconfigs.cleanup_logs_volume,
                ]),
                containers: std.prune([
                    {
                        name: "slb-ipvsdata-watchdog",
                        image: slbimages.hyperslb,
                        [if configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
                        command: [
                            "/sdn/slb-ipvs-data-watchdog",
                            "--log_dir=" + slbconfigs.logsDir,
                            "--namespace=sam-system",
                            configs.sfdchosts_arg,
                            "--k8sapiserver=",
                            "--connPort=" + portconfigs.slb.ipvsDataConnPort,
                            ] + (
                                if slbimages.phaseNum <= 1 then
                                 [
                                     "--monitorFrequency=10s",
                                 ] else
                                 [
                                     "--monitorFrequency=180s",
                                 ]
                            ) + [
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--hostnameOverride=$(NODE_NAME)",
                            "--ignoreWeightsInConsistencyCheck=true",
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
                            slbconfigs.node_name_env,
                            configs.kube_config_env,
                        ],
                    },
                    slbshared.slbLogCleanup,
                ]),
            } + slbconfigs.getGracePeriod()
              + slbconfigs.getDnsPolicy()
              + slbconfigs.slbEstateNodeSelector,
            metadata: {
                labels: {
                    name: "slb-ipvsdata-watchdog",
                    apptype: "monitoring",
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
        },
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 1,
            },
        },
        minReadySeconds: 30,
    },
} else "SKIP"
