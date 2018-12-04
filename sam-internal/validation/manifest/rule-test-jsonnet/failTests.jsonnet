local base = import 'template.libsonnet';
local expectedError = import 'expectedErrorTypes.libsonnet';

{
    "HostPathUseNotAllowedPattern.yaml": base {
        override+:: {
            expected: expectedError.notAllowedValuesUsed,
            functions: {
                volumes: [
                    {
                        name: "bad-host-path",
                        hostPath: {
                            path: "/data/certs/bad/path"
                        }
                    }
                ]
            },
        },
    },


    "HostPathDoesNotMatchPattern.yaml": base {
        override+:: {
            expected: expectedError.doesNotMatchPattern,
            functions: {
                volumes: [
                    {
                        name: "bad-host-path",
                        hostPath: {
                            path: "/does/not/match/any/patterns"
                        }
                    }
                ]
            },
        },
    },


    "MaddogClientUsesLBNames.yaml": base {
        override+:: {
            expected: expectedError.allowedValuesNotUsed,
            functions: {
                volumes: [
                    {
                        name: "maddog-client-uses-lbnames",
                        maddogCert: {
                            type: "client",
                            lbnames: [ "foo", "bar" ],
                        },
                    },
                ],
            }
        }
    },


    "EnvUseReservedName.yaml": base {
        override+:: {
            expected: expectedError.notAllowedValuesUsed,
            containers: {
                env: [
                    { 
                        name: "FUNCTION",
                        value: "foo-value"
                    },
                ],
            }
        },
    },


    "EnvNameDoesNotMatchPattern.yaml": base {
        override+:: {
            expected: expectedError.doesNotMatchPattern,
            containers: {
                env: [ 
                    { 
                        name: "FOO-000-BAR",
                        value: "foo-value"
                    }
                ],
            }
        },
    },


    "ImageFormShouldFail.yaml": base {
        override+:: {
            expected: expectedError.doesNotMatchPattern,
            containers: {
                image: "somerandomhost.net/docker/retail/fail:123"
            },
        },
    },


    "ImageFormNotAllowed.yaml": base {
        override+:: {
            expected: expectedError.notAllowedValuesUsed,
            containers: {
                image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/foo/bar:latest"
            },
        },
    },


    "ContainerUsesSecurityContext.yaml": base {
        override+:: {
            expected: expectedError.notAllowedValuesUsed,
            containers: {
                securitycontext: "securityContextExistsShouldFail"
            },
        },
    },


    "ContainerUsesLifeCycle.yaml": base {
        override+:: {
            expected: expectedError.notAllowedValuesUsed,
            containers: {
                lifecycle: "lifeCycleExistsShouldFail"
            },
        },
    },


    "VolumeMountUsesSubPath.yaml": base {
        override+:: {
            expected: expectedError.notAllowedValuesUsed,
            containers: {
                volumeMounts: [
                    { 
                        name: "use-sub-path",
                        mountPath: "/subpath-not-allowed/",
                        subPath: "/subpath/not/allowed" 
                    },
                ],
            },
        }
    },


    "VolumesSecretDoesNotHaveSecretName.yaml": base {
        override+:: {
            expected: expectedError.requiredPropertyDoesntExist,
            functions: {
                volumes: [
                    {
                        name: "no-secret-name",
                        k4aSecret: {
                            somethingelse: "noSecretNameHere"
                        }
                    }
                ]
            },
        }
    },


    "VolumeMountInvalidMountPathPattern.yaml": base {
        override+:: {
            expected: expectedError.doesNotMatchPattern,
            containers: {
                volumeMounts: [
                    {              
                        name: "invalidMountPathPattern",
                        mountPath: "some:bad:path" 
                    },
                ],
            },
        }
    },


    "VolumeMountUseSecretWithNoReadOnly.yaml": base {
        override+:: {
            expected: expectedError.requiredPropertyDoesntExist,
            containers: {
                volumeMounts: [
                    {
                        name: "secretvol",
                        mountPath: "/secrets/"
                    },
                ],
            },
        }
    },


    "VolumeMountUseSecretWithFalseReadyOnly.yaml": base {
        override+:: {
            expected: expectedError.allowedValuesNotUsed,
            containers: {
                volumeMounts: [
                    {
                        name: "secretvol",
                        mountPath: "/secrets/",
                        readOnly: false
                    },
                ],
            },
        }
    },


    "VolumesInvalidFormat.yaml": base {
        override+:: {
            expected: {
                [ expectedError.additionalPropertyNotAllowed ]: 3
            },
            functions: {
                volumes: [
                    {
                        name: "more-than-one-type",
                        k4aSecret: {
                            k4a: "secret"
                        },
                        secret: {
                            something: "test"
                        },
                        maddogCert: {
                            type: "client"
                        },
                        hostPath: {
                            path: "/data/some/good/path"
                        },
                    }
                ]
            },
        }
    },


    "VolumesEmptyDirNotEmpty.yaml": base {
        override+:: {
            expected: expectedError.additionalPropertyNotAllowed,
            functions: {
                volumes: [
                    {
                        name: "not-empty-dir",
                        emptyDir: {
                            notSo: "emptyDir"
                        },
                    }
                ]
            },
        }
    },


    "LivenessProbeHttpGetPortDoesntExist.yaml": base {
        override+:: {
            expected: expectedError.requiredPropertyDoesntExist,
            containers: {
                livenessProbe: {
                    httpGet: {
                        path: "/no/port/here/"
                    },
                },
            },
        }
    },


    "SystemDoesNotExist.yaml": base {
        override+:: {
            expected: expectedError.requiredPropertyDoesntExist,
        },
        system:: "hidden"
    },


    "FunctionDoesNotExist.yaml": base {
        override+:: {
            expected: expectedError.requiredPropertyDoesntExist,
            system: {
                functions:: "hidden"
            },
        },
    },


    "ContainersDoesNotExist.yaml": base {
        override+:: {
            expected: expectedError.requiredPropertyDoesntExist,
            functions: { 
                containers:: "hidden" 
            },
        }
    },


    "EnvValueDoesNotExist.yaml": base {
        override+:: {
            expected: expectedError.requiredPropertyDoesntExist,
            containers: {
                env: [ 
                    { name: "SOME_ENV_NAME" } 
                ],
            },
        }
    },


    "ContainerImageDoesNotExist.yaml": base {
        override+:: {
            expected: expectedError.requiredPropertyDoesntExist,
            containers: {
                image:: "hidden"
            },
        },
    },


    "ContainerLivenessProbeDoesntExist.yaml": base {
        override+:: {
            expected: expectedError.requiredPropertyDoesntExist,
            containers: {
                livenessProbe:: "hidden"
            },
        },
    },


    "VolumeMountMountPathDoesNotExist.yaml": base {
        override+:: {
            expected: expectedError.requiredPropertyDoesntExist,
            containers: {
                volumeMounts: [ 
                    { name: "no-mount-path" } 
                ],
            },
        }
    },

    "FunctionNameDoesNotMatchDNSPattern.yaml": base {
        override+:: {
            expected: expectedError.doesNotMatchPattern,
            functions: {
                name: "not:valid:dns:pattern"
            },
        }
    },


    "ContainerNameMorethan63Characters.yaml": base {
        override+:: {
            expected: expectedError.stringExceedsMax,
            containers: {
                name: "this-should-be-valid-dns-pattern-but-is-longer-than-63-characters"
            },
        }
    },

    "IdentityServiceNameIsNotDNS.yaml": base {
        override+:: {
            expected: expectedError.doesNotMatchPattern,
            functions: {
                identity: {
                    serviceName: "not_DNS_ValiD",
                }
            },
        }
    },

    "BothFunctionAndSelectorExists.yaml": base {
        override+:: {
            expected: expectedError.notAllowedValuesUsed,
            loadbalancers: {
                "function": "foo-function",
                selector: "foo-selector"
            },
        },
    },

    "NeitherFunctionNorSelectorExists.yaml": base {
        override+:: {
            expected: expectedError.requiredPropertyDoesntExist,
            loadbalancers: {
                "function":: "no function here",
                selector:: "no selector neither"
            },
        },
    },

    "ContainerPortNameIsNotValid.yaml": base {
        override+:: {
            expected: {
                [ expectedError.notAllowedValuesUsed ]: 3,
                [ expectedError.stringExceedsMax ]: 1
            },
            containers: {
                ports: [
                    { name: "this-name-is-longer-than-15-characters" },
                    { name: "double--dash" },
                    { name: "-start-dash" },
                    { name: "end-dash-" }
                ],
            },
        }
    },

    "FunctionTypeIsNeitherStatefulNorDeployment.yaml": base {
        override+:: {
            expected: expectedError.allowedValuesNotUsed,
            functions: {
                type: "stateless"
            },
        },
    },

    "StatefulFunctionTypeLBNameIsEmpty.yaml": base {
        override+:: {
            expected: expectedError.requiredPropertyDoesntExist,
            functions: {
                type: "stateful-set"
            },
        },
    },

    "StatefulFunctionTypeStrategyExists.yaml": base {
        override+:: {
            expected: expectedError.notAllowedValuesUsed,
            functions: {
                type: "stateful-set",
                lbname: "foo-lbname",
                strategy: {
                    type: "RollingUpdate"
                },
            },
        },
    },

    "StatelessFunctionTypeLBNameExists.yaml": base {
        override+:: {
            expected: expectedError.notAllowedValuesUsed,
            functions: {
                lbname: "foo-lbname"
            },
        },
    },

    "StatelessFunctionTypeVolumeClaimTemplateExists.yaml": base {
        override+:: {
            expected: expectedError.notAllowedValuesUsed,
            functions: {
                volumeClaimTemplates: [
                    {
                        name: "abc"
                    },
                ],
            },
        },
    },

    "LBPortTypeNotValid.yaml": base {
        override+:: {
            expected: expectedError.allowedValuesNotUsed,
            lbports: {
                lbtype: "invalidType"
            },
        },
    },

    "LBPortStickyExistsForTCP.yaml": base {
       override+:: {
            expected: expectedError.notAllowedValuesUsed,
            lbports: {
                lbtype: "tcp",
                sticky: 100
            },
        },
    },

    "LBPortAlgorithmNotValid.yaml": base {
       override+:: {
            expected: expectedError.allowedValuesNotUsed,
            lbports: {
                lbalgorithm: "sdn"
            },
        },
    },

    "LBPortRRAlgorithmHasDSRType.yaml": base {
       override+:: {
            expected: expectedError.notAllowedValuesUsed,
            lbports: {
                lbalgorithm: "roundrobin",
                lbtype: "dsr"
            },
        },
    },

    "LBThrottlesWhitelistNotValidCIDR.yaml": base {
       override+:: {
            expected: expectedError.doesNotMatchPattern,
            lbports: {
                throttleswhitelist: [ "10.213.128.128/34", "1023.213.128.128/31", "123.2133.1284.1218/31" ],
            },
        },
    },

    "LBTlsCertificateIsInvalidTLS.yaml": base {
       override+:: {
            expected: expectedError.doesNotMatchPattern,
            lbports: {
                tlscertificate: "some:invalid:format",
                tls: false
            },
        },
    },
}