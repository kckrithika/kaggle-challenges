local flowsnake_config = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");

{
  # add new Spark-on-kubernetes clients to this object.
  clients_per_estate: {
      # None yet!  Soon this object will contain a field per estate containing a list of client
      # spec objects with the following format:
      # {
      #     owner_name: "Owner Team",
      #     namespace: "some_client_namespace",
      #     users: ["clientrole.client_app1", "clientrole.client_app2"],
      #     quota: {
      #         cpu: 1000,
      #         pods: 200,
      #         memory: "20Gi"
      #         [...etc]
      #     }
      # },

  },

  clients: if std.objectHas(self.clients_per_estate, estate) then self.clients_per_estate[estate] else [],

}
