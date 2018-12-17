local casamTmptl = import "../../casam.libsonnet";

local prdEnv = import "../env.json";
local env = import "env.json";

local na5 = prdEnv + env;

casamTmptl.newCasam(region='prd', instanceName='na5', env=na5)
