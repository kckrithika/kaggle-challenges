local firefly_feature_flags = import "sfcd_feature_flags.jsonnet";

{
  service_health_port(portName):: (
      {
         name: 'admin-port',
         protocol: 'TCP',
         port: 8081,
         targetPort: 8081,
      }
  ),
  sfcdapi:
    {
      firebom_http: 8080,
      firebom_https: 8443,
      firebom_mgmt: 8081,
      firebom_http_nodeport: 32080,
      firebom_https_nodeport: 32443,
      firebom_mgmt_nodeport: 32081,
    },
}
