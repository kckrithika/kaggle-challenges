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
        containers: std.flattenArrays(
        [
          # If an override exists for this version, use it.
          local imageNames = if std.objectHas(flowsnakeimages.flowsnakeImagesToPromoteOverrides, version) then
              flowsnakeimages.flowsnakeImagesToPromoteOverrides[version]
          else
               flowsnakeimages.flowsnakeImagesToPromote;
          [
            {
              name: imageName,
              image: flowsnakeconfig.strata_registry + "/" + imageName + ":" + flowsnakeimages.version_mapping.main[version],
            }
            for imageName in imageNames
          ]
          for version in std.objectFields(flowsnakeimages.version_mapping.main)
        ]
),
      },
    },
  },
} else "SKIP"
