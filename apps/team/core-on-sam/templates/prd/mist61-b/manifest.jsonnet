local casamTmptl = import "../../casam.libsonnet";

local prdEnv = import "../env.json";
local env = import "env.json";

local mist61B = prdEnv + env;

casamTmptl.newCasam(region='prd', instanceName='mist61-b', env=mist61B)
