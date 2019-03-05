local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local util = import "util_functions.jsonnet";
local kingdom = std.extVar("kingdom");
local configs = import "config.jsonnet";
local image_renames_and_canary_build_tags = std.objectHas(flowsnake_images.feature_flags, "image_renames_and_canary_build_tags");

# Turn an image:tag into a name k8s can use for a container
local image_to_name(imageNameTag) = std.join("-", std.split(std.join("-", std.split(std.split(imageNameTag, ":")[0], "_")), "."));

# Image tagged based on the version mapping
local build_mapped_entry(imageName, version) = imageName + ":" + flowsnake_images.version_mapping.main[version];

# Image tagged directly with the version
local build_versioned_entry(imageName, version) = imageName + ":" + version;

local environment_images_to_promote = std.uniq(std.sort(std.flattenArrays(
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
)));


# SAM won't pick up images if they're deployed via k8s List files, so add those here.
local extra_images_to_promote = [
    flowsnake_images.watchdog_canary,
] +
(if std.objectHas(flowsnake_images.feature_flags, "spark_op_watchdog") then [
        flowsnake_images.watchdog_spark_operator,
    ] else []);


if util.is_production(kingdom) then
{
  apiVersion: "extensions/v1beta1",
  kind: "Deployment",
  spec: {
    template: {
      spec: {
        containers:
        [
          {
            name: image_to_name(imageNameTag),
            image: flowsnakeconfig.strata_registry + "/" + imageNameTag,
          }
          for imageNameTag in environment_images_to_promote
        ]
        +
        [
          { name: "extra-image-" + ix, image: extra_images_to_promote[ix] }
for ix in std.range(0, std.length(extra_images_to_promote) - 1)
        ],
      },
    },
  },
} else "SKIP"
