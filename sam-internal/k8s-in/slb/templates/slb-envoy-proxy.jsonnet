local configs = import "config.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbconfigs = (import "slbconfig.jsonnet") + { dirSuffix:: slbconfigs.envoyProxyName };
local portconfigs = import "portconfig.jsonnet";
local slbports = import "slbports.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local slbshared = (import "slbsharedservices.jsonnet") + { dirSuffix:: slbconfigs.envoyProxyName };
local madkub = (import "slbmadkub.jsonnet") + { templateFileName:: std.thisFile, dirSuffix:: slbconfigs.envoyProxyName };
local slbflights = (import "slbflights.jsonnet") + { dirSuffix:: slbconfigs.envoyProxyName };

local slbbasedeployment = (import "slb-base-deployment.libsonnet") + { dirSuffix:: slbconfigs.envoyProxyName };

// cert1 = server cert, cert2 = client cert.
local certDirs = ["cert1", "cert2"];

local sherpaContainer = {
    env: [
        // See https://git.soma.salesforce.com/servicelibs/sherpa-envoy/blob/a075369d86202b459fed04534f8eb913df50f912/launcher/config.go#L170-L174
        // for required environment variables.
        {
            name: "FUNCTION_NAMESPACE",
            valueFrom: {
                fieldRef: {
                    apiVersion: "v1",
                    fieldPath: "metadata.namespace",
                },
            },
        },
        {
            name: "SETTINGS_SUPERPOD",
            value: "None",
        },
        {
            name: "SETTINGS_PATH",
            value: "-.-." + configs.kingdom + ".-." + slbconfigs.envoyProxyName,
        },
    ],
    image: "ops0-artifactrepo2-0-prd.data.sfdc.net/sfci/servicelibs/sherpa-envoy:e6ae1aef47d40fa3d4a184f8a446cb4bb8c90b71",
    imagePullPolicy: "Always",
    name: "sherpa",
    ports: [
        {
            containerPort: 7014,
            name: "http1",
        },
        {
            containerPort: 7442,
            name: "http1-tls",
        },
        {
            containerPort: 15373,
            name: "sherpa-adm",
        },
    ],
    securityContext: {
        runAsNonRoot: true,
        runAsUser: 7447,
    },
    volumeMounts: [
        {
            mountPath: "/client-certs",
            name: "cert2",
        },
        {
            mountPath: "/server-certs",
            name: "cert1",
        },
    ],
};

local nginxContainer = {
    name: slbconfigs.envoyProxyName,
    image: slbimages.slbnginx,
    command: ["nginx", "-g", "daemon off;"],
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
            name: "slb-envoy-nginx-configuration",
            mountPath: "/etc/nginx/conf.d",
        },
        slbconfigs.nginx_logs_volume_mount,
        slbconfigs.slb_volume_mount,
    ] + madkub.madkubSlbCertVolumeMounts(certDirs)),
} + configs.ipAddressResourceRequest;

// Anti-affinitize the proxy to ipvs and to itself -- the proxy can't run on the same node as ipvs.
local affinity = {
    podAntiAffinity: {
        requiredDuringSchedulingIgnoredDuringExecution: [{
            labelSelector: {
                matchExpressions: [{
                    key: "name",
                    operator: "In",
                    values: [
                        "slb-ipvs",
                        slbconfigs.envoyProxyName,
                    ],
                }],
            },
            topologyKey: "kubernetes.io/hostname",
        }],
    },
    // Ensure that the floating nginx pods don't land on nodes allocated to ipvs.
    // This is a stopgap solution until ipvs is made to float as well.
    nodeAffinity: {
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
};

if slbconfigs.isSlbEstate && slbflights.envoyProxyEnabled then
    slbbasedeployment.slbBaseDeployment(
        name=slbconfigs.envoyProxyName,
        replicas=3,
        affinity=affinity,
        beforeSharedContainers=[nginxContainer, sherpaContainer, madkub.madkubRefreshContainer(certDirs)],
    ) {
    spec+: {
        template+: {
            metadata+: {
                annotations+: {
                    "madkub.sam.sfdc.net/allcerts": std.manifestJsonEx(madkub.madkubSlbCertsAnnotation(certDirs), " "),
                },
            },
            spec+: {
                securityContext: {
                    fsGroup: 7447,
                },
                volumes+: [
                    {
                        name: "slb-envoy-nginx-configuration",
                        configMap: {
                            name: "slb-envoy-nginx-configuration",
                        },
                    },
                ] + madkub.madkubSlbCertVolumes(certDirs)
                + madkub.madkubSlbMadkubVolumes(),
                initContainers+: [
                    madkub.madkubInitContainer(certDirs),
                ],
                nodeSelector: { pool: slbconfigs.slbEstate },
            },
        },
    },
} else "SKIP"
