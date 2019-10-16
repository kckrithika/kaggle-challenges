local configs = import "config.jsonnet";

local apiserverEstates = {
    "prd-samtest": true,
    "prd-samdev": true,
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
    "ia5-sam": true,
    "iad-sam": true,
    "lo2-sam": true,
    "lo3-sam": true,
    "ord-sam": true,
    "par-sam": true,
    "ph2-sam": true,
    "phx-sam": true,
    "prd-sam": true,
    "syd-sam": true,
    "ttd-sam": true,
    "ukb-sam": true,
    "wax-sam": true,
    "xrd-sam": true,
    "yhu-sam": true,
    "yul-sam": true
};

{
  apiserver: {
      featureFlag: (std.objectHas(apiserverEstates, configs.estate) && apiserverEstates[configs.estate]),
  },
}