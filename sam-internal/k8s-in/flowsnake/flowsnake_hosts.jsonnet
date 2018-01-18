local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local hosts = import "sam/configs/hosts.jsonnet";
{
        hosts: [h for h in hosts.hosts if h.controlestate == std.extVar("estate") && h.kingdom == std.extVar("kingdom")],
}
