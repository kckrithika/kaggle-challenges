local configs = import "config.jsonnet";
local samimages = (import "sam/samimages.jsonnet") + { templateFilename:: std.thisFile };
local istioImages = (import "service-mesh/istio-images.jsonnet") + { templateFilename:: std.thisFile };
local madkub = (import "service-mesh/istio-madkub-config.jsonnet") + { templateFilename:: std.thisFile };

local funnelEndpoint = std.split(configs.funnelVIP, ":");

## Istio sidecar-injector madkub certificates.
local sidecarInjectorSans = [
  "istio-sidecar-injector",
  "istio-sidecar-injector.mesh-control-plane",
  "istio-sidecar-injector.mesh-control-plane.svc",  // This is the one that works with webhook's clientConfig.service
  "istio-sidecar-injector.mesh-control-plane.svc.%s" % configs.dnsdomain,
];
// TODO change cert1 to server-cert
local sidecarInjectorServerCertConfig = madkub.serverCertConfig("cert1", "/cert1", "istio-sidecar-injector", "mesh-control-plane", sidecarInjectorSans);
local sidecarInjectorCertConfigs = [sidecarInjectorServerCertConfig];

## Istio ingressGateway madkub certificates.
local ingressGatewayServerCertSans = [
  "istio-ingressgateway",
  "istio-ingressgateway.mesh-control-plane",
  "istio-ingressgateway.mesh-control-plane.svc",
  "istio-ingressgateway.mesh-control-plane.svc.%s" % configs.dnsdomain,
];
local ingressGatewayServerCertConfig = madkub.serverCertConfig("tls-server-cert", "/server-cert", "istio-ingressgateway", "mesh-control-plane", ingressGatewayServerCertSans);
local ingressGatewayClientCertConfig = madkub.clientCertConfig("tls-client-cert", "/client-cert", "istio-ingressgateway", "mesh-control-plane");
local ingressGatewayCertConfigs = [ingressGatewayClientCertConfig, ingressGatewayServerCertConfig];

{
  ## Istio Images. Represented as `"mcpIstioConfig.<image>"` in template.
  // TODO rename images to camel case.
  pilotImage: istioImages.pilot,
  proxyImage: istioImages.proxy,
  proxyInitImage: istioImages.proxyinit,
  sidecarInjectorImage: istioImages.sidecarinjector,
  metricsScraperImage: istioImages.metricsscraper,
  madkubImage: samimages.madkub,

  ### Istio Config Objects. Represented as `"mcpIstioConfig.<name>"` in template.
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

  ### Istio Config Strings. Represented as `"%(<name>)s" % mcpIstioConfig` in template.
  istioEstate: (
    if configs.estate == "prd-samtest" then
      configs.estate
    else
      configs.estate + "_gater"
  ),

  superpod: "-",
  settingsPath: "-.-." + configs.kingdom + ".-." + "istio-pilot",

  funnelHost: funnelEndpoint[0],
  funnelPort: funnelEndpoint[1],

  madkubEndpoint: "https://10.254.208.254:32007",  // Check madkubserver-service.jsonnet for why IP
  maddogEndpoint: configs.maddogEndpoint,

}
