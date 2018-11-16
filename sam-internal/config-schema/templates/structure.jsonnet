local base = import "base-config.jsonnet";
local util = import "util.jsonnet";

{
    # JSON Schema Keyword, $id is used to help the main schema reference to this file
    "$id": "manifestConfigs",


    Rule_reservedPorts: util.ListNotAllowed(base.reservedPorts),


    Rule_hostPathList: util.MatchPatterns(base.hostPathList.allowed, base.hostPathList.notAllowed),


    Rule_imageForm: util.MatchPatterns(base.imageForm.allowed, base.imageForm.notAllowed),


    Rule_envVariableName: {
        EnvNamePatterns: util.MatchPatterns(base.envNamePattern),
        ReservedEnvName: util.ValuesNotAllowed(base.reservedEnvName)
    },


    Rule_isDNSValidation: {
        maxLength: 63,
        pattern: "^[a-z0-9]([-a-z0-9]*[a-z0-9])?$"
    },


    Rule_maddogValidation: base.maddogValidation,


    Rule_volumeMountValidation: {
        MountPathPattern: util.MatchPatterns(base.mountPathPattern),
        SecretVolume: base.secretVolumeMountValidation
    },


    Rule_volumesFormat: {
        anyOf: [
            base.maddogVolumeFormat,
            base.secretVolumeFormat,
            base.hostPathVolumeFormat,
            base.emptyDirVolumeFormat
        ]
    },


    Requirements_manifest: {
        Required: util.Required(base.manifest_requirements)
    },

    Requirements_system: {
        Required: util.Required(base.system_requirements)
    },

    Requirements_functions: {
        Required: util.Required(base.functions_requirements)
    },

    Requirements_env: {
        Required: util.Required(base.env_requirements)
    },

    Requirements_httpGet: {
        Required: util.Required(base.httpGet_requirements)
    },

    Requirements_container: {
        Required: util.Required(base.container_requirements.required),
        Unsupported: util.Unsupported(unsupported=base.container_requirements.unsupported)
    },

    Requirements_volumeMount: {
        Required: util.Required(base.volumeMounts_requirements.required),
        Unsupported: util.Unsupported(unsupported=base.volumeMounts_requirements.unsupported)
    }
    
}