local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";

if configs.estate == "prd-sdc" || configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "slb-canary",
        },
        name: "slb-canary",
        namespace: "sam-system",
    },
    spec: {
        replicas: 2,
        template: {
            metadata: {
                labels: {
                    name: "slb-canary",
                },
                namespace: "sam-system",
            },
            spec: {
                hostNetwork: true,
                volumes: configs.filter_empty([
                    slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: "slb-canary",
                        image: slbimages.hypersdn,
                        command: [
                            "/sdn/slb-canary-service",
                            "--serviceName=" + slbconfigs.canaryServiceName,
                            "--metricsEndpoint=" + configs.funnelVIP,
                            "--log_dir=" + slbconfigs.logsDir,
                            "--ports=" + portconfigs.slb.canaryServicePort,
                            "--tlsPorts=" + portconfigs.slb.canaryServiceTlsPort,
                            "--privateKey=/var/slb/canarycerts/server.key",
                        ]
                        + (
                           if configs.estate == "prd-sdc" then [
                            "--publicKey=/var/slb/canarycerts/sdc.crt",
                           ] else [
                            "--publicKey=/var/slb/canarycerts/sam.crt",
                           ]
                          ),

                        volumeMounts: configs.filter_empty([
                            slbconfigs.logs_volume_mount,
                        ]),
                    }
                    + (
                        if configs.estate == "prd-sdc" then {
                            livenessProbe: {
                                httpGet: {
                                    path: "/",
                                    port: portconfigs.slb.canaryServicePort,
                                },
                                initialDelaySeconds: 5,
                                periodSeconds: 3,
                            },
                        }
                        else {
                            securityContext: {
                                privileged: true,
                                capabilities: {
                                    add: [
                                        "ALL",
                                    ],
                                },
                            },
                        }
                       ),
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            } + (
            if configs.estate == "prd-sdc" then {
              affinity: {
                nodeAffinity: {
                  requiredDuringSchedulingIgnoredDuringExecution: {
                    nodeSelectorTerms: [
                      {
                        matchExpressions: [
                          {
                            key: "pool",
                            operator: "In",
                            values: [configs.estate],
                          },
                          {
                            key: "slb-service",
                            operator: "NotIn",
                            values: ["slb-ipvs", "slb-nginx"],
                          },
                        ] + (
                            if configs.estate == "prd-sdc" then
                            [
                              {
                                key: "illumio",
                                operator: "NotIn",
                                values: ["b"],
                              },
                            ] else []
                          ),
                      },
                    ],
                  },
                },
              },
            } else {}
          ),
        },
    },
} else "SKIP"
