local casamTmptl = import "../../casam.libsonnet";

local prdEnv = import "../env.json";
local env = import "env.json";

local na3 = prdEnv + env;

casamTmptl.newCasam(region='prd', instanceName='na3', env=na3)
