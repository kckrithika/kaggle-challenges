local flowsnakeimages = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local util = import "util_functions.jsonnet";
local kingdom = std.extVar("kingdom");
local configs = import "config.jsonnet";


# Builds an image promotion entry with the image tagged based on the version mapping
local build_mapped_entry(imageName, version) = {
  name: imageName,
  image: flowsnakeconfig.strata_registry + "/" + imageName + ":" + flowsnakeimages.version_mapping.main[version],
};

# Builds an image promotion entry with the image tagged directly with the version
local build_versioned_entry(imageName, version) = {
   name: std.join("-", std.split(imageName, "_")),
   image: flowsnakeconfig.strata_registry + "/" + imageName + ":" + version,
};

if util.is_production(kingdom) then
configs.deploymentBase("flowsnake") {
  spec+: {
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
            build_mapped_entry(imageName, version)
            for imageName in imageNames
          ] +
          std.prune([  #other images will result in a NULL entry, so prune them
            if std.startsWith(imageName, "flowsnake-job") then
                build_versioned_entry(imageName, version)
            for imageName in imageNames
          ])
          for version in std.objectFields(flowsnakeimages.version_mapping.main)
        ]
),
      },
    },
  },
} else "SKIP"
