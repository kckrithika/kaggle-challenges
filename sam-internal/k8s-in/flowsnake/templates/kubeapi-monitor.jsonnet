local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local configs = import "config.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";

if !std.objectHas(flowsnake_images.feature_flags, "kubeapi_monitor_setup") then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items:
        (import "kubeapi-monitor-scripts.libsonnet")
        + [
        configs.daemonSetBase("flowsnake") {
            local label_node = self.spec.template.metadata.labels,
            metadata: {
                name: "kubeapi-monitor",
                namespace: "flowsnake",
            },
            spec+: {
                selector: {
                    matchLabels: {
                        app: label_node.app,
                        apptype: label_node.apptype,
                    },
                },
                template: {
                    metadata: {
                        labels: {
                            app: "kubeapi-monitor",
                            apptype: "monitoring",
                            # NOTE: flowsnakeOwner and flowsnakeRole are used in prometheus-funnel
                            flowsnakeOwner: "dva-transform",
                            flowsnakeRole: "KubeapiMonitor",
                        },
                    },
                    spec: {
                        restartPolicy: "Always",
                        # NOTE: Use container network instead of host network, in order to utilize kubeDNS and thus be able to connect with kubeapi
                        hostNetwork: false,
                        containers: [
                            {
                                image: flowsnake_config.strata_registry + "/sfdc_centos7",  # FIXME: need specific tag or just use "latest"?
                                imagePullPolicy: flowsnake_config.default_image_pull_policy,
                                command: [
                                    "/kubeapi-monitor-scripts/check-kubeapi.sh",
                                ],
                                name: "kubeapi-monitor",
                                resources: {
                                    # NOTE: It's just making API calls, so a small container is enough
                                    requests: {
                                        cpu: "0.1",
                                        memory: "100Mi",
                                    },
                                    limits: {
                                        cpu: "0.1",
                                        memory: "100Mi",
                                    },
                                },
                                volumeMounts: [
                                    {
                                        mountPath: "/kubeapi-monitor-scripts",
                                        name: "kubeapi-monitor-scripts",
                                    },
                                ],
                                env: [
                                    {
                                        name: "FUNNEL_ENDPOINT",
                                        value: flowsnake_config.funnel_endpoint,
                                    },
                                    {
                                        name: "ESTATE",
                                        value: estate,
                                    },
                                    {
                                        name: "KINGDOM",
                                        value: kingdom,
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
                            },
                        ],
                        volumes: [
                            {
                                configMap: {
                                    name: "kubeapi-monitor-scripts",
                                    defaultMode: 493,
                                },
                                name: "kubeapi-monitor-scripts",
                            },
                        ],
                    },
                },
            },
        },
    ],
}
