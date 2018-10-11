local configs = import "config.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local portconfigs = import "portconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";

local slbCanaryTlsPublicKeyPath =
    if configs.estate == "prd-sdc" then
        "/var/slb/canarycerts/sdc.crt"
    else
        "/var/slb/canarycerts/sam.crt";

local slbCanaryTlsPrivateKeyPath = "/var/slb/canarycerts/server.key";

// All of these temp_ functions define overrides for small differences between the canaries that should be phased out over time.
// The "slbimages.phaseNum > n" portion will be updated to eliminate these differences in a phased approach.
local temp_getServiceNameParam(canaryName) = (
    if slbimages.phaseNum > 0 then
        if canaryName == "slb-bravo" then "slb-bravo-svc"
        else if canaryName == "slb-canary" then "slb-canary-service"
        else canaryName
    else canaryName
);

local temp_getContainerNameParam(canaryName) = (
    if canaryName == "slb-canary-proxy-tcp-host" && slbimages.phaseNum > 0 then "slb-canary-proxy-tcp" else canaryName
);

local temp_getContainerSecurityContext(canaryName) = (
    if canaryName == "slb-canary" && configs.estate != "prd-sdc" && slbimages.phaseNum > 0 then {
        securityContext: {
            privileged: true,
            capabilities: {
                add: [
                    "ALL",
                ],
            },
        },
    } else {}
);

local temp_useIPVSPodAntiaffinity(canaryName) = (
    // Unclear why these services anti-affinitize to ipvs everywhere, but they probably don't need to.
    slbimages.phaseNum > 0 && (
        canaryName == "slb-canary-proxy-tcp-host" ||
        canaryName == "slb-canary-proxy-tcp" ||
        canaryName == "slb-canary-passthrough-tls"
    )
);

local ipvsPodAntiAffinity(canaryName) = (
    if configs.estate == "prd-sdc" || temp_useIPVSPodAntiaffinity(canaryName) then {
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

local temp_useIPVSNodeAntiAffinity(canaryName) = (
    configs.estate == "prd-sdc" && (
        canaryName == "slb-bravo" ||
        canaryName == "slb-canary-passthrough-host-network" ||
        canaryName == "slb-canary-proxy-http" ||
        canaryName == "slb-canary"
    )
);

local temp_ipvsNodeAntiAffinityExpression(canaryName) = (
    if temp_useIPVSNodeAntiAffinity(canaryName) then [{
        key: "slb-service",
        operator: "NotIn",
        values: ["slb-ipvs"],
    }] else []
);

local temp_useIllumioNodeAntiAffinity() = (
    configs.estate == "prd-sdc"
);

local temp_illumioNodeAntiAffinityExpression() = (
    if temp_useIllumioNodeAntiAffinity() then [{
        key: "illumio",
        operator: "NotIn",
        values: ["a", "b"],
    }] else []
);

local fieldIfNonEmpty(name, object, value=object) = {
    [if std.length(object) > 0 then name]: value,
};

local getPodAffinity(canaryName) = (
    ipvsPodAntiAffinity(canaryName)
);

local temp_getNodeAffinity(canaryName) = (
    local matchExpressions = temp_ipvsNodeAntiAffinityExpression(canaryName) + temp_illumioNodeAntiAffinityExpression();
    fieldIfNonEmpty("nodeAffinity", matchExpressions, {
        requiredDuringSchedulingIgnoredDuringExecution: {
            nodeSelectorTerms: [{
                matchExpressions: matchExpressions,
            }]
        }
    })
);

local getAffinity(canaryName) = (
    local affinity = getPodAffinity(canaryName) + temp_getNodeAffinity(canaryName);
    fieldIfNonEmpty("affinity", affinity)
);

local getCanaryLivenessProbe(port) = (
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
                        name: temp_getContainerNameParam(canaryName),
                        image: slbimages.hypersdn,
                        [if !hostNetwork && configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
                        command: std.prune([
                                     "/sdn/slb-canary-service",
                                     "--serviceName=" + temp_getServiceNameParam(canaryName),
                                     "--log_dir=" + slbconfigs.logsDir,
                                     "--ports=" + std.join(",", ports),
                                 ]
                                 + ( // mix in tls config (if specified).
                                     if tlsPorts != null then std.prune([
                                         "--tlsPorts=" + std.join(",", tlsPorts),
                                         "--privateKey=" + slbCanaryTlsPrivateKeyPath,
                                         // verbose is mixed in here because that's the way slb-canary-proxy-http currently orders it. *shrug*.
                                         if !verbose then "--verbose=false",
                                         "--publicKey=" + slbCanaryTlsPublicKeyPath,
                                     ]) else []
                                 )
                                 + ( // mix in proxy protocol ports (if specified).
                                    if proxyProtocolPorts != null then [
                                        "--proxyProtocolPorts=" + std.join(",", proxyProtocolPorts),
                                    ] else []
                                 )),

                        volumeMounts: configs.filter_empty([
                            slbconfigs.logs_volume_mount,
                        ]),
                    }
                    + getCanaryLivenessProbe(ports[0])
                    + temp_getContainerSecurityContext(canaryName),
                ],
                nodeSelector: {
                    pool: configs.estate,
                },
            } + getAffinity(canaryName)
            + slbflights.getDnsPolicy(),
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