{
  lbname: $.lbName,
  "function": $.functionName,
  nodeExposed: true,
  slbEnabled: false,
  ports: [
    {
      port: 8998,
      targetport: 8998,
    },
    {
      port: 8085,
      targetport: 8085,
    },
    {
      port: 13065,
      targetport: 13065,
    },
    {
      port: 15373,
      targetport: 15373,
    },
  ],
}
