{
    cert_volume: [
        {
            name: "certificate-authority",
            hostPath: {
                path: "/etc/pki_service/ca"
            }
        },
        {
            name: "client-certificate",
            hostPath: {
                path: "/etc/pki_service/kubernetes/k8s-client/certificates"
            }
        },
        {
            name: "client-key",
            hostPath: {
                path: "/etc/pki_service/kubernetes/k8s-client/keys"
            }
        },
        {
            name: "data-cert",
            hostPath: {
                path: "/data/certs"
            }
        },
    ],
    cert_volumeMounts: [
        {
            mountPath: "/etc/pki_service/ca",
            name: "certificate-authority",
            readOnly: true
        },
        {
            mountPath: "/etc/pki_service/kubernetes/k8s-client/certificates",
            name: "client-certificate",
            readOnly: true
        },
        {
            mountPath: "/etc/pki_service/kubernetes/k8s-client/keys",
            name: "client-key",
            readOnly: true
        },
        {
            mountPath: "/data/certs",
            name: "data-cert",
            readOnly: true
        },
    ],
    kubeconfig_volumeMounts: [
        {
           mountPath: "/etc/kubernetes/kubeconfig",
           name: "kubeconfig",
           readOnly: true
        },
    ],
    kubeconfig_volume: [
        {
            hostPath: {
              path: "/etc/kubernetes/kubeconfig"
            },
            name: "kubeconfig"
        },
    ]
}
