local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

# The purpose of this file is to maintain a central set of booleans for new services that
# we slowly roll from a small set of kingdoms/estates to everywhere for safety reasons.
# By defining these flags centrally we dont need to copy-paste the same if statements across
# many templates.
#
# This is not intended for kingdom/estate selection for something that by-design will only run
# in a small subset of places.  (Like our jenkins runs only in prd-sam and has no plans to run in prod)

{

    # for the first pr keeping logic the same, but we should unify this with the one above
    rbacwd: !utils.is_gia(configs.kingdom) && !utils.is_flowsnake_cluster(configs.estate) && configs.estate != "prd-sdc",

    # MadDog
    maddogforsamapps: true,

    # EstatesSvc gets an rpm from estates but that does not have data for GIA or public cloud
    # NodeController uses estatesSvc.
    estatessvc: !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom),

    # kubedns is enabled in a few select test clusters.
    kubedns: (configs.kingdom == "yhu" || configs.kingdom == "ord" || configs.kingdom == "frf" || configs.kingdom == "prd" || configs.kingdom == "xrd") && !utils.is_flowsnake_cluster(configs.estate),

    # k8sproxy is enabled in test clusters.
    k8sproxy:
        configs.estate == "prd-samdev" ||
        configs.estate == "prd-samtest" ||
        configs.estate == "prd-sam" ||
        configs.estate == "prd-sdc" ||
        configs.estate == "xrd-sam",

     syntheticwdPagerDutyEnabled: true,

     maddogCopyTestCA: (if configs.kingdom == "prd" then true),

     sdpv1: configs.estate == "prd-sam",

     # Whether nodes are patched by node-controller with the max sdn pod count resource ("sam.sfdc.net/ip-address").
     ipAddressCapacityNodeResource: std.setMember(configs.estate, std.set(["prd-samdev", "prd-samtest", "prd-sam", "prd-sdc"])),

     # Whether the SAM app controller injects a request for an IP address ("sam.sfdc.net/ip-address") for non-host network pods.
     ipAddressCapacityRequest: std.setMember(configs.estate, configs.ipAddressResourceRequestEnabledEstates),

     enableIdentityEnvVar:
        configs.kingdom == "prd",

     kafkaProducer:
       configs.estate != "prd-sdc" && configs.estate != "vpod",

     kafkaConsumer:
       configs.estate == "prd-sam" || configs.estate == "prd-samtwo",
}
