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
          tlscertificate: "secret_service:slbTest:kmscert-prd-20181102-signed",
          tlskey: "kms:1:2:4A4C6C75332A0547BB81D5263A9D2F939FB4590FF9AF15C5403A656F8BB913D2:85cbe09f-790c-43a8-aecc-eb4376ef6a45",  # prd
        }
        else if configs.estate == "xrd-sam" then {
          tlscertificate: "secret_service:slbTest:kmscert-xrd-20181102-signed",
          tlskey: "kms:1:2:4A4C6C75332A0547BB81D5263A9D2F939FB4590FF9AF15C5403A656F8BB913D2:79f1260d-ce7b-4eac-8876-709bd0185683",  # xrd
        } else {}),
];

local cnames = if configs.estate == "prd-sam" then [] else [{ cname: "kms-" + configs.kingdom + ".slb.sfdc.net" }];

if slbconfigs.hsmNginxEnabledEstate then
    slbbaseservice.slbCanaryBaseService("slb-canary-proxy-http", canaryPortConfig, serviceName, vipName, cnames) {
} else "SKIP"
