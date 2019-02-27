local deployment = import 'deploymentTemplate.libsonnet';
local daemonSet = import 'daemonSetTemplate.libsonnet';
local service = import 'serviceTemplate.libsonnet';
local statefulSet = import 'statefulSetTemplate.libsonnet';
local expectedError = import '../../expectedErrorTypes.libsonnet';

{
    "StatefulSetServiceNameDoesntExist.yaml": statefulSet {
        override+:: {
            expectedError: expectedError.requiredPropertyDoesntExist,
            spec: {
                serviceName:: "hidden"
            },
        },
    },

    "DeploymentPoolSelectorLengthNot1.yaml": deployment {
        override+:: {
            expectedError: expectedError.arrayBelowMin,
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
                                                "More",
                                                "Than",
                                                "One"
                                            ],
                                        }
                                    ],
                                },
                            ],
                        },
                    },
                },
            },
        },
    },

    "DeploymentVolumeNameNotValid.yaml": deployment {
        override+:: {
            expectedError: expectedError.doesNotMatchPattern,
            templateSpec: {
                volumes: [
                    {
                        name: "bad_name",
                        hostPath: {
                            path: "/notBanned"
                        },
                    },
                ],
            },
        },
    },

    "StatefulSetVolumeUseBannedHostPath.yaml": statefulSet {
        override+:: {
            expectedError: expectedError.notAllowedValuesUsed,
            templateSpec: {
                volumes: [
                    {
                        name: "good-name",
                        hostPath: {
                            path: "/usr"
                        },
                    },
                ],
            },
        },
    },

    "DaemonSetContainerNameNotValid.yaml": daemonSet {
        override+:: {
            expectedError: expectedError.doesNotMatchPattern,
            containers: [
                {
                    name: "__bad_container_name"
                },
            ],
        },
    },

    "StatefulSetEnvNameNotValid.yaml": statefulSet {
        override+:: {
            expectedError: expectedError.doesNotMatchPattern,
            containers: [
                {
                    name: "valid-container-name",
                    env: [
                        {
                            name: "123-_BAD-ENV_NAME"
                        },
                    ],
                },
            ],
        },
    },

    "DaemonSetVolumeMountNameNotValid.yaml": daemonSet {
        override+:: {
            expectedError: {
                [ expectedError.doesNotMatchPattern ]: 5,
            },
            containers: [
                {
                    name: "valid-container-name",
                    volumeMounts: [
                        {
                            name: "_bad-one-part-name_"
                        },
                        {
                            name: "_bad-2-part-name_/bad"
                        },
                        {
                            name: "exceeds/the-63-word-count-limit-for-second-part-this-is-longer-than-63-characters"
                        },
                        {
                            name: "exceeds-the-first-part-length-which-is-253-so-this-is-going-to-be-long-test-test-test-test-test-test-test-test-test-test-est-test-test-test-placeholder-weoigaownva-vwegaweg-avv-vawevwegeagwab-awebasdgaweg-bwevagbfbssdfsdf-ok-253-characters-is-longer-than-i-expected/name"
                        },
                    ],
                },
            ],
        },
    },

    "ServiceSLBAnnotationNotValid.yaml": service {
        override+:: {
            expectedError: expectedError.doesNotMatchPattern,
            metadata: {
                annotations: {
                    "slb.sfdc.net/name": "NOT_VALID_DNS"
                },
            },
        },
    },

    "DeploymentUseSAMReservedLabels.yaml": deployment {
        override+:: {
            expectedError: {
                [ expectedError.notAllowedValuesUsed ]: 4,
            },
            metadata: {
                labels: {
                    "sam_test": "badLabel",
                    "bundleName": "badLabel",
                    "test/deployed_by/test": "goodLabel",
                    "kubernetes.io/": "badLabel",
                    "test.kubernetes.io/test": "badLabel",
                },
            },
        },
    },

    "StatefulSetUseK8sReservedLabels.yaml": statefulSet {
        override+:: {
            expectedError: {
                [ expectedError.notAllowedValuesUsed ]: 4,
            },
            metadata: {
                annotations: {
                    "sam_test": "badLabel",
                    "bundleName": "badLabel",
                    "test/deployed_by/test": "goodLabel",
                    "kubernetes.io/": "badLabel",
                    "test.kubernetes.io/test": "badLabel",
                },
            },
        },
    }
}