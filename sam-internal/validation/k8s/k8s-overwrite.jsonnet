local util = import "../util.jsonnet";

{
    // List of Volume Host Paths that cannot be used
    // TODO: Add /sbin someday if slb-realsvrcfg stops using it
    bannedHostPaths:: [
        "/", 
        "/var", 
        "/usr", 
        "/bin", 
        "/lib", 
        "/sys", 
        "/opt", 
        "/boot"
    ],

    // List of SAM and K8s reserved Labels
    ReservedLabelsRegex:: [
        "^" + "bundleName" + "$",
        "^" + "deployed_by" + "$",
        "^" + "pod-template-hash" + "$",
        "^" + "controller-revision-hash" + "$",
        "^" + "sam_.*" + "$",
        "^" + ".*kubernetes.io/.*" + "$",
    ],

    // Namespaces that can ignore the rules
    privilegedNamespaces:: [
        "sam-system"
    ],
}
