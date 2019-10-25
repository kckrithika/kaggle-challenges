local prodRollout1Enabled = true;
local prodRollout2Enabled = false;
local prodRollout3Enabled = false;
local prodRollout4Enabled = false;
local prodRollout5Enabled = false;

{
  local rolloutKingdoms = {
     "prd": prodRollout1Enabled,

     "par": prodRollout2Enabled,

     "cdu": prodRollout3Enabled,
     "frf": prodRollout3Enabled,
     "lo2": prodRollout3Enabled,

     "syd": prodRollout4Enabled,
     "ukb": prodRollout4Enabled,
     "fra": prodRollout4Enabled,
     "hnd": prodRollout4Enabled,
     "lo3": prodRollout4Enabled,

     "yul": prodRollout5Enabled,
     "yhu": prodRollout5Enabled,
     "iad": prodRollout5Enabled,
     "ord": prodRollout5Enabled,
     "dfw": prodRollout5Enabled,
     "cdg": prodRollout5Enabled,
     "phx": prodRollout5Enabled,
     "ph2": prodRollout5Enabled,
     "ia2": prodRollout5Enabled,
     "ia4": prodRollout5Enabled,
     "ia5": prodRollout5Enabled,
  },

  is_electron_opa_injector_dev_cluster(estate):: (
    estate == "prd-samdev"
  ),

  is_electron_opa_injector_test_cluster(estate):: (
    estate == "prd-samtest"
  ),

  is_electron_opa_injector_prod_cluster(estate):: (
    estate != "prd-samdev" &&
    estate != "prd-samtest"
  ),

  can_deploy(kingdom):: (
    std.objectHas(rolloutKingdoms, kingdom) && rolloutKingdoms[kingdom]
  ),
}
