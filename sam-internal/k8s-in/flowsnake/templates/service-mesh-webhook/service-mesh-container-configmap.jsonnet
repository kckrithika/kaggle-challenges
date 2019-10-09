local madkub_common = import "madkub_common.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");

# Copied from madkub_common
local containerspec = {
    name: "<replaced>",
    image: flowsnake_images.service_mesh,
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
    resources: (if flowsnake_config.sherpa_resources then flowsnake_config.sherpa_resources else {
        requests: {
            cpu: "1m",
            memory: "1Mi"
        },
        limits: {
            cpu: "1.0",
            memory: "1Gi"
        }
    }),
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
            "value": "1024M"
        },
    ],
};

if flowsnake_config.service_mesh_enabled then
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "service-mesh-container-spec",
        namespace: "flowsnake",
    },
    data: {
        "spec.jaysawn": std.toString(containerspec)
    }
} else "SKIP"
