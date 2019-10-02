local configs = import "config.jsonnet";

local apiserverEstates = {
    "prd-samtest": true,
    "prd-samdev": true,
};

{
  apiserver: {
      featureFlag: (std.objectHas(apiserverEstates, configs.estate) && apiserverEstates[configs.estate]),
  },
}