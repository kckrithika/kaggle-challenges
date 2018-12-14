local casamTmptl = import "../../casam.libsonnet";

local prdEnv = import "../env.json";
local env = import "env.json";

local steam = prdEnv + env;

casamTmptl.newCasam(region='prd', instanceName='steam', env=steam)
