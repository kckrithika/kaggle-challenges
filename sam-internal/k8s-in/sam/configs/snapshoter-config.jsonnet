local samimages = import "samimages.jsonnet";
local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then
{
  recipient: "sam@salesforce.com",
  "ca-file": configs.caFile,
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
  kafkaEndpoint: "ajna0-broker1-0-prd.data.sfdc.net:9093",
} else "SKIP"
