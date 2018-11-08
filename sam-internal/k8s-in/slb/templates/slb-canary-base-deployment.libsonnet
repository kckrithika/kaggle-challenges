local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";
local utils = import "util_functions.jsonnet";

local slbCanaryTlsPublicKeyPath =
    if configs.estate == "prd-sdc" then
        "/var/slb/canarycerts/sdc.crt"
    else
        "/var/slb/canarycerts/sam.crt";

local slbCanaryTlsPrivateKeyPath = "/var/slb/canarycerts/server.key";

local ipvsPodAntiAffinity(canaryName) = (
    if configs.estate == "prd-sdc" then {
        podAntiAffinity+: {
            requiredDuringSchedulingIgnoredDuringExecution: [{
                labelSelector: {
                    matchExpressions: [{
                        key: "name",
                        operator: "In",
                        values: [
                            "slb-ipvs",
                            "slb-ipvs-a",
                            "slb-ipvs-b",
                            "slb-vip-watchdog",
                        ],
                    }],
                },
                topologyKey: "kubernetes.io/hostname",
            }],
        },
    } else {}
);

local ipvsNodeAntiAffinity(canaryName) = (
    if configs.estate == "prd-sdc" then {
        nodeAffinity+: {
        requiredDuringSchedulingIgnoredDuringExecution: {
            nodeSelectorTerms: [{
                matchExpressions: [{
                    key: "slb-service",
                    operator: "NotIn",
                    values: ["slb-ipvs"],
                }],
            }],
        },
    },
    } else {}
);

local getPodAffinity(canaryName) = (
    ipvsPodAntiAffinity(canaryName) + ipvsNodeAntiAffinity(canaryName)
);

local getAffinity(canaryName) = (
    local podAffinity = getPodAffinity(canaryName);
    utils.fieldIfNonEmpty("affinity", podAffinity)
);

local getCanaryLivenessProbe(port) = (
    // TODO: phase in this liveness probe everywhere.
    if configs.estate == "prd-sdc" then {
        livenessProbe: {
            httpGet: {
                path: "/",
                port: port,
            },
            initialDelaySeconds: 15,
            periodSeconds: 10,
        },
    }
    else {}
);

{
    slbCanaryBaseDeployment(
        canaryName,
        ports,
        tlsPorts = null,
        proxyProtocolPorts = null,
        replicas = 2,
        hostNetwork = false,
        verbose = true,
    ):: configs.deploymentBase("slb") {

      metadata: {
          labels: {
              name: canaryName,
          } + configs.ownerLabel.slb,
          name: canaryName,
          namespace: "sam-system",
      },
      spec+: {
        replicas: replicas,
        template: {
            metadata: {
                labels: {
                    name: canaryName,
                } + configs.ownerLabel.slb,
                namespace: "sam-system",
            },
            spec: {
                [if hostNetwork then "hostNetwork"]: true,
                volumes: configs.filter_empty([
                    slbconfigs.logs_volume,
                ]),
                containers: [
                    {
                        name: canaryName,
                        image: slbimages.hypersdn,
                        [if !hostNetwork && configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
                        command: std.prune([
                                     "/sdn/slb-canary-service",
                                     "--serviceName=" + canaryName,
                                     "--log_dir=" + slbconfigs.logsDir,
                                     "--ports=" + std.join(",", [std.toString(port) for port in ports]),
                                 ]
                                 + ( // mix in tls config (if specified).
                                     if tlsPorts != null && std.length(tlsPorts) > 0 then std.prune([
                                         "--tlsPorts=" + std.join(",", [std.toString(port) for port in tlsPorts]),
                                         "--privateKey=" + slbCanaryTlsPrivateKeyPath,
                                         // verbose is mixed in here because that's the way slb-canary-proxy-http currently orders it. *shrug*.
                                         if !verbose then "--verbose=false",
                                         "--publicKey=" + slbCanaryTlsPublicKeyPath,
                                     ]) else []
                                 )
                                 + ( // mix in proxy protocol ports (if specified).
                                    if proxyProtocolPorts != null && std.length(proxyProtocolPorts) > 0 then [
                                        "--proxyProtocolPorts=" + std.join(",", [std.toString(port) for port in proxyProtocolPorts]),
                                    ] else []
                                 )),

                        volumeMounts: configs.filter_empty([
                            slbconfigs.logs_volume_mount,
                        ]),
                    }
                    + getCanaryLivenessProbe(ports[0])
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            } + slbconfigs.getGracePeriod()
              + getAffinity(canaryName)
              + slbconfigs.getDnsPolicy(),
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
    }
}