# NOTE: Do NOT override base OR modify base for team specific/whitelist rules

local config = import "../manifest-overwrite.jsonnet";
local util = import "../../util.jsonnet";

local schemaID = "manifestConfigs";

{
    # List of regex env name must match
    envNamePattern:: [
        "^[A-Za-z_][A-Za-z0-9_]*$"
    ],

    # List of regex env name must match
    mountPathPattern:: [
        "^[^:]+$"
    ],

    # List of manifest fields that must exist
    manifest_requirements:: [
        "system"
    ],

    # List of system fields that must exist
    system_requirements:: [
        "functions"
    ],

    # List of functions fields that must exist
    functions_requirements:: [
        "name",
        "count",
        "containers"
    ],

    # List of env fields that must exist
    env_requirements:: [
        "name",
    ],

    # List of httpGet (livenessProbe) fields that must exist
    httpGet_requirements:: [
        "port"
    ],

    volumeClaimTemplates_requirements:: [
        "name"
    ],

    loadbalancers_requirements:: [
        "lbname"
    ],

    lbPort_requirements:: [
        "port",
        "targetport",
    ],

    # List of container fields that must exist
    container_requirements:: {
        local containerRequirements = [
            "name", 
            "image", 
            "livenessProbe" 
        ],
        local containerNotAllowed = [
            "securitycontext",
            "lifecycle"
        ],
        
        # List of must exist fields in container
        mustExist:
            if config.Enable_LivenessProbeWhitelist then
                util.Whitelist(
                    { image: { not: { "$ref": schemaID + "#/LivenessProbeExceptions" } } },
                    util.Required(containerRequirements),
                    util.Required([ "name", "image" ]),
                )
            else util.Required(containerRequirements),

        # List of not allowed fields in containers
        notAllowed: util.NotAllowed(containerNotAllowed),
    },

    # List of volumeMounts fields that must exist
    volumeMounts_requirements:: {
        mustExist: util.Required([ "name", "mountPath" ]),

        # List of not allowed fields in containers
        notAllowed: util.NotAllowed([ "subPath" ]),
    },


###############################  More Complicated Logic  #####################################

    imageValidation:: {
        local imageNameNTag = "^.+:.+$",
        local dockerSamImage = "^ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/.+/.+:.+$",
        local invalidPatterns = [
            "^ops0-artifactrepo1-0-prd.data.sfdc.net/.+/.+:.+$",
            "^ops0-artifactrepo2-0-prd.data.sfdc.net/(docker-p2p|docker-sam)/.+:.+$",
            "^.*(latest)$",
        ],

        oneOf: [
            {
                pattern: dockerSamImage
            },
            util.MatchRegex([ imageNameNTag ], invalidPatterns),
        ],
    },

    insecureImageValidation:: 
        if config.Enable_InsecureImageExceptions then {
            not: {
                allOf: [
                    { pattern: "^.+\\..+\\/.+$" },
                    util.ValuesNotAllowed(config.insecureImageExceptionSet),
                    util.DoNotMatchRegex(config.secureRegistry),
                ],
            }
        } else {},

    # IsQualifiedName Rule from Kubernetes apimachinery (Used for Label and Annotation Keys)
    isQualifiedName:: {
        oneOf: [            
            # For one part names without '/'
            {
                pattern: "^([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9]$",
                maxLength: 63
            },

            # For two parts with a '/'
            {
                allOf: [
                    # Make sure the 1st part matches DNS1123Subdomain regex and 2nd part match qualifiedName regex
                    { pattern: "^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)/([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9]$" },
                    # Make sure the max length for the 1st part is 253 and 2nd part is 63
                    { pattern: "^.{1,253}/.{1,63}$" },
                ],
            },
        ]
    },

    # Neither serviceName nor pod are required, but they must be DNS1123 valid if they exist
    identityValidation:: {
        properties: {
            serviceName: {
                type: "string",
                "$ref": "#/Rule_IsDNSValidation"
            },

            pod: {
                type: "string",
                "$ref": "#/Rule_IsDNSValidation"
            }
        }
    },

    # Validate labels/annotations are k8s valid
    validateLabels:: {
        propertyNames: $.isQualifiedName,
        additionalProperties: {
            maxLength: 63,
            pattern: "^(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])?$"
        },
    },

    # Make sure SAM/Kubernetes reserved labels are not being used
    reservedLabels:: {
        // PropertyNames is a JSON Schema keyboard that enforces the property/key value
        propertyNames: util.DoNotMatchRegex(config.reservedLabelsRegex),
    },

    # Only type Server can have lbnames property
    maddogValidation:: {
        properties: {
            type: util.AllowedValues( [ "server", "client" ] ),
            lbnames: { type: "array" }
        },

        required: [ "type" ],
                        
        dependencies: {
            lbnames: {
                properties: {
                    type: util.AllowedValues( [ "server" ] )
                }
            }
        }
    },

    # MaddogCertificate Volume Format
    maddogVolumeFormat:: { 
        properties: {
            name: {
                type: "string",
                "$ref": "#/Rule_IsDNSValidation"
            },
            maddogCert: {
                allOf: [
                    { "$ref": "#/Rule_MaddogValidation" }
                ]
            }
        },
        additionalProperties: false
    },

    # Secret Volume Format
    secretVolumeFormat:: {
        properties: {
            name: {
                type: "string",
                "$ref": "#/Rule_IsDNSValidation"
            },

            secret: {
                type: "object",
                required: [ "secretName" ],
                properties: {
                    secretName: {
                        type: "string"
                    }
                }
            },
        },
        # additionalProperties disallow any properties that are not defined in the schema to exist
        # In this case, only 'name' and 'secret' can exist for secret volume
        additionalProperties: false
    },

    # K4ASecret Volume Format
    k4aVolumeFormat:: {
        properties: {
            name: {
                type: "string",
                "$ref": "#/Rule_IsDNSValidation"
            },
        },

        patternProperties: {
            "k4asecret|k4aSecret": {
                type: "object",
                required: [ "secretName" ],
                properties: {
                    secretName: {
                        type: "string"
                    }
                }
            },
        },

        additionalProperties: false
    },

    # HostPath Volume Format
    hostPathVolumeFormat:: {
        properties: {
            name: {
                type: "string",
                "$ref": "#/Rule_IsDNSValidation"
            },
        },

        patternProperties: {
            "hostpath|hostPath": {
                type: "object",
                properties: {
                    path: {
                        type: "string",
                        "$ref": "#/Rule_HostPathList"
                    }
                }
            }
        },

        additionalProperties: false
    },

    # EmptyDir Volume Format
    emptyDirVolumeFormat:: {
        properties: {
            name: {
                type: "string",
                "$ref": "#/Rule_IsDNSValidation"
            },
            emptyDir: {
                type: "object",
                additionalProperties: false,
                properties: {}
            }
        },
        additionalProperties: false
    },

    # Secret Volumes MUST have readOnly field set as true
    secretVolumeMountValidation:: {
        "if": {
            anyOf: [
                { properties: { name: util.AllowedValues([ "secretvol" ]) } },
                { properties: { mountPath: util.AllowedValues([ "/secrets/" ]) } }
            ]
        },
        "then": {
            allOf: [
                util.Required([ "readOnly" ]),
                { properties: { readOnly: util.AllowedValues([ true ]) } }
            ]
        }
    },

    # Kubernetes requirements for valid container port name and number
    validateContainerPort:: {
        isValidPortName: {
            maxLength: 15,
            allOf: [
                { pattern: "^[-a-z0-9]+$" },
                { pattern: "[a-z0-9]" },
                # Must not contain consecutive '-' and cannot start/end with '-'
                util.ListNotAllowed([
                    { pattern: "^.*--.*$" },
                    { pattern: "^-.*$" },
                    { pattern: "^.*-$" }
                ])
            ]
        },

        isValidPortNumber: util.Range([ 1, 65535 ])
    },

    # Makes sure function types are either stateful or stateless and 
    validateFunctionType:: {
        typesAllowed: [ "stateful-set", "deployment" ],

        typeRequirements: {
            # Stateless by default
            "if": {
                properties: { 
                    type: util.AllowedValues([ "deployment" ])
                }
            },
            "then": util.NotAllowed( [ "lbname", "volumeClaimTemplates" ] ),
            "else": {
                "if": {
                    properties: { 
                        type: util.AllowedValues([ "stateful-set" ])
                    }
                },
                "then": {
                    allOf: [
                        util.Required( [ "lbname" ] ),
                        util.NotAllowed( [ "strategy" ] )
                    ]
                },
            },
        }
    },

    # One and only one of function or selector must exist in loadbalancer
    LBFunctionOrSelector:: util.ExactlyOneExists("function", "selector"),

    # LoadBalancer Port allowed types and validation
    LBPortsValidation:: {
        LBPortAllowedTypes: [ "dsr", "tcp", "http" ],

        LBDestinationPort: util.ExactlyOneExists("targetport", "httpsredirectport"),

        LBTypeSpecificParameters: {
            local HttpOnly = [ "sticky", "reencrypt", "tls", "mtls", "addheaders", "removeheaders", "httpsredirectport" ],
            local TlsOnly = [ "proxyprotocol" ],

            allOf: [
                {
                    "if": { properties: { lbtype: util.ValuesNotAllowed([ "tls" ]) } },
                    "then": util.NotAllowed( TlsOnly ),
                },
                {
                    "if": { properties: { lbtype: util.ValuesNotAllowed([ "http" ]) } },
                    "then": util.NotAllowed( HttpOnly ),
                },
            ],
        },

        LBPortAllowedAlgorithm: [ "leastconn", "roundrobin", "hash" ],

        LBPortAlgorithm: {
            // Since if for value that doesn't exist defaults to true, if lbalgorithm isn't defined do nothing
            "if": { properties: { lbalgorithm: util.AllowedValues([ "" ]) } },
            "then": {},
            "else": {
                "if": { properties: { lbalgorithm: util.AllowedValues([ "leastconn", "roundrobin", "hash" ]) } },
                "then": { properties: { lbtype: util.ValuesNotAllowed([ "dsr" ]) } }
            },
        },

        CIDRValidation: {
            items: {
                type: "string",
                pattern: "^([0-9]{1,3}.){3}[0-9]{1,3}(/([0-9]|[1-2][0-9]|3[0-2]))?$"
            }
        },

        TLSValidation: {
            dependencies: {
                TlsCertificate: {
                    required: [ "tls", "lbtype" ],

                    properties: {
                        tls: util.AllowedValues([ true ]),
                        lbtype: util.AllowedValues([ "http" ])
                    }
                },
    
                TlsKey: {
                    required: [ "tls", "lbtype" ],

                    properties: {
                        tls: util.AllowedValues([ true ]),
                        lbtype: util.AllowedValues([ "http" ])
                    }
                }
            }
        },

        TLSPattern: {
            pattern: "^secret_service:[a-zA-Z0-9]+:[-a-zA-Z0-9]*$"
        } 
    },
}