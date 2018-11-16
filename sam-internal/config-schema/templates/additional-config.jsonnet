local util = import "util.jsonnet";

{
    # Additional reserved ports as an array of objects
    # example: 
    #        [ 
    #            util.AllowedValues([ 1, 2, 3 ]),
    #            util.Range([2, 5]),
    #        ],
    reservedPorts: [],

    # Additional host path patterns that can/cannot be matched
    # example: 
    #        allowed: [
    #           "^abc+$"
    #        ],
    #        notAllowed: [
    #           "^123+$"
    #        ],
    #
    hostPathList: {
        allowed: [],
        notAllowed: []
    },

    # Additional image patterns that can/cannot be matched
    # Same as hostPathList above
    imageForm: {
        allowed: [],
        notAllowed: [],
    },

    # Additional reserved env names that cannot be used
    # example: 
    #        [
    #           "NAME_ONE",
    #           "ANOTHER_NAME"
    #        ]
    reservedEnvName: [],

    # Additional env name patterns (Can be easily refactored to notAllowed)
    # example: 
    #        [
    #           "^123+$"
    #        ],
    envNamePatterns: [],

    # Additional mount path patterns (Can be easily refactored to notAllowed)
    # Same as envNamePatterns above
    mountPathPatterns: [],

    # Additional fields that must exist in the base manifest file
    # example: 
    #        [
    #           "notifications"
    #        ],
    manifestRequirements: [],

    # Additional fields that must exist in the system field 
    systemRequirements: [],

    # Additional fields that must exist in the functions field 
    functionsRequirements: [],

    # Additional fields that must exist in the env field 
    envRequirements: [],

    # Additional fields that must exist in the httpGet (livenessProbe) field 
    httpGetRequirements: [],

    # Additional fields that must exist in the containers field 
    containerRequirements: {
        required: [],
        unsupported: [],
    },

    # Additional fields that must exist in the volumeMounts field 
    volumeMountsRequirements: {
        required: [],
        unsupported: [],
    }
}