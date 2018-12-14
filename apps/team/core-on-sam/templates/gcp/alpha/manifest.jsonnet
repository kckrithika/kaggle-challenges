local casamTmptl = import "../../casam.libsonnet";

local prdEnv = import "../env.json";
local env = import "env.json";

local alpha = prdEnv + env;

casamTmptl.newCasam(region='gcp', instanceName='alpha', env=alpha)
