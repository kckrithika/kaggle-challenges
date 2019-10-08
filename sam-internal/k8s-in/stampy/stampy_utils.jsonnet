local configs = import "config.jsonnet";

local apiserverEstates = {
    "prd-samtest": true,
    "prd-samdev": true,
    "prd-sam": true
};

{
  apiserver: {
      featureFlag: (std.objectHas(apiserverEstates, configs.estate) && apiserverEstates[configs.estate]),
  },
}