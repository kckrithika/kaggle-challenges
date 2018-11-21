local base = import "base-config.jsonnet";
local util = import "util.jsonnet";
local config = import "../manifest-overwrite.jsonnet";

local schemaID = "manifestConfigs";

{
    # JSON Schema Keyword, $id is used to help the main schema reference to this file
    "$id": schemaID,


    LivenessProbeExceptions: config.livenessProbeExceptions,


    Rule_ReservedPorts: util.ListNotAllowed(config.reservedPorts),


    Rule_HostPathList: util.MatchRegex(config.allowedHostPathList.allowed, config.allowedHostPathList.notAllowed),


    Rule_ImageForm: util.MatchRegex(config.imageForm.allowed, config.imageForm.notAllowed),


    Rule_EnvVariableName: {
        EnvNamePatterns: util.MatchRegex(base.envNamePattern),
        ReservedEnvName: util.ValuesNotAllowed(config.reservedEnvName)
    },


    Rule_IsDNSValidation: {
        maxLength: 63,
        pattern: "^[a-z0-9]([-a-z0-9]*[a-z0-9])?$"
    },


    Rule_MaddogValidation: base.maddogValidation,


    Rule_VolumeMountValidation: {
        MountPathPattern: util.MatchRegex(base.mountPathPattern),
        SecretVolume: base.secretVolumeMountValidation
    },


    Rule_VolumesFormat: {
        anyOf: [
            base.maddogVolumeFormat,
            base.secretVolumeFormat,
            base.hostPathVolumeFormat,
            base.emptyDirVolumeFormat
        ]
    },


    Rule_ManifestRequirements: {
        MustExist: util.Required(base.manifest_requirements)
    },

    Rule_SystemRequirements: {
        MustExist: util.Required(base.system_requirements)
    },

    Rule_FunctionsRequirements: {
        MustExist: util.Required(base.functions_requirements)
    },

    Rule_EnvRequirements: {
        MustExist: util.Required(base.env_requirements)
    },

    Rule_HttpGetRequirements: {
        MustExist: util.Required(base.httpGet_requirements)
    },

    Rule_ContainerRequirements: {
        MustExist: base.container_requirements.mustExist,
        NotAllowed: base.container_requirements.notAllowed
    },

    Rule_VolumeMountRequirements: {
        MustExist: util.Required(base.volumeMounts_requirements.mustExist),
        NotAllowed: util.NotAllowed(base.volumeMounts_requirements.notAllowed)
    }

}