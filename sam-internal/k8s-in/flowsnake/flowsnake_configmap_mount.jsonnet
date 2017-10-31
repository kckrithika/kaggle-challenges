{
    cert_volume: {
        name: "certs",
        hostPath: {
            path: "/data/certs"
        }
    },
    cert_volumeMounts: {
        mountPath: "/data/certs",
        name: "certs",
        readOnly: true
    },
    kubeconfig_volumeMounts: {
       mountPath: "/etc/kubernetes/kubeconfig",
       name: "kubeconfig",
       readOnly: true
    },
    kubeconfig_volume: {
        hostPath: {
          path: "/etc/kubernetes/kubeconfig"
        },
        name: "kubeconfig"
    }
}
