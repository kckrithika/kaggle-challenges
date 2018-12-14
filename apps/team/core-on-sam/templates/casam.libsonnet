local cacheFunction = import "cache-function.libsonnet";
local coreAppFunction = import "core-app-function.libsonnet";
local sequencerFunction = import "sequencer-function.libsonnet";
local sfProxyFunction = import "sfproxy-function.libsonnet";

// local kaijuFunction = import "kaiju-function.libsonnet";

local coreAppLB = import "core-app-lb.libsonnet";
local sfProxyLB = import "sfproxy-lb.libsonnet";

local defaultEnv = import "default-env.json";

local join(a) =
  local notNull(i) = i != null;
  local maybeFlatten(acc, i) = if std.type(i) == "array" then acc + i else acc + [i];
  std.foldl(maybeFlatten, std.filter(notNull, a), []);

local getCurrentAppColor(env) = if env.casamAppColor == 'blue' then "green" else "blue";

//  This is a hack as we are currently using the na1 server pool the
// core app validation checks for right url naming convention
// However in the production setup we will have an externally setup
// sfproxy and the value for which will specified as env property
local getSfProxyHostName(instanceName) = std.strReplace(instanceName, 'na', 'us') + "-sfproxy-lb";

local getPublicHostName(env) =
  if env.enableSFProxy then
    getSfProxyHostName(env.instanceName) + "." + env.publicDNSSuffix
  else if env.enableCoreAppDebugLB then
    env.instanceName + "-coreapp-lb." + env.publicDNSSuffix
  else env.publicHost;

local getSFProxyCoreappVIP(env) =
  if env.enableSFProxy then
    "https://" + getSfProxyHostName(env.instanceName) + "." + env.publicDNSSuffix + ":8443"
  else
    env.sfProxyVIP;

local getSFProxyEP(env) =
  if env.enableSFProxy then
    "https://" + getSfProxyHostName(env.instanceName) + "." + env.publicDNSSuffix + ":8086"
  else
    env.sfProxyEndpoint;

local getSFProxySFDCEnvironmentValue(env) =
  if env.subEnvName == '-' then
    env.envName
  else
    env.subEnvName;

local getFunctionName(env, name) =
  if env.subEnvName == '-' then
    env.instanceName + "-" + name + "-" + env.region
  else
    env.instanceName + "-" + env.subEnvName + name + "-" + env.region;

local newCasam(region, instanceName, env) = {

  local mergedEnv = defaultEnv + env + {
    instanceName: instanceName,
    region: region,
    publicHostName: getPublicHostName,
    publicEP: getSFProxyCoreappVIP,
    sfProxyEP: getSFProxyEP,
    currentAppColor: getCurrentAppColor,
    sfProxySfdcEnvironment: getSFProxySFDCEnvironmentValue,
  },

  local coreAppFn = coreAppFunction {
    functionName:: getFunctionName(mergedEnv, "coreapp"),
    env:: mergedEnv,
  },

  local sequencerFn = sequencerFunction {
    functionName:: getFunctionName(mergedEnv, "sequencer"),
    env:: mergedEnv,
  },

  local cacheFn = cacheFunction {
    functionName:: getFunctionName(mergedEnv, "cache"),
    env:: mergedEnv,
  },

  // local kaijuFn = kaijuFunction + {
  //   functionName:: "kaiju-" + instanceName,
  //   env:: config.New(env),
  // },

  local sfProxyFn = sfProxyFunction {
    functionName:: getFunctionName(mergedEnv, "sfproxy"),
    lbName:: getSfProxyHostName(instanceName),
    env:: mergedEnv,
  },

  local localSFProxyLB = sfProxyLB {
    functionName:: getFunctionName(mergedEnv, "sfproxy"),
    lbName:: getSfProxyHostName(instanceName),
    env:: mergedEnv,
  },

  local coreAppLBForDebug = coreAppLB {
    functionName:: getFunctionName(mergedEnv, "coreapp"),
    lbName:: instanceName + "-coreapp-lb",
    env:: mergedEnv,
  },

  apiVersion: 'v1',
  system: {
    functions: join([
      if mergedEnv.enableCoreApp then coreAppFn,
      if mergedEnv.enableSequencer then sequencerFn,
      if mergedEnv.enableCache then cacheFn,
      if mergedEnv.enableSFProxy then sfProxyFn,
      // if config.IsKaijuEnabled(env) then kaijuFn,
    ]),
    loadbalancers: join([
      if mergedEnv.enableCoreAppDebugLB then coreAppLBForDebug,
      if mergedEnv.enableSFProxy then localSFProxyLB,
    ]),
  },
};

// Export the function as a constructor for casam app
{
  newCasam:: newCasam,
}
