local configs = import "config.jsonnet";
local portconfigs = import "portconfig.jsonnet";
local firefly_feature_flags = import "firefly_feature_flags.jsonnet";

if firefly_feature_flags.is_rabbitmq_enabled then {
  kind: 'Service',
  apiVersion: 'v1',
  metadata: {
    name: 'rabbitmq-svc',
    namespace: 'firefly',
    labels: {
      app: 'firefly-rabbitmq',
      type: 'LoadBalancer',
    } + configs.ownerLabel.tnrp,
    annotations: if firefly_feature_flags.is_slb_enabled then {
        "slb.sfdc.net/name": "firefly-rabbitmq",
        "slb.sfdc.net/portconfigurations": std.toString(
         [
           {
             port: portconfigs.firefly.rabbitmq_http,
             targetport: $.spec.ports[0].targetPort,
             lbtype: "http",
             tls: false,
             reencrypt: false,
             sticky: 0,
           },
           {
             port: portconfigs.firefly.rabbitmq_https,
             targetport: $.spec.ports[1].targetPort,
             lbtype: "http",
             tls: true,
             reencrypt: false,
             sticky: 0,
           },
           {
             port: portconfigs.firefly.rabbitmq_amqp,
             targetport: $.spec.ports[2].targetPort,
             lbtype: "tcp",
             sticky: 0,
           },
           {
             port: portconfigs.firefly.rabbitmq_amqps,
             targetport: $.spec.ports[3].targetPort,
             lbtype: "tcp",
             sticky: 0,
           },
         ]
       ),
    },
  },
  spec: {
    type: if firefly_feature_flags.is_slb_enabled then 'NodePort' else 'LoadBalancer',
    ports: [
      {
        name: 'http',
        protocol: 'TCP',
        port: portconfigs.firefly.rabbitmq_http,
        targetPort: portconfigs.firefly.rabbitmq_http,
        nodePort: if !firefly_feature_flags.is_slb_enabled then portconfigs.firefly.rabbitmq_http_nodeport,
      },
      {
        name: 'https',
        protocol: 'TCP',
        port: portconfigs.firefly.rabbitmq_https,
        targetPort: portconfigs.firefly.rabbitmq_http,
        nodePort: if !firefly_feature_flags.is_slb_enabled then portconfigs.firefly.rabbitmq_https_nodeport,
      },
      {
        name: 'amqp',
        protocol: 'TCP',
        port: portconfigs.firefly.rabbitmq_amqp,
        targetPort: portconfigs.firefly.rabbitmq_amqp,
        nodePort: if !firefly_feature_flags.is_slb_enabled then portconfigs.firefly.rabbitmq_amqp_nodeport,
      },
      {
        name: 'amqp-tls',
        protocol: 'TCP',
        port: portconfigs.firefly.rabbitmq_amqps,
        targetPort: portconfigs.firefly.rabbitmq_amqps,
        nodePort: if !firefly_feature_flags.is_slb_enabled then portconfigs.firefly.rabbitmq_amqps_nodeport,
      },
    ],
    selector: {
      app: 'rabbitmq',
    },
  },
} else "SKIP"
