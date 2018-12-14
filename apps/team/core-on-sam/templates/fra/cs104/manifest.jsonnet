local casamTmptl = import "../../casam.libsonnet";

local prdEnv = import "../env.json";
local env = import "env.json";
local cs104 = prdEnv + env;

casamTmptl.newCasam(region='fra', instanceName='cs104', env=cs104)
