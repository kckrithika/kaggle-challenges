{
local estate = std.extVar("estate"),

    perCluster: {

        k8s_subnet: {
            "prd-sam_storage": "10.251.0.0./16",
        },
    },

k8s_subnet: self.perCluster.k8s_subnet[estate],

// Add common config options here.
}
