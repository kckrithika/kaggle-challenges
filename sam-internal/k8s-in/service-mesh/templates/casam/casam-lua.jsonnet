{
  apiVersion: "networking.istio.io/v1alpha3",
  kind: "EnvoyFilter",
  metadata: {
    name: "casam-lua-filter",  # currently adding to default namespace.
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
  },
  spec: {
    workloadLabels: {
      istio: "ingressgateway",
    },
    filters: [
    {
      listenerMatch: {
        portNumber: 8085,
        listenerType: "GATEWAY",
        listenerProtocol: "HTTP",
      },
      filterName: "envoy.lua",
       filterType: "HTTP",
       filterConfig: {
        inlineCode: |||
            function envoy_on_request(request_handle)
                -- Log all headers
                for key, value in pairs(request_handle:headers()) do
                    request_handle:logDebug("header key " .. key .. " value " .. value)
                end
                -- Remove ciphersuite header for all incoming requests.
                request_handle:headers():remove("CipherSuite")
                -- Add a dummy CipherSuite header if the downstream connection uses ssl.
                if request_handle:connection():ssl() ~= nil then
                    request_handle:logDebug("adding dummy cipher suite")
                    request_handle:headers():add("CipherSuite", "https")
                end
            end
        |||,
        },
    },
    ],
  },
}
