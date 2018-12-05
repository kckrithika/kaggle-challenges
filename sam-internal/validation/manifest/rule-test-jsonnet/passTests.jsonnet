local base = import 'template.libsonnet';
local expectedError = import 'expectedErrorTypes.libsonnet';

{
    # Makes sure that the base fields are good
    # also checks DNS Validation as a bonus
    "BaseManifestTest.yaml": base {
        override+:: {
            expectedError: expectedError.none
        },
    },

    "GoodHostPath.yaml": base {
        local patterns = [
            "/data/ca-cluster-a",
            "/fastdata/gater", 
            "/cowdata", 
            "/var/log/scheduler-db", 
            "/home/caas/logs/caas", 
            "/home/sfdc-retail/logs"
        ],

        override+:: {
            expectedError: expectedError.none,
            functions: {
                volumes: [
                    {
                        # Just to make sure the names are unique
                        name: "foo" + std.strReplace(x, "/", "-"),
                        hostPath: {
                            path: x
                        }
                    } for x in patterns
                ]
            },
        }
    },


    "GoodCorpNetImageForm.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            containers: {
                image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/retail/retail-setup:dca7fd4"
            },
        }
    },


    "GoodPrdPrefixImageForm.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            containers: {
                image: "ops0-artifactrepo2-0-prd.data.sfdc.net/foo/bar:123"
            },
        }
    },


    "GoodShortImageForm.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            containers: {
                image: "tnrp/caas/caas-redis:0.1-13175027-16"
            },
        }
    },


    "GoodMaddogValidation.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            functions: {
                volumes: [
                    {
                        name: "maddog-client",
                        maddogCert: {
                            type: "client"
                        },
                    },
                    {
                        name: "maddog-server",
                        maddogCert: {
                            type: "server",
                            lbnames: [ "foo", "bar" ],
                        },
                    },
                ],
            },
        }
    },


    "GoodVolumeFormats.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            functions: {
                volumes: [
                    {
                        name: "maddog",
                        maddogCert: {
                            type: "server"
                        },
                    },
                    {
                        name: "hostpath",
                        hostPath: {
                            path: "/data/good/path"
                        },
                    },
                    {
                        name: "emptydir",
                        emptyDir: {},
                    },
                ],
            },
        }
    },


    "SecretVolumeUseSecretName.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            functions: {
                volumes: [
                    {
                        name: "secrets",
                        secret: {
                            secretName: "someSecret"
                        },
                    },
                    {
                        name: "k4a-secret",
                        k4aSecret: {
                            secretName: "someOtherSecret"
                        },
                    },
                ]
            }
        }
    },


    "SecretVolumeMountReadOnlyIsTrue.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            containers: {
                volumeMounts: [
                    {
                        name: "secretvol",
                        mountPath: "/secrets/",
                        readOnly: true
                    },
                ],
            },
        }
    },


    "ContainerValidPortRange.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            containers: {
                ports: [
                    { containerPort: 8012 },
                    { containerPort: 3111 },
                    { containerPort: 1025 },
                ],
            },
        }
    },


    // If imaged is on the excepted list, then livenessProbe doesn't have to exist
    "ValidExceptedLivenessProbe.yaml": base {
        override+::{
            expectedError: expectedError.none,
            containers: {
                livenessProbe:: "livenessprobe not needed",
                image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/dkardach/aqueduct-test-deploy:20170418"
            },
        },
    },

    "IdentityServiceAndPodNameAreDNS.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            functions: {
                identity: {
                    serviceName: "good-service-name",
                    pod: "good-pod-name"
                }
            },
        }
    },

    "ContainerPortNameAndNumAreValid.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            containers: {
                ports: [
                    {
                        name: "good-portname-1",
                        containerPort: 8012 
                    },
                    {
                        name: "good-portname-2",
                        containerPort: 3111 
                    },
                ],
            },
        }
    },

    "FunctionTypeStateful.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            functions: {
                type: "stateful-set",
                lbname: "some-lb-name"
            },
        }
    },

    "FunctionTypeStateless.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            functions: {
                type: "deployment"
            },
        }
    },

    "LBPortValidType.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            lbports: {   
                lbtype: "http",
                reencrypt: true,
                sticky: 100
            }
        },
    },

    "LBPortValidAlgorithm.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            lbports: {
                lbalgorithm: "leastconn"
            },
        },
    },

    "LBPortMatchCIDR.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            lbports: {
                allow: [ "10.213.128.128/26", "10.214.129.128/26", "10.215.133.0/24" ],
                deny: [ "10.2.128.128/26", "10.3.129.128/26", "10.4.133.0/24" ],
                throttleswhitelist: ["10.210.128.128/26", "10.210.129.128/26", "10.210.133.0/24"],
            },
        },
    },

    "LBPortCertificateAndKeyMatchesTLS.yaml": base {
        override+:: {
            expectedError: expectedError.none,
            lbports: {
                tlscertificate: "secret_service:certificate:secret123",
                tlskey: "secret_service:key123:secret",
                lbtype: "http",
                tls: true
            },
        },
    },
}