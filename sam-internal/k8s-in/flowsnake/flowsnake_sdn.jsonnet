local estate = std.extVar("estate");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
{
    sdn_enabled: !(flowsnakeconfig.is_minikube),

    // Map of in-deployment estate names to the phase of deployment they're currently in.
    // The resources deployed for each phase (and its subsequent phases) are defined below.
    // The estate not being in this map at all means that it is fully bootstrapped and running Flowsnake.
    // Note: keys in this map are estate name only, not kingdom/estate.
    sdn_estate_phases: flowsnakeconfig.validate_estate_fields({
        "ia2-flowsnake_prod": 5,
    }),

    sdn_deployment_phases: [
        # 0 Autodeployer only
        [
            "samcontrol-deployer-configmap.yaml",
            "samcontrol-deployer.yaml",
        ],
        # 1 SDN Secret Vault Agent
        [
            "__flowsnake-ns.yaml",
            "_sfdchosts-configmap-sam.yaml",
            "_sfdchosts-configmap.yaml",
            "sdn-vault-agent.yaml",
        ],
        # 2 Secret Agent
        [
            "sdn-secret-agent.yaml",
        ],
        # 3 Cleanup
        [
            "sdn-cleanup.yaml",
        ],
        # 4 Various daemonsets
        [
            "sdn-hairpin-setter.yaml",
            "sdn-peering-agent.yaml",
            "sdn-bird.yaml",
        ],
        # 5 SDN Watchdogs
        [
            "sdn-ping-watchdog.yaml",
            "sdn-route-watchdog.yaml",
        ],

    ],

    bootstrap_resources: (
        if std.objectHas(self.sdn_estate_phases, estate)
        then
            std.flattenArrays([self.sdn_deployment_phases[p] for p in std.range(0, self.sdn_estate_phases[estate])])
        else
            []
    ),

}
