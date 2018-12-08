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
}
