local deployment = import 'deploymentTemplate.libsonnet';
local daemonSet = import 'daemonSetTemplate.libsonnet';
local service = import 'serviceTemplate.libsonnet';
local statefulSet = import 'statefulSetTemplate.libsonnet';

{
    # Make sure the base templates are good and actually passes
    "BaseDeploymentTest.yaml": deployment,
    "BaseServiceTest.yaml": service,
    "BaseDaemonSetTest.yaml": daemonSet,
    "BaseStatefulSetTest.yaml": statefulSet,

    # Pool selector in affinity validation based on Key and Operator
    "DeploymentPoolSelectorIs1.yaml": deployment {
        override+:: {
            templateSpec: {
                affinity: {
                    nodeAffinity: {
                        requiredDuringSchedulingIgnoredDuringExecution: {
                            nodeSelectorTerms: [
                                {
                                    matchExpressions: [
                                        {
                                            key: "pool",
                                            operator: "In",
                                            values: [
                                                "Just 1 Value"
                                            ],
                                        },
                                        {
                                            key: "not-pool",
                                            operator: "not-In",
                                            values: [
                                                "More",
                                                "Than",
                                                "One",
                                                "Value"
                                            ], 
                                        },
                                    ],
                                },
                            ],
                        },
                    },
                },
            },
        },
    },

    # Deployment Volume, Container, and volumeMounts names are valid
    # Also hostPath does not used banned path
    "DeploymentVolumesAndContainerAreValid.yaml": deployment {
        override+:: {
            templateSpec: {
                volumes: [
                    {
                        name: "good-name",
                        hostPath: {
                            path: "/notBanned"
                        },
                    },
                ],
            },
            containers: [
                {
                    name: "valid-container-name",
                    env: [
                        {
                            name: "GOOD_ENV_NAME"
                        },
                    ],
                    volumeMounts: [
                        {
                            name: "good-one-part-name"
                        },
                    ],
                },
            ],
        },
    },

    "StatefulSetVolumesAndContainerAreValid.yaml": statefulSet {
        override+:: {
            templateSpec: {
                volumes: [
                    {
                        name: "good-name",
                        hostPath: {
                            path: "/notBanned"
                        },
                    },
                ],
            },
            containers: [
                {
                    name: "valid-container-name",
                    env: [
                        {
                            name: "GOOD_ENV_NAME"
                        },
                    ],
                    volumeMounts: [
                        {
                            name: "test.com/good-2-part-name"
                        },
                    ],
                },
            ],
        },
    },

    "DaemonSetVolumesAndContainerAreValid.yaml": daemonSet {
        override+:: {
            templateSpec: {
                volumes: [
                    {
                        name: "good-name",
                        hostPath: {
                            path: "/notBanned"
                        },
                    },
                ],
            },
            containers: [
                {
                    name: "valid-container-name",
                    env: [
                        {
                            name: "GOOD_ENV_NAME"
                        },
                    ],
                    volumeMounts: [
                        {
                            name: "www.example.com/MyName"
                        },
                    ],
                },
            ],
        },
    },

    "ServiceGoodSLBAnnotation.yaml": service {
        override+:: {
            metadata: {
                annotations: {
                    "slb.sfdc.net/name": "valid-value"
                },
            },
        },
    },

    "DeploymentGoodLabelsAndAnnotations.yaml": deployment {
        override+:: {
            metadata: {
                annotations: {
                    "test.labels.1": "goodLabel",
                    "test.bundleName": "goodLabel",
                    "test/deployed_by/test": "goodLabel",
                },
            },
        },
    },

    "PrivilegedNamespaceUsesReservedLabels.yaml": deployment {
        override+:: {
            metadata: {
                namespace: "sam-system",
                labels: {
                    "sam_only": "goodLabel",
                    "bundleName": "goodLabel",
                    "kubernetes.io/": "goodLabel",
                    "test.kubernetes.io/test": "goodLabel",
                },
            },
        },
    },
}