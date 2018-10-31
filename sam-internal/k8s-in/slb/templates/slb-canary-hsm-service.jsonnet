local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbimages = (import "slbimages.jsonnet") + { templateFilename:: std.thisFile };
local slbportconfiguration = import "slbportconfiguration.libsonnet";
local slbbaseservice = import "slb-base-service.libsonnet";
local slbflights = import "slbflights.jsonnet";
local utils = import "util_functions.jsonnet";

local canaryName = "slb-canary-hsm";
local serviceName = canaryName + "-service";
local vipName = canaryName;

local canaryPortConfig = [
    slbportconfiguration.newPortConfiguration(
        port=443,
        lbType="http",
        name=canaryName + "-port",
        nodePort=0,
    ) {
        tls: true,
        reencrypt: true,
    } + (if (configs.estate == "prd-sdc" || configs.estate == "prd-sam") then {
          tlscertificate: "secret_service:slbTest:kmscert-prd-20181030-signed",
          tlskey: "kms:1:2:4A4C6C75332A0547BB81D5263A9D2F939FB4590FF9AF15C5403A656F8BB913D2:3d023dc5-8926-4c60-9dc0-6386bcacbdde",  # prd
        }
        else if configs.estate == "xrd-sam" then {
          tlscertificate: "secret_service:slbTest:kmscert-xrd-20181030-signed",
          tlskey: "kms:1:2:4A4C6C75332A0547BB81D5263A9D2F939FB4590FF9AF15C5403A656F8BB913D2:8a2b0f29-6b17-4f1f-9019-5b5302814148",  # xrd
        } else {}),
];

local cnames = [{ cname: "kms-" + configs.kingdom + ".slb.sfdc.net" }];

if slbflights.hsmCanaryEnabled then
    slbbaseservice.slbCanaryBaseService("slb-canary-proxy-http", canaryPortConfig, serviceName, vipName, cnames) {
} else "SKIP"
