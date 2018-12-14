local casamTmptl = import "../../casam.libsonnet";

local prdEnv = import "../env.json";
local env = import "env.json";

local na10 = prdEnv + env;

casamTmptl.newCasam(region='prd', instanceName='na10', env=na10)
