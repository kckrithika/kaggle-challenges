local configs = import "config.jsonnet";

// Public functions
{
    string_replace(str, to_replace, replace_with):: (
        std.join("", std.map(function(x) if x == to_replace then replace_with else x, std.stringChars(str)))
    ),
    // log_init_volumes provides the set of volumes necessary to support propagation of logs to the host.
    log_init_volumes():: [
        {
            name: "container-log-vol",
            emptyDir: {},
        },
        {
            name: "host-log-vol",
            hostPath: {
                path: "/var/log"
            },
        },
    ],
    // log_init_volume_mounts provides the set of volume mounts necessary to support propagation of logs to the host.
    log_init_volume_mounts():: [
        {
            mountPath: "/var/log",
            name: "container-log-vol"
        },
        {
            mountPath: "/var/log-mounted",
            name: "host-log-vol",
        },
    ],
    // log_init_container generates the init container necessary to support propagation of logs to the host.
    // image_name: name of the loginitcontainer docker image.
    // pod_log_path: log path (relative to /var/log/) for logs from the pod.
    // uid: userid for the process writing logs.
    // gid: groupid for the process writing logs.
    // username: username corresponding to uid.
    log_init_container(image_name, pod_log_path, uid, gid, username):: {
        command: [
            "sh",
            "-c",
            "/entrypoint.sh -g " + gid + " -u " + uid + " -s " + username + " -l " + pod_log_path,
        ],
        name: "log-init",
        image: image_name,
        securityContext: {
            privileged: true,
        },
        volumeMounts: $.log_init_volume_mounts(),
        env: [
            {
                name: "KUBEVAR_POD_NAME",
                valueFrom: {
                    fieldRef: {
                        fieldPath: "metadata.name",
                    },
                },
            },
            {
                name: "KUBEVAR_POD_NAMESPACE",
                valueFrom: {
                    fieldRef: {
                        fieldPath: "metadata.namespace",
                    },
                },
            },
        ],
    },

    // sfms_environment_vars returns the set of environment variables to pass to an sfms container.
    sfms_environment_vars(serviceName):: [
        {
            name: "SFDC_FUNNEL_VIP",
            value: configs.funnelVIP,
        },
        {
            name: "MC_KINGDOM",
            value: configs.kingdom,
        },
        {
            name: "MC_ESTATE",
            value: configs.estate,
        },
        {
            name: "MC_NAME",
            value: serviceName,
        },
        {
            name: "MC_NAMESPACE",
            valueFrom: {
                fieldRef: {
                    fieldPath: "metadata.namespace",
                },
            },
        },
        {
            name: "MC_NODE",
            valueFrom: {
                fieldRef: {
                    fieldPath: "spec.nodeName",
                },
            },
        },
        {
            name: "MC_DEVICE",
            valueFrom: {
                fieldRef: {
                    fieldPath: "metadata.name",
                },
            },
        },
    ],

    // This is WIP and slowly we will call this to generate storageclass
    // per request
    make_storage_class(estate,name,namespace,clusters,size) :: {
    "apiVersion": "csp.storage.salesforce.com/v1",
    "kind": "CustomerStoragePool",
    "metadata": {
        "name": "someName",
        "namespace": "someNamespace",
        "annotations": {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    "spec": {
        "clusterNamespace": "legostore",
        "size": "50Gi",
        "storageTier": "hdd" ,
    }
}
}
