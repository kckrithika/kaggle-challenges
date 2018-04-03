local flowsnakeimages = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local util = import "util_functions.jsonnet";
local kingdom = std.extVar("kingdom");
if util.is_production(kingdom) then
{
  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  metadata: {
    name: "FakeDeplyForImgPromo",
  },
  spec: {
    containers: [[
    {
      count: 0,
      image: flowsnakeconfig.registry + "/" + imageName + ":" + imageTag,
      name: imageName,
    }
for imageName in flowsnakeimages.flowsnakeImagesToPromote
] for imageTag in [flowsnakeimages.version_mapping.main[version] for version in std.objectFields(flowsnakeimages.version_mapping.main)]],
  },
} else "SKIP"
