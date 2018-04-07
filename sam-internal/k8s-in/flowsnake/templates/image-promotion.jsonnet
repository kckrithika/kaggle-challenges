local flowsnakeimages = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local util = import "util_functions.jsonnet";
local kingdom = std.extVar("kingdom");
if util.is_production(kingdom) then
{
  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  spec: {
    template: {
      spec: {
        containers: std.flattenArrays([
[
          {
            name: imageName,
            image: flowsnakeconfig.strata_registry + "/" + imageName + ":" + flowsnakeimages.version_mapping.main[version],
          }
        for imageName in flowsnakeimages.flowsnakeImagesToPromote
]
        for version in std.objectFields(flowsnakeimages.version_mapping.main)
]),
      },
    },
  },
} else "SKIP"
