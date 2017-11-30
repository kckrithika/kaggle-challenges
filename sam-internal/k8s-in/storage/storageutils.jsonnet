// Public functions
{
    string_replace(str, to_replace, replace_with):: (
        std.join("", std.map(function(x) if x == to_replace then replace_with else x, std.stringChars(str)))
    ),
    // image_name: name of the loginitcontainer docker image.
    // pod_log_path: log dir for logs from the pod.
    // uid: userid for the process writing logs.
    // gid: groupid for the process writing logs.
    // username: username corresponding to uid
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
        volumeMounts: [
            {
                mountPath: pod_log_path,
                name: "container-log-vol"
            },
            {
                mountPath: "/var/log-mounted",
                name: "host-log-vol",
            },
        ],
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
}