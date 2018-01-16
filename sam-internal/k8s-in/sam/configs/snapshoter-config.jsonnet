local samimages = import "samimages.jsonnet";
local configs = import "config.jsonnet";

if configs.estate == "dfw-sam" || configs.estate == "phx-sam" || configs.estate == "frf-sam" || configs.estate == "prd-samdev" then {
  recipient: "sam@salesforce.com",
  "ca-file": configs.caFile,
  "key-file": configs.keyFile,
  "cert-file": configs.certFile,
  kafkaEndpoint: "ajna0-broker1-0-" + configs.kingdom + ".data.sfdc.net:9093",
  "kafka-topic": "sfdc.prod.sam__" + configs.kingdom + ".ajna_local__resourcestatus",
} else "SKIP"
