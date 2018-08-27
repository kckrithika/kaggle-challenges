local packagesvc = import "firefly-package-svc.jsonnet.TEMPLATE";
local configs = import "config.jsonnet";

if configs.estate == "prd-samtwo" then
packagesvc {
    env:: super.env + [
        {
            name: "instanceType",
            value: "manifests",
        },
        {
            name: "packageQ",
            value: "test-manifests.package",
        },
        {
            name: "promotionQ",
            value: "test-manifests.promotion",
        },
        {
            name: "latestfileQ",
            value: "test-manifests.latestfile",
        },
   ],
}
else "SKIP"
