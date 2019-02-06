local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local util = import "util_functions.jsonnet";
local kingdom = std.extVar("kingdom");
local configs = import "config.jsonnet";
local image_renames_and_canary_build_tags = std.objectHas(flowsnake_images.feature_flags, "image_renames_and_canary_build_tags");

# Builds an image promotion entry with the image tagged based on the version mapping
local build_mapped_entry(imageName, version) = {
  name: std.join("-", std.split(std.join("-", std.split(imageName, "_")), ".")),
  image: flowsnakeconfig.strata_registry + "/" + imageName + ":" + flowsnake_images.version_mapping.main[version],
};

# Builds an image promotion entry with the image tagged directly with the version
local build_versioned_entry(imageName, version) = {
   name: std.join("-", std.split(std.join("-", std.split(imageName, "_")), ".")),
   image: flowsnakeconfig.strata_registry + "/" + imageName + ":" + version,
};

# SAM won't pick up images if they're deployed via k8s List files, so add those here.
local extra_images_to_promote = [
    flowsnake_images.watchdog_canary,
];


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
          local imageNames = if std.objectHas(flowsnake_images.flowsnakeImagesToPromoteOverrides, version) then
              flowsnake_images.flowsnakeImagesToPromoteOverrides[version]
          else
               flowsnake_images.flowsnakeImagesToPromote;
          [
            build_mapped_entry(imageName, version)
            for imageName in imageNames
          ] +
          if image_renames_and_canary_build_tags then [] else std.prune([  #other images will result in a NULL entry, so prune them
            if std.startsWith(imageName, "flowsnake-job") then
                build_versioned_entry(imageName, version)
            for imageName in imageNames
          ])
          for version in std.objectFields(flowsnake_images.version_mapping.main)
        ]
        )
        +
        [
          { name: "extra-image-" + ix, image: extra_images_to_promote[ix] }
for ix in std.range(0, std.length(extra_images_to_promote) - 1)
        ]
         /* TODO: remove these after will is done testing spark s3 on prod */
        + [
{
          image: "ops0-artifactrepo1-0-" + kingdom + ".data.sfdc.net/dva/flowsnake-spark-s3:jenkins-dva-transformation-flowsnake-sample-apps-PR-17-2-itest",
          name: "spark-s3",
},
{
          image: "ops0-artifactrepo1-0-" + kingdom + ".data.sfdc.net/dva/flowsnake-spark-s3-worker:jenkins-dva-transformation-flowsnake-sample-apps-PR-17-2-itest",
          name: "spark-s3-worker",
},
],
      },
    },
  },
} else "SKIP"
