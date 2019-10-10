local configs = import "config.jsonnet";

local apiserverEstates = {
    "prd-samtest": true,
    "prd-samdev": true,
    "prd-sam": true,
    "xrd-sam": true,
    "chx-sam": true,
    "ttd-sam": true
};

{
  apiserver: {
      featureFlag: (std.objectHas(apiserverEstates, configs.estate) && apiserverEstates[configs.estate]),
  },
}