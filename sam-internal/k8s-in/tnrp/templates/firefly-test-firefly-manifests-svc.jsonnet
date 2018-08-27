local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";

if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then
packagesvc {
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
}
else "SKIP"
