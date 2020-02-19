local resourceRequirements = {
    extra_small: {
        cpu: "1",
        memory: "1Gi",
    },
    small: {
        cpu: "1",
        memory: "8Gi",
    },
    medium: {
        cpu: "2",
        memory: "8Gi",
    },
    large: {
        cpu: "3",
        memory: "15Gi",
    },
};

{
    # Node Selector for sloop deployment depending on hosting estate.
    sloopNodeSelectors: {
        "prd-samtest": { master: "true" },
        "prd-samtwo": { "node.sam.sfdc.net/role": "samcompute", pool: "prd-samtwo" },
    },

    estateConfigs: {
        "prd-samtest": {
            limits: resourceRequirements.small,
            containerPort: 31938,
            hostPort: 80,
            flags: [],
        },
        "prd-samtwo": {
            limits: resourceRequirements.small,
            containerPort: 31939,
            hostPort: 81,
            flags: [],
        },
        "hnd-sam": {
            limits: resourceRequirements.medium,
            containerPort: 31940,
            hostPort: 82,
            flags: [],
        },
        "frf-sam": {
            limits: resourceRequirements.medium,
            containerPort: 31941,
            hostPort: 83,
            flags: [],
        },
        "par-sam": {
            limits: resourceRequirements.large,
            containerPort: 31942,
            hostPort: 84,
            flags: [],
        },
        "prd-sam": {
            limits: resourceRequirements.large,
            containerPort: 31943,
            hostPort: 85,
            flags: [],
        },
        "ast-sam": {
            limits: resourceRequirements.extra_small,
            containerPort: 31944,
            hostPort: 86,
            flags: [
                "--badger-use-lsm-only-options=false",
                // 1<<20 (1048576 bytes = 1 Mb)
                "--badger-max-table-size=1048576",
                "--badger-number-of-compactors=1",
                "--badger-number-of-level-zero-tables=1",
                "--badger-number-of-zero-tables-stall=2",
                "--badger-sync-writes=false",
            ],
        },
    },
}
