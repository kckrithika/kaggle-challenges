local resourceRequirements = {
    extra_small: {
        limits: {
            cpu: "1",
            memory: "1Gi",
        },
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
    small: {
        limits: {
            cpu: "1",
            memory: "8Gi",
        },
        flags: [
            "--badger-use-lsm-only-options=false",
            // 16<<20 (16777216 bytes = 16 Mb)
            "--badger-max-table-size=16777216",
            "--badger-number-of-compactors=1",
            "--badger-number-of-level-zero-tables=1",
            "--badger-number-of-zero-tables-stall=2",
            "--badger-sync-writes=false",
        ],
    },
    medium: {
        limits: {
            cpu: "2",
            memory: "8Gi",
        },
        flags: [],
    },
    large: {
        limits: {
            cpu: "3",
            memory: "15Gi",
        },
        flags: [],
    },
};

{
    # Node Selector for sloop deployment depending on hosting estate.
    sloopNodeSelectors: {
        "prd-samtest": { master: "true" },
        "prd-samtwo": { "node.sam.sfdc.net/role": "samcompute", pool: "prd-samtwo" },
    },

    estateConfigs: {
        "ast-sam": {
            resource: resourceRequirements.extra_small,
            containerPort: 31938,
        },
        "frf-sam": {
            resource: resourceRequirements.medium,
            containerPort: 31939,
        },
        "hnd-sam": {
            resource: resourceRequirements.medium,
            containerPort: 31940,
        },
        "par-sam": {
            resource: resourceRequirements.large,
            containerPort: 31941,
        },
        "prd-sam": {
            resource: resourceRequirements.large,
            containerPort: 31942,
        },
        "prd-samtest": {
            resource: resourceRequirements.small,
            containerPort: 31943,
        },
        "prd-samtwo": {
            resource: resourceRequirements.small,
            containerPort: 31944,
        },
    },
}
