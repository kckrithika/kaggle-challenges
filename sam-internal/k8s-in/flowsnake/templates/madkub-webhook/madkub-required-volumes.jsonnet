local flowsnake_config = import "flowsnake_config.jsonnet";
local madkub_common = import "madkub_common.jsonnet";
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";

local certs = madkub_common.make_cert_config([
    {
        name: "usercerts",
        dir: "/certs",
        type: "client",
        volume: "datacerts",
    }]
    + (if std.objectHas(flowsnake_images.feature_flags, "madkub_injector_server_cert") then [
    {
        name: "servercerts",
        dir: "/servercerts",
        type: "server",
        volume: "servercerts",
    }] else [])
);

if flowsnake_config.madkub_enabled then
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "madkub-required-volumes",
        namespace: "flowsnake",
    },
    data: {
		// TODO: fix sam/manifests validator bug
        "volumes.jaysawn": std.toString(
            madkub_common.cert_volumes(certs)+
        (if !flowsnake_config.is_minikube then []
        else [
            {
              hostPath: {
                  path: "/tmp/sc_repo",
              },
              name: "maddog-onebox-certs",
            },
        ]),
    )}
} else "SKIP"
