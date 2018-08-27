local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";
local pullrequestsvc = import "firefly-pullrequest-svc.jsonnet.TEMPLATE";

if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then
{
  local p = packagesvc {
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
  local r = pullrequestsvc {
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
  apiVersion: "v1",
  kind: "List",
  items: std.flattenArrays([p.items, r.items]),

}
else "SKIP"
