local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local estate = std.extVar("estate");
local madkub_common = import "madkub_common.jsonnet";
local flowsnake_images = import "flowsnake_images.jsonnet";
local new_std = import "stdlib_0.12.1.jsonnet";
local pki_kingdom = (if "upcase_pki_kingdom" in flowsnake_images.feature_flags then new_std.asciiUpper(std.extVar("kingdom")) else std.extVar("kingdom"));

# app_name is used internally to identify the Kubernetes resources
local app_name = "impersonation-proxy";

local certs = madkub_common.make_cert_config([
    {
        name: app_name,
        dir: "/certs-nginx-server",
        type: "server",
    },
]);
local cert = certs[0];

if !flowsnake_config.impersonation_proxy_enabled then
"SKIP"
else
{
    local label_node = self.spec.template.metadata.labels,
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "impersonation-proxy",
        },
        name: "impersonation-proxy",
        namespace: "flowsnake",
    },
    spec: {
        progressDeadlineSeconds: 600,
        replicas: flowsnake_config.impersonation_proxy_replicas,
        revisionHistoryLimit: 2,
        selector: {
            matchLabels: {
                name: label_node.name,
                apptype: label_node.apptype,
            },
        },
        template: {
            metadata: {
                annotations: {
                    "madkub.sam.sfdc.net/allcerts": std.toString({
                        certreqs: [
                            {
                                name: cert.name,
                                role: "flowsnake." + flowsnake_config.role_munge_for_estate(app_name),
                                san: [
                                    flowsnake_config.api_slb_fqdn,
                                    flowsnake_config.service_mesh_fqdn(flowsnake_config.api_public_name),
                                ],
                                "cert-type": cert.type,
                                kingdom: pki_kingdom,
                            },
                        ],
                    }),
                },
                labels: {
                    apptype: "control",
                    name: app_name,
                    flowsnakeOwner: "dva-transform",
                    flowsnakeRole: "ImpersonationProxy",
                },
                namespace: "flowsnake",
            },
            spec: {
                serviceAccountName: "flowsnake-impersonation-proxy",
                automountServiceAccountToken: true,
                containers: [
                    {
                        name: "nginx",
                        image: flowsnake_images.impersonation_proxy,
                        env: [
                            {
                                name: "PROXY_HOST",
                                value: "impersonation-proxy.flowsnake.svc.cluster.local",
                            },
                            {
                                name: "PROXY_PORT",
                                value: "443",
                            },
                            {
                                name: "PROXY_CERT",
                                value: cert.cert_path,
                            },
                            {
                                name: "PROXY_KEY",
                                value: cert.key_path,
                            },
                            {
                                name: "TARGET_HOST",
                                # Currently we cannot use this standard service name
                                # value: "kubernetes.default.svc.cluster.local",
                                #
                                # This is a temporary work-around.
                                # We would like to access the KubeAPI by the standard kubernetes.default.svc.cluster.local service name. However,
                                # because kube-api uses a MadDog host cert without that name in the cert SANs, TLS handshake fails.
                                # Hopefully that will be fixed some day.
                                #
                                # For now, we hack around this by using a DNS name that we know is on the cert (and is not used for other purposes)
                                # and creating a HostAlias for it.
                                # The DNS name we will use is <role-name>.sfdc-role, where <role-name> is the host's estates role name (not to be confused with
                                # device/GUS/Puppet roles).
                                #
                                # https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/#adding-additional-entries-with-hostaliases
                                #
                                value: flowsnake_config.estate_master_role,
                            },
                            {
                                name: "TARGET_PORT",
                                value: "443",
                            },
                            {
                                name: "CA_CERT",
                                value: cert.ca_path,
                            },
                            {
                                # Standard location; see https://kubernetes.io/docs/tasks/access-application-cluster/access-cluster/#accessing-the-api-from-a-pod
                                name: "SERVICE_ACCOUNT_TOKEN_FILE",
                                value: "/var/run/secrets/kubernetes.io/serviceaccount/token",
                            },
                        ],
                        imagePullPolicy: flowsnake_config.default_image_pull_policy,
                        livenessProbe: {
                            # Note: probes do not verify server certificate, so no need to configure CA.
                            httpGet: {
                                path: "/healthz",
                                port: 443,
                                scheme: "HTTPS",
                            },
                            timeoutSeconds: 10,
                        },
                        ports: [
                            {
                                containerPort: 443,
                                name: "https-proxy",
                                protocol: "TCP",
                                hostPort: 8444,
                            },
                        ],
                        readinessProbe: {
                            # Note: probes do not verify server certificate, so no need to configure CA.
                            httpGet: {
                                path: "/healthz",
                                port: 443,
                                scheme: "HTTPS",
                            },
                            timeoutSeconds: 10,
                        },
                        resources: {
                            limits: {
                                memory: "270Mi",
                            },
                            requests: {
                                cpu: "100m",
                                memory: "70Mi",
                            },
                        },
                    volumeMounts: madkub_common.cert_mounts(certs),
                    },
                    madkub_common.refresher_container(certs),
                ],
                initContainers: [
                    madkub_common.init_container(certs),
                ],
                volumes: madkub_common.cert_volumes(certs),
                hostAliases: [{
                    # See TARGET_HOST comments above
                    # Every Kubernetes cluster in the company currently uses this IP as the ClusterIP for the
                    # kubeapi-service, so this is slightly less brittle than it appears.
                    # https://git.soma.salesforce.com/sam/puppet_kubernetes_module/blob/b5b89b8843f517f60a8978c02999cf08c7d5bfc1/manifests/variables.pp#L118
                    ip: "10.254.208.1",
                    hostnames: [flowsnake_config.estate_master_role],
                }],
            },
        },
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 1,
            },
        },
    },
}
