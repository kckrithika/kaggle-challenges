local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local madkub = (import "service-mesh/istio-madkub-config.jsonnet") + { templateFilename:: std.thisFile };
local istioPhases = import "service-mesh/istio-phases.jsonnet";
local istioReleases = import "service-mesh/istio-releases.json";

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
local sidecarInjectorClientCertConfig = madkub.clientCertConfig("tls-client-cert", "/client-cert", "istio-sidecar-injector", "mesh-control-plane");
// TODO: We will need to remove the considion here before releasing to PAR!
local sidecarInjectorCertConfigs = [sidecarInjectorServerCertConfig] + if configs.kingdom == "prd" then [sidecarInjectorClientCertConfig] else [];

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

{
  ## Images. Represented as `"mcpIstioConfig.<image>"` in template.

  # Istio hub and tag is used in Helm values. Represented as "%(istioHub)s" and "%(istioTag)s" respectively.
  istioHub: if std.objectHas(istioReleases[istioPhases.phase], 'istioHub') then istioReleases[istioPhases.phase].istioHub else configs.registry + "/sfci/servicemesh/istio-packaging",
  istioTag: istioReleases[istioPhases.phase].istioTag,

  serviceMeshHub: configs.registry + "/sfci/servicemesh/servicemesh",
  serviceMeshTag: istioReleases[istioPhases.phase].serviceMeshTag,

  routingWebhookImage: $.serviceMeshHub + "/istio-routing-webhook:" + $.serviceMeshTag,
  routeUpdateSvcImage: $.serviceMeshHub + "/route-update-service:" + $.serviceMeshTag,
  metricsScraperImage: $.serviceMeshHub + "/metrics-scraper:" + $.serviceMeshTag,

  madkubImage: samimages.madkub,
  permissionInitContainer: samimages.permissionInitContainer,
  proxyImage: $.istioHub + "/proxy:" + $.istioTag,
  proxyInitImage: $.istioHub + "/proxy_init:" + $.istioTag,

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
  kingdom: configs.kingdom,
  superpod: "-",
  pilotSettingsPath: "istio.-." + configs.kingdom + ".-." + "istio-pilot",
  ingressGatewaySettingsPath: "istio.-." + configs.kingdom + ".-." + "istio-ingressgateway",

  funnelEndpoint: istioPhases.funnelEndpoint,
  funnelVIP: configs.funnelVIP,

  madkubEndpoint: "https://10.254.208.254:32007",  // Check madkubserver-service.jsonnet for why IP
  maddogEndpoint: configs.maddogEndpoint,

  accessLogFile: if configs.kingdom == "prd" then "/dev/stdout" else "",

  sidecarEgressHosts: istioPhases.sidecarEgressHosts,

  istioEnvoyVolumes():: [
    {
      emptyDir: {
        medium: "Memory",
      },
      name: "istio-envoy",
    },
  ],
}
