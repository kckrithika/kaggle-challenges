# This provides a the ability to customize the shell to your liking on a host.
# The mechanism is to put content in a script in a configmap and execute a one-liner that grabs and runs
# the script to install the content.
#
# Initial install on a new host:
#     sudo kubectl --kubeconfig /etc/kubernetes/kubeconfig get configmap/customize-shell -o jsonpath="{.data['customize-shell']}" | bash && source ~/.bashrc
#
# Subsequent updates:
#     customize-shell

local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
      name: "customize-shell",
      namespace: "default",
    },
    data: {
        "customize-shell": importstr "customize-shell.sh",
    },
}
