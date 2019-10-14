local configs = import "config.jsonnet";

local apiserverEstates = {
    "prd-samtest": true,
    "prd-samdev": true,
    "prd-sam": true,
    "xrd-sam": true,
    "cdg-sam": true,
    "cdu-sam": true,
    "chx-sam": true,
    "dfw-sam": true,
    "fra-sam": true,
    "frf-sam": true,
    "hio-sam": true,
    "hnd-sam": true,
    "ia2-sam": true,
    "ia4-sam": true,
    "ttd-sam": true,
    "wax-sam": true
};

{
  apiserver: {
      featureFlag: (std.objectHas(apiserverEstates, configs.estate) && apiserverEstates[configs.estate]),
  },
}