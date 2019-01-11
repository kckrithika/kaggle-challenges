local flowsnakeconfig = import "flowsnake_config.jsonnet";
local madkub_common = import "madkub_common.jsonnet";
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";

if flowsnakeconfig.is_test then
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "madkub-required-containers",
        namespace: "flowsnake",
    },
    data: {
		// TODO: fix sam/manifests validator bug
        "volumes.jaysawn": std.toString([
            madkub_common.certs_volume,
            madkub_common.tokens_volume,
        ] +
        (if !flowsnakeconfig.is_minikube then
            certs_and_kubeconfig.platform_cert_volume
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
