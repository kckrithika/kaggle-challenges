{
    # This helps to avoid same port usage by services with other services running in the same cluster.
    # Lists out port usages for each service (e.g. sam, sdn, slb etc...)

    # Here is the syntax to the format to be used:
    # "<teamname>": {
    #     serviceA: "portA",
    #     serviceB: "portB"
    # },

    "sam": {
        sam_secret_agent: "9098",
    },

    "sdn": {
        sdn_peering_agent: "9100",
        sdn_ping_watchdog: "9102",
        sdn_route_watchdog: "9104",
        sdn_vault_agent: "9106",
    },
}
