local casamTmptl = import "../../casam.libsonnet";

local prdEnv = import "../env.json";
local env = import "env.json";
local cs103 = prdEnv + env;

casamTmptl.newCasam(region='fra', instanceName='cs103', env=cs103)
