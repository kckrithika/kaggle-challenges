local flowsnake_images = import "flowsnake_images.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local prefetch_config = import "image_prefetch_config.jsonnet";

local images_to_prefetch = [
        flowsnake_config.registry + (if std.startsWith(img, "/") then img else "/" + img)
        for img in prefetch_config[flowsnake_config.deployment_region]                
    ];


if ! ("prefetcher_enabled" in flowsnake_images.feature_flags) then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "flowsnake-prefetcher-configmap",
        namespace: "flowsnake",        
    },
    data: {
        "prefetch_images.txt": std.join("\n", images_to_prefetch),
        "prefetcher.sh": importstr "prefetcher.sh",
    }
}