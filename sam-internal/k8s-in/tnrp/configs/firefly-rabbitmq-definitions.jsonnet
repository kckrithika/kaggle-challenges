{
  "vhosts": [
    {
      "name": "/"
    },
  ],
  "policies":[
    {
      "vhost":"/",
      "name":"ha",
      "pattern":"",
      "definition":
      {
        "ha-mode":"exactly",
        "ha-params":3,
        "ha-sync-mode":"automatic"
      }
    }
  ],
}