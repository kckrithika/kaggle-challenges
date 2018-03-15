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
    # RBAC

    # rbac required Kube 1.7 everywhere.  As soon as we fix CDU we can add public cloud.
    rbac: !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom),

    # for the first pr keeping logic the same, but we should unify this with the one above
    rbacwd: !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) && !utils.is_flowsnake_cluster(configs.estate),

    # todo: explain what is blocking this from going everywhere
    rbacstorage: configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" || configs.estate == "phx-sam" || configs.estate == "prd-sam_storagedev",

    # MadDog
    maddogforsamapps: !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom),
    # Keep this in sync with maddog_cert_volume and maddog_cert_volume_mount in configs.jsonnet
    maddogforsamhosts: !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom),

}
