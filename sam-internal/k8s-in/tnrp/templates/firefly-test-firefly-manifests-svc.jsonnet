local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";
local intakesvc = import "firefly-intake-svc.jsonnet.TEMPLATE";

if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then
{
  local package = packagesvc {
      env:: super.env + [
          {
              name: "instanceType",
              value: "manifests",
          },
          {
              name: "packageQ",
              value: "test-firefly-manifests.package",
          },
          {
              name: "promotionQ",
              value: "test-firefly-manifests.promotion",
          },
          {
              name: "latestfileQ",
              value: "test-firefly-manifests.latestfile",
          },
     ],
  },
  local pullrequest = pullrequestsvc {
      env:: super.env + [
          {
              name: "instanceType",
              value: "manifests",
          },
          {
              name: "rabbitmqQueueName",
              value: "test-firefly-manifests.pr",
          },
          {
              name: "rabbitMqExchangeName",
              value: "firefly.delivery",
          },
     ],

  },
  local intake = intakesvc {
      env:: super.env,
  },

  apiVersion: "v1",
  kind: "List",
  items: std.flattenArrays([package.items, pullrequest.items, intake.items]),

}
else "SKIP"
