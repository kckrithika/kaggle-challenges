# NOTE for k8s validation, only override fields that require SAM logic over it
# Let the Kubernetes schema handle the rest (We don't want to deal with that 15k line monster)

local base = import "base-config.jsonnet";
local util = import "../../util.jsonnet";
local config = import "../k8s-overwrite.jsonnet";

local schemaID = "k8sConfigs";

{
    # JSON Schema Keyword, $id is used to help the main schema reference to this file
    "$id": schemaID,


    # Same as IsDNS1123Label
    Rule_IsDNSValidation: {
        maxLength: 63,
        pattern: "^[a-z0-9]([-a-z0-9]*[a-z0-9])?$"
    },


    Rule_IsDNS1035Validation: {
        maxLength: 63,
        pattern: "^[a-z]([-a-z0-9]*[a-z0-9])?$"
    },


    Rule_ValidateVolumes: {
        // BannedHostPaths: util.ValuesNotAllowed(config.bannedHostPaths)
        BannedHostPaths: base.BannedVolumeHostPaths
    },


    Rule_AnnotationValidation: base.AnnotationValidation,


    Rule_LabelsValidation: base.LabelsValidation,


    Rule_ValidateNameInContainer: {
        IsEnvVarName: util.MatchRegex(base.envVarNamePattern),
        IsQualifiedName: base.isQualifiedName,
    },


    Rule_AffinityValidation: base.affinityValidation,


    Rule_SLBAnnotationValidation: base.SLBAnnotationValidation,


    Rule_StatefulSetSpecRequirements: {
        MustExist: util.Required(base.statefulSetSpecRequirements)
    },
}