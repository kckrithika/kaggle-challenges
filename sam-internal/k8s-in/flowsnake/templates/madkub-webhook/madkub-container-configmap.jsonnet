local flowsnakeconfig = import "flowsnake_config.jsonnet";
local madkub_common = import "madkub_common.jsonnet";

if flowsnakeconfig.is_test then
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "madkub-container-spec"
    },
    data: {
        // TODO: fix sam/manifests validator bug
        "spec.jaysawn": std.toString(madkub_common.init_container("usercerts"))
    }
} else "SKIP"
