local madkub_common = import "madkub_common.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";
local enabled = std.objectHas(flowsnake_images.feature_flags, "madkub_injector");

if enabled then
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "madkub-container-spec",
        namespace: "flowsnake",
    },
    data: {
        // TODO: fix sam/manifests validator bug
        "spec.jaysawn": std.toString(madkub_common.init_container("usercerts"))
    }
} else "SKIP"
