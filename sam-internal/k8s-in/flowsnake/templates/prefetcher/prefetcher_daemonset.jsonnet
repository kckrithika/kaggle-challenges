local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnake_images = import "flowsnake_images.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";

if ! ("prefetcher_enabled" in flowsnake_images.feature_flags) then
"SKIP"
else
{
    local common_labels = {
            service: "image-prefetcher",
            flowsnakeOwner: "dva-transform",
            flowsnakeRole: "ImagePrefetcher",
            name: "flowsnake-image-prefetcher-ds",            
        },
    kind: "DaemonSet",
    apiVersion: "apps/v1",
    metadata: {
        name: "flowsnake-image-prefetcher-ds",
        namespace: "flowsnake",
        labels: common_labels,
        annotations: {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    spec: {
        selector: {
            matchLabels: common_labels,
        },
        updateStrategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: "50%",
            },
        },
        template: {
            metadata: {
                labels: common_labels,
            },
            spec: {
                hostNetwork: true,
                restartPolicy: "Always",
                serviceAccountName: "default",
                volumes: [
                    {
                        name: "host-var-run",
                        hostPath: {
                            path: "/var/run",
                        },
                    },
                    {
                        name: "prefetcher-resources",
                        configMap: {
                            name: "flowsnake-prefetcher-configmap",                            
                        },
                    },
               ],
               containers: [
                   {
                       name: "prefetcher",
                       image: flowsnake_images.flowsnake_ops_tools,
                       command: [ "/bin/bash", "/prefetcher-resources/prefetcher.sh"],
                       env: [
                           {
                               name: "KINGDOM",
                               value: kingdom,
                           },
                           {
                               name: "ESTATE",
                               value: estate,
                           },
                           {
                               name: "FUNNEL_ENDPOINT",
                               value: flowsnake_config.funnel_endpoint,
                           },
                           {
                               name: "NODE_NAME",
                               valueFrom: { 
                                   fieldRef: {
                                       fieldPath: "spec.nodeName",
                                   },
                               },
                           },
                       ],
                       volumeMounts: [
                           {
                               name: "host-var-run",
                               mountPath: "/host-var-run",
                           },
                           {
                               name: "prefetcher-resources",
                               mountPath: "/prefetcher-resources",
                           }
                       ]
                   }
               ],
            },
        },
    },
}