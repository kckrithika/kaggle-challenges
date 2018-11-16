local additional = import "additional-config.jsonnet";
local util = import "util.jsonnet";

{
    # List and Range of reserved ports that should not be accessed
    reservedPorts: [
        util.AllowedValues( [ 2379, 2380, 4194, 8000, 8002, 8080, 9099, 9100, 10250, 10251, 10252, 10255, 64121 ] ), 
        util.Range( [ 0, 1024 ] ),
        util.Range( [ 32000, 40000 ] )
    ] + additional.reservedPorts,

    # Regex for allowed/disallowed host path
    hostPathList: {
        allowed: [
            "^/data/([a-zA-Z-_]+/?)+$",
            "^/fastdata/([a-zA-Z-_]+/?)+$",
            "^/cowdata/([a-zA-Z-_]+/?)+$",
            "^/var/log/([a-zA-Z-_]+/?)+$",
            "^/home/caas/([a-zA-Z-_]+/?)+$",
            "^/home/sfdc-([a-zA-Z-_]+)([a-zA-Z-_]+/?)+$"
        ] + additional.hostPathList.allowed,

        notAllowed: [
            "^(/data/certs).*$"
        ] + additional.hostPathList.notAllowed
    },

    # Regex for allowed/disallowed image forms
    imageForm: {
        allowed: [
            "^ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/.+/.+:.+$"
        ] + additional.imageForm.allowed,

        notAllowed: [
            "^.*(latest)$",
            "^ops0-artifactrepo2-0-prd.data.sfdc.net/(docker-p2p|docker-sam).+:.+$"
        ] + additional.imageForm.notAllowed
    },

    # List of reserved env names that should not be used
    reservedEnvName: [
        "HOST_TYPE",
        "SFDC_METRICS_SERVICE_HOST",
        "SFDC_METRICS_SERVICE_PORT",
        "FUNCTION_NAMESPACE",
        "FUNCTION_INSTANCE_NAME",
        "FUNCTION_INSTANCE_IP",
        "SFDC_SETTINGS_PATH",
        "SFDC_SETTINGS_SUPERPOD",
        "KINGDOM",
        "ESTATE",
        "SUPERPOD",
        "FUNCTION"
    ] + additional.reservedEnvName,

    # List of regex env name must match
    envNamePattern: [
        "^[A-Za-z_][A-Za-z0-9_]*$"
    ] + additional.envNamePatterns,

    # List of regex env name must match
    mountPathPattern: [
        "^[^:]+$"
    ] + additional.mountPathPatterns,

    # List of manifest fields that must exist
    manifest_requirements: [
        "apiVersion",
        "system"
    ] + additional.manifestRequirements,

    # List of system fields that must exist
    system_requirements: [
        "functions"
    ] + additional.systemRequirements,

    # List of functions fields that must exist
    functions_requirements: [
        "name",
        "count",
        "containers"
    ] + additional.functionsRequirements,

    # List of env fields that must exist
    env_requirements: [
        "name", 
        "value" 
    ] + additional.envRequirements,

    # List of httpGet (livenessProbe) fields that must exist
    httpGet_requirements: [
        "port"
    ] + additional.httpGetRequirements,

    # List of container fields that must exist
    container_requirements: {
        required: [
            "name",
            "image"
        ] + additional.containerRequirements.required,

        # List of unsupported fields in containers
        unsupported: [
            "securitycontext",
            "lifecycle"
        ] + additional.volumeMountsRequirements.unsupported,
    },

    # List of volumeMounts fields that must exist
    volumeMounts_requirements: {
        required: [
            "name",
            "mountPath"
        ] + additional.volumeMountsRequirements.required,

        # List of unsupported fields in volume mounts
        unsupported: [
            "subPath"
        ] + additional.volumeMountsRequirements.unsupported,
    },


#####################$##########  More Complicated Logic  #######################################


    # Only type Server can have lbnames property
    maddogValidation: {
        properties: {
            type: { enum: [ "server", "client" ] },
            lbnames: { type: "array" }
        },

        required: [ "type" ],
                        
        dependencies: {
            lbnames: {
                properties: {
                    type: { "enum": [ "server" ] }
                }
            }
        }
    },

    # MaddogCertificate Volume Format
    maddogVolumeFormat: { 
        properties: {
            name: {
                type: "string",
                "$ref": "#/Rule_isDNSValidation"
            },
            maddogCert: {
                allOf: [
                    { "$ref": "#/Rule_maddogValidation" }
                ]
            }
        },
        additionalProperties: false
    },

    # Secret/K4A Volume Format
    secretVolumeFormat: {
        properties: {
            name: {
                type: "string",
                "$ref": "#/Rule_isDNSValidation"
            }
        },

        patternProperties: {
            "^(k4aSecret)$|(secret)$" : {
                type: "object",
                required: [ "secretName" ],
                properties: {
                    secretName: {
                        type: "string"
                    }
                }
            }
        },

        additionalProperties: false
    },

    # HostPath Volume Format
    hostPathVolumeFormat: {
        properties: {
            name: {
                type: "string",
                "$ref": "#/Rule_isDNSValidation"
            },
            hostPath: {
                type: "object",
                properties: {
                    path: {
                        type: "string",
                        "$ref": "#/Rule_hostPathList"
                    }
                }
            }
        },
        additionalProperties: false
    },

    # EmptyDir Volume Format
    emptyDirVolumeFormat: {
        properties: {
            name: {
                type: "string",
                "$ref": "#/Rule_isDNSValidation"
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
    secretVolumeMountValidation: {
        "if": {
            anyOf: [
                { properties: { name: { enum: [ "secretvol" ] } } },
                { properties: { mountPath: { enum: [ "/secrets/" ] } } }
            ]
        },
        "then": {
            allOf: [
                { required: [ "readOnly" ] },
                { properties: { readOnly: { enum: [ true ] } } }
            ]
        }
    }
}