local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local madkub = (import "service-mesh/istio-madkub-config.jsonnet") + { templateFilename:: std.thisFile };

local funnelEndpoint = std.split(configs.funnelVIP, ":");

## Istio pilot madkub certificates.
local pilotSans = [
  "istio-pilot",
  "istio-pilot.mesh-control-plane",
  "istio-pilot.mesh-control-plane.svc",
  "istio-pilot.mesh-control-plane.svc.%s" % configs.dnsdomain,
  "istio-pilot.mesh-control-plane.sfdc-role",
];
local pilotServerCertConfig = madkub.serverCertConfig("tls-server-cert", "/server-cert", "istio-pilot", "mesh-control-plane", pilotSans);
local pilotClientCertConfig = madkub.clientCertConfig("tls-client-cert", "/client-cert", "istio-pilot", "mesh-control-plane");
local pilotCertConfigs = [pilotServerCertConfig, pilotClientCertConfig];

## Istio sidecar-injector madkub certificates.
local sidecarInjectorSans = [
  "istio-sidecar-injector",
  "istio-sidecar-injector.mesh-control-plane",
  "istio-sidecar-injector.mesh-control-plane.svc",  // This is the one that works with webhook's clientConfig.service
  "istio-sidecar-injector.mesh-control-plane.svc.%s" % configs.dnsdomain,
];
local sidecarInjectorServerCertConfig = madkub.serverCertConfig("tls-server-cert", "/server-cert", "istio-sidecar-injector", "mesh-control-plane", sidecarInjectorSans);
local sidecarInjectorCertConfigs = [sidecarInjectorServerCertConfig];

## Istio ingressGateway madkub certificates.
local ingressGatewayServerCertSans = [
  "istio-ingressgateway",
  "istio-ingressgateway.core-on-sam-sp2",
  "istio-ingressgateway.core-on-sam-sp2.svc",
  "istio-ingressgateway.core-on-sam-sp2.svc.%s" % configs.dnsdomain,
  "istio-ingressgateway.core-on-sam-sp2.prd-sam.prd.slb.sfdc.net",
  "*.istio-prd.eng.sfdc.net",
  "*.istiotest-prd.eng.sfdc.net",
];
local ingressGatewayServerCertConfig = madkub.serverCertConfig("tls-server-cert", "/server-cert", "istio-ingressgateway", "core-on-sam-sp2", ingressGatewayServerCertSans);
local ingressGatewayClientCertConfig = madkub.clientCertConfig("tls-client-cert", "/client-cert", "istio-ingressgateway", "core-on-sam-sp2");
local ingressGatewayCertConfigs = [ingressGatewayClientCertConfig, ingressGatewayServerCertConfig];

## Istio hub and tag for images
local istioHub = "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/istio-packaging/";
local istioTag = "91747894065947d0217bdae7eab3e0a3dfbaa21e";

{
  ## Images. Represented as `"mcpIstioConfig.<image>"` in template.
  ## Istio image tag needs to be updated in Helm values.
  metricsScraperImage: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/servicemesh/metrics-scraper:e0c2f0082b404ce6a3ecdb1a686731ef3bae5223",
  madkubImage: samimages.madkub,
  permissionInitContainer: samimages.permissionInitContainer,
  proxyImage: istioHub + "proxy:" + istioTag,
  proxyInitImage: istioHub + "proxy_init:" + istioTag,

  ## Istio Config Objects. Represented as `"mcpIstioConfig.<name>"` in template.

  pilotMadkubAnnotations: std.manifestJsonEx(
    {
      certreqs:
        [
          certReq
          for certReq in madkub.madkubSamCertsAnnotation(pilotCertConfigs).certreqs
        ],
    }, " "
  ),

  sidecarInjectorMadkubAnnotations: std.manifestJsonEx(
    {
      certreqs:
        [
          certReq
          for certReq in madkub.madkubSamCertsAnnotation(sidecarInjectorCertConfigs).certreqs
        ],
    }, " "
  ),

  ingressGatewayMadkubAnnotations: std.manifestJsonEx(
    {
      certreqs:
        [
          certReq
          for certReq in madkub.madkubSamCertsAnnotation(ingressGatewayCertConfigs).certreqs
        ],
    }, " "
  ),

  ## Istio Config Strings. Represented as `"%(<name>)s" % mcpIstioConfig` in template.
  istioEstate: (
    if configs.estate == "prd-samtest" then
      configs.estate
    else
      configs.estate + "_gater"
  ),
  casamEstate: (
    if configs.estate == "prd-samtest" then
      configs.estate
    else
      "prd-sp2-sam_coreapp"
  ),
  controlEstate: configs.estate,

  superpod: "-",
  pilotSettingsPath: "istio.-." + configs.kingdom + ".-." + "istio-pilot",
  ingressGatewaySettingsPath: "istio.-." + configs.kingdom + ".-." + "istio-ingressgateway",

  funnelVIP: configs.funnelVIP,
  funnelIstioEndpoint: "ajnafunneldirect.svc.mesh.sfdc.net:8080",

  funnelHost: funnelEndpoint[0],
  funnelPort: funnelEndpoint[1],

  madkubEndpoint: "https://10.254.208.254:32007",  // Check madkubserver-service.jsonnet for why IP
  maddogEndpoint: configs.maddogEndpoint,

  sidecarEgressHosts: [
    // System namespaces
    "mesh-control-plane/*",
    "z9s-default/*",

    // App namespaces
    "app/*",
    "casam/*",
    "ccait/*",
    "core-on-sam-sp2/*",
    "emailinfra/*",
    "funnel/*",
    "gater/*",
    "retail-cre/*",
    "retail-dfs/*",
    "retail-mds/*",
    "retail-rsui/*",
    "scone/*",
    "search-scale-safely/*",
    "service-mesh/*",
    "universal-search/*",
  ],

  istioEnvoyVolumes():: [
    {
      emptyDir: {
        medium: "Memory",
      },
      name: "istio-envoy",
    },
  ],
}
