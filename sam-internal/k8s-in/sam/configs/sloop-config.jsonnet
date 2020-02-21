local resourceRequirements = {
    extra_small: {
        limits: {
            cpu: "1",
            memory: "1.5Gi",
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
            memory: "5Gi",
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
        flags: [
            "--badger-use-lsm-only-options=false",
            // 32<<20 (33554432 bytes = 32 Mb)
            "--badger-max-table-size=33554432",
            "--badger-number-of-compactors=1",
            "--badger-number-of-level-zero-tables=2",
            "--badger-number-of-zero-tables-stall=3",
            "--badger-sync-writes=false",
        ],
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
        "dfw-sam": {
            resource: resourceRequirements.medium,
            containerPort: 31939,
        },
        "frf-sam": {
            resource: resourceRequirements.medium,
            containerPort: 31940,
        },
        "hnd-sam": {
            resource: resourceRequirements.medium,
            containerPort: 31941,
        },
        "iad-sam": {
            resource: resourceRequirements.medium,
            containerPort: 31942,
        },
        "ord-sam": {
            resource: resourceRequirements.large,
            containerPort: 31943,
        },
        "par-sam": {
            resource: resourceRequirements.large,
            containerPort: 31944,
        },
        "phx-sam": {
            resource: resourceRequirements.medium,
            containerPort: 31945,
        },
        "prd-sam": {
            resource: resourceRequirements.large,
            containerPort: 31946,
        },
        "prd-samtest": {
            resource: resourceRequirements.small,
            containerPort: 31947,
        },
        "prd-samtwo": {
            resource: resourceRequirements.small,
            containerPort: 31948,
        },
        "ukb-sam": {
            resource: resourceRequirements.medium,
            containerPort: 31949,
        },
        "xrd-sam": {
            resource: resourceRequirements.medium,
            containerPort: 31950,
        },
    },
}
