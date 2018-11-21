# NOTE: Do NOT override base OR modify base for team specific/whitelist rules

local config = import "../manifest-overwrite.jsonnet";
local util = import "util.jsonnet";

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
        "apiVersion",
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
        "value" 
    ],

    # List of httpGet (livenessProbe) fields that must exist
    httpGet_requirements:: [
        "port"
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
        mustExist: [
            "name",
            "mountPath"
        ],

        # List of not allowed fields in containers
        notAllowed: [ "subPath" ],
    },


###############################  More Complicated Logic  #####################################


    # Only type Server can have lbnames property
    maddogValidation:: {
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

    # Secret/K4A Volume Format
    secretVolumeFormat:: {
        properties: {
            name: {
                type: "string",
                "$ref": "#/Rule_IsDNSValidation"
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
    hostPathVolumeFormat:: {
        properties: {
            name: {
                type: "string",
                "$ref": "#/Rule_IsDNSValidation"
            },
            hostPath: {
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