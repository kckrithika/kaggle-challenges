{
  lbname: $.lbName,
  "function": $.functionName,
  nodeExposed: false,
  slbEnabled: true,
  ports: [
    {
      port: 2525,
      targetport: 2525,
    },
    {
      port: 8086,
      targetport: 12060,
    },
    {
      port: 8443,
      targetport: 12060,
    },
    {
      port: 8087,
      targetport: 15373,
    },
    {
      port: 8888,
      targetport: 12060,
    },
  ],
}
