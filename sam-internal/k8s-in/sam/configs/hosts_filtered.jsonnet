local hosts = import "hosts.jsonnet";
{
	"hosts": [h for h in hosts.hosts if h.controlestate == std.extVar("estate") && h.kingdom == std.extVar("kingdom")],
}
