local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
 local flowsnakeconfig = import "flowsnake_config.jsonnet";
 local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
 local estate = std.extVar("estate");
 local kingdom = std.extVar("kingdom");

 ### cert_name_folder_map associates named certs with their directory on disk.
 local certs_mounts(cert_name_folder_map) = [{
     mountPath: '/%s' % cert_name_folder_map[cert_name],
     name: cert_name,
 } for cert_name in std.objectFields(cert_name_folder_map)];

 # Simple case: single cert, stored in /certs
 local certs_mount = certs_mounts({ datacerts: "certs" })[0];


 ### cert_name_folder_map associates named certs with their directory on disk.
 local certs_volumes(cert_name_folder_map) = [{
     name: cert_name,
     emptyDir: {
         medium: "Memory",
     },
 } for cert_name in std.objectFields(cert_name_folder_map)];

 # Simple case: single cert, stored in /certs
 local certs_volume = certs_volumes({ datacerts: "certs" })[0];

 local tokens_mount = {
     mountPath: "/tokens",
     name: "tokens",
 };
 local tokens_volume = {
     name: "tokens",
     emptyDir: {
         medium: "Memory",
     },
 };

 ### Refresh container for Madkub - Reloads tokens at regular intervals, required for cert rotation
 ### cert_name_folder_map associates named certs with their directory on disk.
 local refresher_container_multi_cert(cert_name_folder_map) = {
     name: "sam-madkub-integration-refresher",
     args: [
         "/sam/madkub-client",
         "--madkub-endpoint",
         flowsnakeconfig.madkub_endpoint,
         "--maddog-endpoint",
         flowsnakeconfig.maddog_endpoint,
         "--maddog-server-ca",
         if flowsnakeconfig.is_minikube then "/maddog-onebox/ca/security-ca.pem" else "/etc/pki_service/ca/security-ca.pem",
         "--madkub-server-ca",
         if flowsnakeconfig.is_minikube then "/maddog-onebox/ca/ca.pem" else "/etc/pki_service/ca/cacerts.pem",
         "--token-folder",
         "/tokens",
         "--kingdom",
         kingdom,
         "--superpod",
         "None",
         "--estate",
         estate,
         "--refresher",
         "--run-init-for-refresher-mode",
         "--cert-folders",
] + ['%s:/%s' % [name, cert_name_folder_map[name]] for name in std.objectFields(cert_name_folder_map)] +
     (if !flowsnakeconfig.is_minikube then [
         "--funnel-endpoint",
         flowsnakeconfig.funnel_endpoint,
     ] else [
         "--log-level",
         "7",
     ]),
     image: flowsnake_images.madkub,
     resources: {
     },
     volumeMounts: [
         certs_mount,
         tokens_mount,
     ] +
     (if !flowsnakeconfig.is_minikube then
         certs_and_kubeconfig.platform_cert_volumeMounts
     else [
         {
             mountPath: "/maddog-onebox",
             name: "maddog-onebox-certs",
         },
     ]),
     env: [
         {
             name: "MADKUB_NODENAME",
                 valueFrom: {
                     fieldRef: {
                         apiVersion: "v1",
                         fieldPath: "spec.nodeName",
                     },
             },
         },
         {
             name: "MADKUB_NAME",
                 valueFrom: {
                     fieldRef: {
                         apiVersion: "v1",
                         fieldPath: "metadata.name",
                 },
             },
         },
         {
             name: "MADKUB_NAMESPACE",
                 valueFrom: {
                     fieldRef: {
                         apiVersion: "v1",
                         fieldPath: "metadata.namespace",
                 },
             },
         },
     ],
 };

 # Simple case: single cert, stored in /certs directory
 local refresher_container(cert_name) = refresher_container_multi_cert({ [cert_name]: "certs" });

 ### Init container for madkub - initializes connection to Madkub and loads initial certs.  Required for madkub integration
 local init_container_multi_cert(cert_name_folder_map) = {
     name: "sam-madkub-integration-init",
     args: [
         "/sam/madkub-client",
         "--madkub-endpoint",
         flowsnakeconfig.madkub_endpoint,
         "--maddog-endpoint",
         flowsnakeconfig.maddog_endpoint,
         "--maddog-server-ca",
         if flowsnakeconfig.is_minikube then "/maddog-onebox/ca/security-ca.pem" else "/etc/pki_service/ca/security-ca.pem",
         "--madkub-server-ca",
         if flowsnakeconfig.is_minikube then "/maddog-onebox/ca/ca.pem" else "/etc/pki_service/ca/cacerts.pem",
         "--token-folder",
         "/tokens",
         "--kingdom",
         kingdom,
         "--superpod",
         "None",
         "--estate",
         estate,
         "--cert-folders",
] + ['%s:/%s' % [name, cert_name_folder_map[name]] for name in std.objectFields(cert_name_folder_map)] +
     (if !flowsnakeconfig.is_minikube then [
         "--funnel-endpoint",
         flowsnakeconfig.funnel_endpoint,
     ] else [
         "--log-level",
         "7",
     ]),
     image: flowsnake_images.madkub,
     resources: {
     },
     volumeMounts: [
         certs_mount,
         tokens_mount,
     ] +
     (if !flowsnakeconfig.is_minikube then
         certs_and_kubeconfig.platform_cert_volumeMounts
     else [
         {
             mountPath: "/maddog-onebox",
             name: "maddog-onebox-certs",
         },
     ]),
     env: [
         {
         name: "MADKUB_NODENAME",
             valueFrom: {
                 fieldRef: {
                     apiVersion: "v1",
                     fieldPath: "spec.nodeName",
                 },
             },
         },
         {
         name: "MADKUB_NAME",
             valueFrom: {
                 fieldRef: {
                     apiVersion: "v1",
                     fieldPath: "metadata.name",
                 },
             },
         },
         {
         name: "MADKUB_NAMESPACE",
             valueFrom: {
                 fieldRef: {
                     apiVersion: "v1",
                     fieldPath: "metadata.namespace",
                 },
             },
         },
     ],
 };

 # Simple case: single cert, stored in /certs directory
 local init_container(cert_name) = init_container_multi_cert({ [cert_name]: "certs" });

 ## Expose common bits for external use / consumption
 {
     certs_mount: certs_mount,
     certs_mounts:: certs_mounts,
     certs_volume: certs_volume,
     certs_volumes:: certs_volumes,
     tokens_volume: tokens_volume,

     refresher_container:: refresher_container,
     init_container:: init_container,
 }
