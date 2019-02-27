local base = import "base-config.jsonnet";
local util = import "../../util.jsonnet";
local config = import "../manifest-overwrite.jsonnet";

local schemaID = "manifestConfigs";

{
    # JSON Schema Keyword, $id is used to help the main schema reference to this file
    "$id": schemaID,


    LivenessProbeExceptions: config.livenessProbeExceptions,

    # Note: This is the same as IsDNS1123Label
    Rule_IsDNSValidation: {
        maxLength: 63,
        pattern: "^[a-z0-9]([-a-z0-9]*[a-z0-9])?$"
    },

    # Note: IsDNS1035 and IsDNS1123 are both need
    # DNS1035 for LBNames and DNS1123 for everything else
    Rule_IsDNS1035Validation: {
        maxLength: 63,
        pattern: "^[a-z]([-a-z0-9]*[a-z0-9])?$"
    },

    Rule_ReservedPorts: util.ListNotAllowed(config.reservedPorts),

    Rule_ValidateLabels: base.validateLabels,

    Rule_ReservedLabels: base.reservedLabels,

    Rule_HostPathList: util.MatchRegex(config.allowedHostPathList.allowed, config.allowedHostPathList.notAllowed),

    Rule_ImageForm: base.imageValidation,

    Rule_EnvVariableName: {
        EnvNamePatterns: util.MatchRegex(base.envNamePattern),
        ReservedEnvName: util.ValuesNotAllowed(config.reservedEnvName)
    },

    Rule_IdentityValidation: base.identityValidation,

    Rule_MaddogValidation: base.maddogValidation,

    Rule_VolumeMountValidation: {
        MountPathPattern: util.MatchRegex(base.mountPathPattern),
        SecretVolume: base.secretVolumeMountValidation
    },

    Rule_FunctionTypeValidation: {
        TypesAllowed: util.AllowedValues(base.validateFunctionType.typesAllowed),
        TypesRequirements: base.validateFunctionType.typeRequirements
    },

    Rule_ValidateContainerPort: {
        IsValidPortName: base.validateContainerPort.isValidPortName,
        IsValidPortNumber: base.validateContainerPort.isValidPortNumber
    },

    Rule_VolumesFormat: {
        anyOf: [
            base.maddogVolumeFormat,
            base.secretVolumeFormat,
            base.k4aVolumeFormat,
            base.hostPathVolumeFormat,
            base.emptyDirVolumeFormat
        ]
    },

    Rule_LBFunctionOrSelector: base.LBFunctionOrSelector,

    Rule_LBPortsValidation: {
        LBPortAllowedTypes: util.AllowedValues(base.LBPortsValidation.LBPortAllowedTypes),
        LBPortAllowedAlgorithm: util.AllowedValues(base.LBPortsValidation.LBPortAllowedAlgorithm),
        LBPortAlgorithm: base.LBPortsValidation.LBPortAlgorithm,
        LBTypeSpecificParameters: base.LBPortsValidation.LBTypeSpecificParameters,
        LBDestinationPort: base.LBPortsValidation.LBDestinationPort,
        TLSValidation: base.LBPortsValidation.TLSValidation,
        TLSPattern: base.LBPortsValidation.TLSPattern,
        CIDRValidation: base.LBPortsValidation.CIDRValidation
    },

    Rule_InsecureImageValidation: base.insecureImageValidation,


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

    Rule_volumeClaimTemplatesRequirements: {
        MustExist: util.Required(base.volumeClaimTemplates_requirements) 
    },

    Rule_LBRequirements: {
        MustExist: util.Required(base.loadbalancers_requirements)
    },

    Rule_LBPortRequirements: {
        MustExist: util.Required(base.lbPort_requirements)
    },

    Rule_ContainerRequirements: {
        MustExist: base.container_requirements.mustExist,
        NotAllowed: base.container_requirements.notAllowed
    },

    Rule_VolumeMountRequirements: {
        MustExist: base.volumeMounts_requirements.mustExist,
        NotAllowed: base.volumeMounts_requirements.notAllowed
    }

}