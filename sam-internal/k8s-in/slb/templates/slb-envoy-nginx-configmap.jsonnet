local configs = import "config.jsonnet";
local slbimages = import "slbimages.jsonnet";
local slbconfigs = import "slbconfig.jsonnet";
local slbflights = import "slbflights.jsonnet";

local default_nginx_conf = import "config/default-nginx-conf.libsonnet";
local service_mesh_conf = import "config/service-mesh-conf.libsonnet";

if slbconfigs.isSlbEstate && slbflights.envoyProxyEnabled then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "slb-envoy-nginx-configuration",
        namespace: "sam-system",
        labels: configs.ownerLabel.slb,
    },
    data: {
        "default.conf": std.toString(default_nginx_conf.data),
        "service-mesh.conf": std.toString(service_mesh_conf.data),
    },
} else "SKIP"
