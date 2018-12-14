local casamTmptl = import "../../casam.libsonnet";

local prdEnv = import "../env.json";
local env = import "env.json";

local gatekeeperEnv = prdEnv + env;

casamTmptl.newCasam(region='prd', instanceName='gatekeeper', env=gatekeeperEnv)
