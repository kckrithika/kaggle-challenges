{
  firefly:
    {
      rabbitmq_https: 15671,
      rabbitmq_http: 15672,
      rabbitmq_amqps: 5672,
      rabbitmq_amqp: 5671,
      rabbitmq_https_nodeport: 32671,
      rabbitmq_http_nodeport: 32672,
      rabbitmq_amqps_nodeport: 33671,
      rabbitmq_amqp_nodeport: 33672,

      intake_http: 8080,
      intake_https: 8443,
      intake_mgmt: 8081,
      intake_http_nodeport: 32080,
      intake_https_nodeport: 32443,
      intake_mgmt_nodeport: 32081,

      pullrequest_mgmt: 8081,
      pullrequest_mgmt_nodeport: 32083,

      package_mgmt: 8081,
      package_mgmt_nodeport: 32085,

      crawler_mgmt: 8081,
      crawler_mgmt_nodeport: 32082,

      promotion_mgmt: 8081,
      promotion_mgmt_nodeport: 32084,
    },
}
