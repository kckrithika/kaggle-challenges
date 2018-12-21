local flowsnakeconfig = import "flowsnake_config.jsonnet";
local madkub_common = import "madkub_common.jsonnet";
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local cert_name = "madkubinjector";

if flowsnakeconfig.is_test then
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
            madkub_common.cert_volumes(cert_name)+
        (if !flowsnakeconfig.is_minikube then []
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
