# Spec for the strata test agent.
# Configmap and other resources specified in strata-integration-tests.jsonnet

local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";

if !flowsnake_config.ci_resources_enabled then
"SKIP"
else
{
    kind: "Deployment",
    apiVersion: "extensions/v1beta1",
    metadata: {
        name: "strata-test-agent",
        namespace: "flowsnake-ci-tests",
        labels: {
            app: "flowsnake-strata-test-agent",
            apptype: "testing",
            flowsnakeOwner: "dva-transform",
            flowsnakeRole: "StrataTestAgent",
        },
    },
    spec: {
        local pod_labels =
            {
                app: "flowsnake-strata-test-agent",
                apptype: "testing",
                flowsnakeOwner: "dva-transform",
                flowsnakeRole: "StrataTestAgent",
            },
        replicas: 1,
        selector: {
            matchLabels: pod_labels,
        },
        template: {
            metadata: {
                labels: pod_labels,
                annotations: {
                    "sfdc.net/disable-madkub" : "true",
                }
            },
            spec: {
                automountServiceAccountToken: true,
                restartPolicy: "Always",
                serviceAccountName: "spark-driver-flowsnake-ci-tests",
                volumes: [
                    {
                        name: "host-cacerts",
                        hostPath: {
                            path: "/etc/pki_service/ca"
                        }
                    },
                    {
                        name: "agent-scripts",
                        configMap: {
                            name: "strata-test-agent-scripts",
                            optional: false,
                        }
                    }
                ],
                containers: [
                    {
                        name: "agent",
                        image: flowsnake_images.jdk8_base,
                        command: [ "/usr/bin/env", "python", "/scripts/strata-test-agent.py" ],
                        env: [
                            { name: "POLL_INTERVAL_SEC", value: "60" },
                        ],
                        volumeMounts: [
                            {
                                name: "host-cacerts",
                                mountPath: "/certs/ca",
                                readOnly: true,
                            },
                            {
                                name: "agent-scripts",
                                mountPath: "/scripts",
                                readOnly: true,
                            }
                        ],
                        resources: {
                            requests: {
                                cpu: "50m",
                                memory: "1Mi",
                            }
                        }
                    },
                    {
                        name: "janitor",
                        image: flowsnake_images.jdk8_base,
                        command: [ "/usr/bin/env", "python", "/scripts/strata-test-janitor.py" ],
                        env: [
                            { name: "POLL_INTERVAL_MIN", value: "30" },
                            { name: "MAX_AGE_MIN", value: "180" },
                        ],
                        volumeMounts: [
                            {
                                name: "host-cacerts",
                                mountPath: "/certs/ca",
                                readOnly: true,
                            },
                            {
                                name: "agent-scripts",
                                mountPath: "/scripts",
                                readOnly: true,
                            }
                        ],
                        resources: {
                            requests: {
                                cpu: "50m",
                                memory: "1Mi",
                            }
                        }
                    }

                ],
            }
        }
    }
}
