local casamTmptl = import "../../casam.libsonnet";

local prdEnv = import "../env.json";
local env = import "env.json";

local na6 = prdEnv + env;

casamTmptl.newCasam(region='prd', instanceName='na6', env=na6)
