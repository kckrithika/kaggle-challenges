local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
{
    sdn_enabled: !(flowsnakeconfig.is_minikube),
    sdn_pre_deployment_estates: [
        "phx-flowsnake_prod",
    ],
    sdn_during_deployment_estates: [
    ],
    sdn_pre_deployment: std.count(self.sdn_pre_deployment_estates, estate) == 1,
    sdn_during_deployment: std.count(self.sdn_during_deployment_estates, estate) == 1,
}
