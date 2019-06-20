local madkub_common = import "madkub_common.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");

# Copied from madkub_common  
local containerspec(cert_names, user=0) = {
    local certs = madkub_common.make_cert_config(cert_names),
    name: "<replaced>",
    image: "ops0-artifactrepo2-0-prd.data.sfdc.net/sfci/servicelibs/sherpa-envoy:1.0.5",
    imagePullPolicy: "IfNotPresent",
    terminationMessagePath: "/dev/termination-log",
    terminationMessagePolicy: "File",
    livenessProbe: {
         exec: {
             command: [
                 "./bin/is-alive"
             ]
         },
         failureThreshold: 3,
         initialDelaySeconds: 120,
         periodSeconds: 5,
         successThreshold: 1,
         timeoutSeconds: 1
    },
    readinessProbe: {
        exec: {
            command: [
                "./bin/is-ready"
            ]
        },
        failureThreshold: 3,
        initialDelaySeconds: 110,
        periodSeconds: 5,
        successThreshold: 1,
        timeoutSeconds: 1
    },
    resources: {
        requests: {
            cpu: "1m",
            memory: "1Mi"
        },
        limits: {
            cpu: "1.0",
            memory: "1Gi"
        },
    },
    volumeMounts: madkub_common.cert_mounts(certs)
        + [{
            mountPath: "/tokens",
            name: "tokens",
        }]
    + (if !flowsnake_config.is_minikube then
        certs_and_kubeconfig.platform_cert_volumeMounts
    else [
        {
            mountPath: "/maddog-onebox",
            name: "maddog-onebox-certs",
        },
    ]),
    env: [
        {
            "name": "SETTINGS_PATH",
            "value": "-.-." + kingdom + ".-."
        },
        {
            "name": "SETTINGS_SUPERPOD",
            "value": "-"
        },
        {
            "name": "SFDC_SETTINGS_PATH",
            "value": "-.-." + kingdom + ".-."
        },
        {
            "name": "SFDC_SETTINGS_SUPERPOD",
            "value": "-"
        },
        {
            "name": "JVM_HEAP_MAX",
            "value": "1008M"
        },
    ],
};

if flowsnake_config.madkub_enabled then
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "service-mesh-container-spec",
        namespace: "flowsnake",
    },
    data: {
        "spec.jaysawn": std.toString(containerspec("usercerts"))
    }
} else "SKIP"
