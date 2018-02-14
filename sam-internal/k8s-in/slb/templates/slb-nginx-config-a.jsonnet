local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-nginx-config-a",
        },
        name: "slb-nginx-config-a",
        namespace: "sam-system",
    },
    spec: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "slb-nginx-config-a",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                     {
                        name: "var-target-config-volume",
                        hostPath: {
                            path: slbconfigs.slbDockerDir + "/nginx/config",
                         },
                     },
                     slbconfigs.slb_config_volume,
                     slbconfigs.logs_volume,
                     configs.sfdchosts_volume,
                ]),
                containers: [
                    {
                        ports: [
                             {
                                name: "slb-nginx-port",
                                containerPort: portconfigs.slb.slbNginxControlPort,
                             },
                        ],
                        name: "slb-nginx-config-a",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-nginx-config",
                            "--configDir=" + slbconfigs.configDir,
                            "--target=" + slbconfigs.slbDir + "/nginx/config",
                            "--netInterfaceName=eth0",
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            "--maxDeleteServiceCount=3",
                            configs.sfdchosts_arg,
                            "--httpsEnabled="
                             + "slb-canary-proxy-http.sam-system." + configs.estate + ".prd.slb.sfdc.net",
                        ],
                        volumeMounts: configs.filter_empty([
                            {
                                name: "var-target-config-volume",
                                mountPath: slbconfigs.slbDir + "/nginx/config",
                            },
                            slbconfigs.slb_config_volume_mount,
                            slbconfigs.logs_volume_mount,
                            configs.sfdchosts_volume_mount,
                        ]),
                        securityContext: {
                            privileged: true,
                        },
                   },
                   {
                                             name: "slb-nginx-proxy-a",
                                             image: slbimages.slbnginx,
                                             command: ["/runner.sh"],
                                             livenessProbe: {
                                             httpGet: {
                                                 path: "/",
                                                 port: portconfigs.slb.slbNginxProxyLivenessProbePort,
                                             },
                                             initialDelaySeconds: 15,
                                             periodSeconds: 10,
                                             },
                                             volumeMounts: configs.filter_empty([
                                             {
                                                 name: "var-target-config-volume",
                                                 mountPath: "/etc/nginx/conf.d",
                                             },
                                             slbconfigs.logs_volume_mount,
                                             ]),
                                         },
                                     {
                                         name: "slb-file-watcher",
                                         image: slbimages.hypersdn,
                                         command: [
                                             "/sdn/slb-file-watcher",
                                             "--filePath=/host/data/slb/logs/slb-nginx-proxy.emerg.log",
                                             "--metricName=nginx-emergency",
                                             "--lastModReportTime=120s",
                                             "--scanPeriod=10s",
                                             "--skipZeroLengthFiles=true",
                                             "--metricsEndpoint=" + configs.funnelVIP,
                                             "--log_dir=" + slbconfigs.logsDir,
                                             configs.sfdchosts_arg,
                                         ],
                                     volumeMounts: configs.filter_empty([
                                         {
                                             name: "var-target-config-volume",
                                             mountPath: "/etc/nginx/conf.d",
                                         },
                                         slbconfigs.logs_volume_mount,
                                         configs.sfdchosts_volume_mount,
                                     ]),
                                     },
                   ],

                nodeSelector: {
                    "slb-service": "slb-nginx-a",
                },
            },
        },
    },
} else "SKIP"
