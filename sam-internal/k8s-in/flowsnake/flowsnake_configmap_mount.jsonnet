{
    k8s_cert_volume: [
        {
            name: "certificate-authority",
            hostPath: {
                path: "/etc/pki_service/ca",
            },
        },
        {
            name: "client-certificate",
            hostPath: {
                path: "/etc/pki_service/kubernetes/k8s-client/certificates",
            },
        },
        {
            name: "client-key",
            hostPath: {
                path: "/etc/pki_service/kubernetes/k8s-client/keys",
            },
        },
        {
            name: "data-cert",
            hostPath: {
                path: "/data/certs",
            },
        },
    ],
    k8s_cert_volumeMounts: [
        {
            mountPath: "/etc/pki_service/ca",
            name: "certificate-authority",
            readOnly: true,
        },
        {
            mountPath: "/etc/pki_service/kubernetes/k8s-client/certificates",
            name: "client-certificate",
            readOnly: true,
        },
        {
            mountPath: "/etc/pki_service/kubernetes/k8s-client/keys",
            name: "client-key",
            readOnly: true,
        },
        {
            mountPath: "/data/certs",
            name: "data-cert",
            readOnly: true,
        },
    ],
    platform_cert_volume: [
        {
            name: "certificate-authority",
            hostPath: {
                path: "/etc/pki_service/ca",
            },
        },
        {
            name: "client-certificate",
            hostPath: {
                path: "/etc/pki_service/platform/platform-client/certificates",
            },
        },
        {
            name: "client-key",
            hostPath: {
                path: "/etc/pki_service/platform/platform-client/keys",
            },
        },
        {
            name: "data-cert",
            hostPath: {
                path: "/data/certs",
            },
        },
    ],
    platform_cert_volumeMounts: [
        {
            mountPath: "/etc/pki_service/ca",
            name: "certificate-authority",
            readOnly: true,
        },
        {
            mountPath: "/etc/pki_service/platform/platform-client/certificates",
            name: "client-certificate",
            readOnly: true,
        },
        {
            mountPath: "/etc/pki_service/platform/platform-client/keys",
            name: "client-key",
            readOnly: true,
        },
        {
            mountPath: "/data/certs",
            name: "data-cert",
            readOnly: true,
        },
    ],
    kubeconfig_volumeMounts: [
        {
           mountPath: "/etc/kubernetes/kubeconfig",
           name: "kubeconfig",
           readOnly: true,
        },
    ],
    kubeconfig_platform_volume: [
        {
            hostPath: {
              path: "/etc/kubernetes/kubeconfig-platform",
            },
            name: "kubeconfig",
        },
    ],
    kubeconfig_volume: [
        {
            hostPath: {
              path: "/etc/kubernetes/kubeconfig",
            },
            name: "kubeconfig",
        },
    ],
    nginx_volumeMounts: [
        {
            mountPath: "/etc/ssl/certs/ssl-cert-snakeoil.pem",
            name: "server-certificate",
            readOnly: true,
        },
        {
            mountPath: "/etc/ssl/private/ssl-cert-snakeoil.key",
            name: "server-key",
            readOnly: true,
        },
    ],
    nginx_volume: [
        {
            name: "server-certificate",
            hostPath: {
                path: "/etc/pki_service/platform/platform-server/certificates/platform-server.pem",
            },
        },
        {
            name: "server-key",
            hostPath: {
                path: "/etc/pki_service/platform/platform-server/keys/platform-server-key.pem",
            },
        },
    ],
}
