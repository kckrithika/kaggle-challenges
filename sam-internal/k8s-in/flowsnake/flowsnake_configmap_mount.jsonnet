local flowsnakeconfig = import "flowsnake_config.jsonnet";
{
    k8s_cert_volume:
        (if flowsnakeconfig.maddog_enabled then [
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
        ] else []) +
        (if flowsnakeconfig.cert_services_preferred then [
            {
                name: "data-cert",
                hostPath: {
                    path: "/data/certs",
                },
            },
        ] else []),
    k8s_cert_volumeMounts:
        (if flowsnakeconfig.maddog_enabled then [
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
        ] else []) +
        (if flowsnakeconfig.cert_services_preferred then [
            {
                mountPath: "/data/certs",
                name: "data-cert",
                readOnly: true,
            },
        ] else []),
    platform_cert_volume:
        (if flowsnakeconfig.maddog_enabled then [
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
        ] else []) +
        (if flowsnakeconfig.cert_services_preferred then [
            {
                name: "data-cert",
                hostPath: {
                    path: "/data/certs",
                },
            },
        ] else []),
    platform_cert_volumeMounts:
        (if flowsnakeconfig.maddog_enabled then [
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
        ] else []) +
        (if flowsnakeconfig.cert_services_preferred then [
            {
                mountPath: "/data/certs",
                name: "data-cert",
                readOnly: true,
            },
        ] else []),
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
