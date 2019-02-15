// This file declares the following VIP watchdog configurations:
// 1. VIPs that are currently omitted from monitoring by VIP watchdog.
//
// Ideally, this list would be empty; however, bugs in our monitoring necessitate a way for us to temporarily exclude
// one or more VIPs from monitoring until the bug can be fixed.
//
// This is a rather large hammer -- VIPs filtered from monitoring do not receive any SLA guarantees, and VIP metrics
// (availability, backend health, etc), are not emitted to Argus. Use with caution. Bias for fixing the monitoring
// bug rather than adding to this list. When adding to this list, include a detailed comment (or link to a work item)
// indicating why the VIP is being filtered and when the filter can be expected to be removed.
//
// 2. Very Important VIPs (VIVIPs) that should receive 24/7 monitoring and alerting.
//
// We would like to reduce our operational burden by constraining the list of VIPs that receive 24/7 monitoring and
// page the oncall after hours. These VIPs are usually heavily used, optionally public facing VIPs that are fronting
// by production systems (eg. Artifactory, Edge etc). VIVIPs will be tagged by vip-wd as `veryImportantVip=true`
// and a special 24/7 alert can be created only for these VIPs.
//
// The structure of the JSON object is like:
// {
//    <controlEstate>: // The name of the k8s control estate hosting the VIP.
//    {
//      serviceLists:  // Optional. If included, specifies one or more service lists to exclude from monitoring.
//      [
//        ...
//      ],
//      namespaces:    // Optional. If included, specifies one or more namespaces to exclude from monitoring.
//      [
//        ...
//      ],
//      vivips:        // Optional. If included, specifies one or more VIPs that should be tagged as Very Important.
//      [
//        ...
//      ],
//    },
// },
//
// A "service list" is an internal SLB concept. It has a mapping for both k8s services and self-service vips.
// * For VIPs bound to a raw k8s service, the "service list" name is the name of the k8s service declaring the VIP.
// * For SAM apps, the "service list" name corresponds to the "lbname" field in the SAM manifest.
// * For self-service VIPs, the "service list" name is the "customlbname" field (if specified), otherwise it is formed
//   from:
//   - the "lbname" field in the VIP declaration,
//   - the team / user name from the folder containing the vips.yaml,
//   - the kingdom name:
//   <lbname>-<team/username>-<kingdom>
//
// Similarly, the "namespace" used here depends on whether the VIP is bound to a k8s service or self-service:
// * For VIPs bound to a k8s service, the namespace is the containing namespace for the service resource.
// * For SAM apps, the namespace is the team / user name.
// * For self-service VIPs, the namespace is always "kne".

// For VIVIPS, the format can be either:
// * FQDN:port (eg. ops0-dvaregistryssl1-0-prd.slb.sfdc.net:443)
// * VIP:port  (eg. 13.110.24.14:80)

local slbimages = import "slbimages.jsonnet";

local vipwdConfig = {
  "prd-sdc":
  {
    // Some canary vivips for testing
    vivips:
    [
      "slb-canary-proxy-http.sam-system.prd-sdc.prd.slb.sfdc.net:*",
    ],
  },
  "prd-sam":
  {
    serviceLists:
    [
      // 2018/12/19 - mgrass: These VIPs were added to the exclusion list with https://git.soma.salesforce.com/sam/manifests/pull/12121.
      // The rationale was:
      //    Note that 2 new DSR VIPs have been added to the vip-wd optOut list. This is because those customers have yet to set up the
      //    puppet module that will make the VIP work end to end.
      // It appears that as of today this is still the case.
      // TODO: follow up with @vyjayanthi-raja and customer to figure out next steps for these VIPs.
      "pra-sfc-prd",
      "pra-dsm-prd",
      // 2019/01/02 - mgrass: This VIP is using a rather interesting construct -- it's a VIP that points to a backend that is . . . a VIP:
      //  https://git.soma.salesforce.com/sam/manifests/blob/befcf4a6d97a0a4cb8904293aed5f9f78c571cb9/apps/user/vijay-kota/vips/vips.yaml#L3
      //  Vijay's reasoning for doing this:
      //    This is not a real scenario :slightly_smiling_face: I have defined a HTTP VIP with tls:true to enforce HTTPS. But I want to use
      //    the browser and just send HTTP requests. So I defined another VIP with tls:false and reencrypt:true to force an HTTPS request to
      //    the actual VIP. I will be removing the vips.yaml under apps/user after my debugging is over.
      //
      //  TODO: follow up with Vijay to see if this VIP is still needed. Now that https VIPs don't demand a client certificate, it shouldn't be
      //        necessary.
      "us99-sfproxytest-vip-vijay-kota-prd",
      // 2019/01/02 - mgrass: This VIP has a single backend, and that backend is sending unreliable health signals. See
      // https://computecloud.slack.com/archives/G340CE86R/p1545408207001700?thread_ts=1545402611.001100&cid=G340CE86R. This should be removed
      // when the underlying issues discussed in https://gus.lightning.force.com/a07B0000004j96jIAA are resolved.
      "us98-mist61sfproxy-lb",
      // 2019/01/02 - mgrass: Issues with our monitoring cause some of the steam VIPs to be incorrectly marked as SLA eligible even with flappy
      // backends.
      // TODO: it's possible that the steam VIPs are no longer symptomatic, and these exclusions can be removed. If after removing, we still get
      //       VIP availability alerts, one or more of these should help resolve:
      //       * remove these steam VIP definitions (as I don't think anybody is depending on them), or
      //       * investigate whether addressing https://gus.lightning.force.com/a07B0000004j96jIAA resolves, or
      //       * explore options to reload nginx config less frequently, possibly modeling after the k8s nginx ingress controller's use of lua
      //         (https://github.com/kubernetes/ingress-nginx/blob/master/docs/how-it-works.md#avoiding-reloads-on-endpoints-changes), or
      //       * switch to envoy, which doesn't require reloads to deal with dynamic endpoint changes :)
      // List generated with:
      //         grep -- '- lbname' apps/team/steam/vips/prd/vips.yaml | awk '{printf "\""$3"-steam-prd\",\n"}' | sort
      // Followed by manually fixing up the 8 VIPs that have a customlbname.
      "cs1-stmfa1-0-prd-steam-prd",
      "cs1-stmfb1-0-prd-steam-prd",
      "cs2-stmfa1-0-prd-steam-prd",
      "cs2-stmfb1-0-prd-steam-prd",
      "cs2-stmfc1-0-prd-steam-prd",
      "cs2-stmsa1-0-prd-steam-prd",
      "cs2-stmua1-0-prd-steam-prd",
      "cs2-stmub1-0-prd-steam-prd",
      "cs3-stmfa1-0-prd-steam-prd",
      "cs3-stmfb1-0-prd-steam-prd",
      "cs3-stmfc1-0-prd-steam-prd",
      "cs3-stmua1-0-prd-steam-prd",
      "cs3-stmub1-0-prd-steam-prd",
      "cs4-stmda1-0-prd-steam-prd",
      "eu1-stmda1-0-prd",
      "eu1-stmda1-0-prd-steam-prd",
      "eu2-stmda1-0-prd-steam-prd",
      "la2-stmda1-0-prd",
      "la2-stmda1-0-prd-steam-prd",
      "la2-stmfa1-0-prd-steam-prd",
      "la2-stmfb1-0-prd-steam-prd",
      "la2-stmfc1-0-prd-steam-prd",
      "la2-stmfd1-0-prd-steam-prd",
      "la2-stmra1-0-prd-steam-prd",
      "la2-stmsa1-0-prd-steam-prd",
      "la2-stmua1-0-prd-steam-prd",
      "la2-stmub1-0-prd-steam-prd",
      "login-stmda1-0-prd-steam-prd",
      "login-stmda-stm",
      "login-stmfa1-0-prd-steam-prd",
      "login-stmfb1-0-prd-steam-prd",
      "login-stmfc1-0-prd-steam-prd",
      "login-stmfd1-0-prd-steam-prd",
      "login-stmra1-0-prd-steam-prd",
      "login-stmsa1-0-prd-steam-prd",
      "login-stmua1-0-prd-steam-prd",
      "login-stmub1-0-prd-steam-prd",
      "na20-stmra1-0-prd-steam-prd",
      "na21-stmra1-0-prd-steam-prd",
      "na22-stmra1-0-prd-steam-prd",
      "na23-stmra1-0-prd-steam-prd",
      "na24-stmra1-0-prd-steam-prd",
      "na25-stmra1-0-prd-steam-prd",
      "na26-stmra1-0-prd-steam-prd",
      "na40-stmfa1-0-prd-steam-prd",
      "na40-stmfb1-0-prd-steam-prd",
      "na41-stmfa1-0-prd-steam-prd",
      "na41-stmfb1-0-prd-steam-prd",
      "na41-stmfc1-0-prd-steam-prd",
      "na41-stmua1-0-prd-steam-prd",
      "na41-stmub1-0-prd-steam-prd",
      "na42-stmfa1-0-prd-steam-prd",
      "na42-stmfb1-0-prd-steam-prd",
      "na42-stmfc1-0-prd-steam-prd",
      "na42-stmua1-0-prd-steam-prd",
      "na42-stmub1-0-prd-steam-prd",
      "na43-stmfa1-0-prd-steam-prd",
      "na43-stmfb1-0-prd-steam-prd",
      "na43-stmfc1-0-prd-steam-prd",
      "na44-sitestmfc1-0-prd-steam-prd",
      "na44-sitestmfd1-0-prd-steam-prd",
      "na44-stmfa1-0-prd-steam-prd",
      "na44-stmfb1-0-prd-steam-prd",
      "na44-stmfc1-0-prd-steam-prd",
      "na44-stmfd1-0-prd-steam-prd",
      "na44-stmsa1-0-prd-steam-prd",
      "na44-stmua1-0-prd-steam-prd",
      "na44-stmub1-0-prd-steam-prd",
      "na45-stmfa1-0-prd-steam-prd",
      "na45-stmfb1-0-prd-steam-prd",
      "na45-stmfc1-0-prd-steam-prd",
      "na45-stmua1-0-prd-steam-prd",
      "na45-stmub1-0-prd-steam-prd",
      "na46-stmfb1-0-prd-steam-prd",
      "na46-stmfc1-0-prd-steam-prd",
      "na47-stmfa1-0-prd-steam-prd",
      "na6-stmsa1-0-prd-steam-prd",
      "na7-stmsa1-0-prd-steam-prd",
      "na8-stmsa1-0-prd-steam-prd",
      "na9-stmsa1-0-prd-steam-prd",
      "stmda1hbase2a-hbasemon1-0-prd",
      "stmdaeu1-cmp1-0-prd",
      "stmdaeu2-cmp1-0-prd",
      "stmda-insights2-redis1-0-prd",
      "stmdashared2-pbsmatch1-0-prd",
      "stmdashared2-pbsmatch1-0-prd-steam-prd",
      "stm-edge1-0-prd-steam-prd",
      "stmfashared2-pbsmatch1-0-prd-steam-prd",
      "stmfbshared2-pbsmatch1-0-prd-steam-prd",
      "stmfcshared2-pbsmatch1-0-prd-steam-prd",
      "stmfdshared2-pbsmatch1-0-prd-steam-prd",
      "stmrashared2-pbsmatch1-0-prd-steam-prd",
      "stmsashared2-pbsmatch1-0-prd-steam-prd",
      "stmshared2-pbsgeo2-0-prd-steam-prd",
      "stmuashared2-pbsmatch1-0-prd-steam-prd",
      "stmubshared2-pbsmatch1-0-prd-steam-prd",
      "test-stmda1-0-prd-steam-prd",
      "test-stmfa1-0-prd-steam-prd",
      "test-stmfb1-0-prd-steam-prd",
      "test-stmfc1-0-prd-steam-prd",
      "test-stmsa1-0-prd-steam-prd",
      "test-stmua1-0-prd-steam-prd",
      "test-stmub1-0-prd-steam-prd",
    ],
    namespaces: [
      // 2019/01/31 - mgrass: Long-time flaky VIP in user namespace. Opting out to address more pressing matters.
      // Investigation here: https://computecloud.slack.com/archives/G340CE86R/p1548979993685500?thread_ts=1548979508.678000&cid=G340CE86R.
      "user-varun-vyas",
    ],
    vivips: [
       // There are 3 sledge VIPs that listen on these ports:
       // sledge-stm-edge-prd.slb.sfdc.net
       // sledge-mist51-ead-lb-edge-prd.slb.sfdc.net
       // sledge-mist51-prd.slb.sfdc.net
       // sledge-stm-ead-lb-edge-prd.slb.sfdc.net
       "sledge-*.slb.sfdc.net:*",
       // Artifactory VIPs and their dvaregistry counterparts
       "ops0-artifactrepo2-0-prd.slb.sfdc.net:443",
       "ops0-artifactrepo1-0-prd.slb.sfdc.net:443",
       "ops0-dvaregistryssl1-0-prd.slb.sfdc.net:443",
       "ops0-dvaregistry1-0-prd.slb.sfdc.net:*",
       // Customer360 VIPs
       "jtuley-rsui-lb.user-jtuley.prd-sam.prd.slb.sfdc.net:*",
       "rsui-func-lb.retail-rsui.prd-sam.prd.slb.sfdc.net:*",
       "rsui-perf-lb.retail-rsui.prd-sam.prd.slb.sfdc.net:8080",
       "rsui-integ-lb.retail-rsui.prd-sam.prd.slb.sfdc.net:*",
       // Flowsnake VIPs
       "kubernetes-api-flowsnake-prd.slb.sfdc.net:443",
       "ingress-flowsnake-prd.slb.sfdc.net:443",
    ],
  },
  "xrd-sam":
  {
    serviceLists:
    [
      // 2018/12/27 - mgrass: A known issue in our monitoring is causing these RDI VIPs in XRD to generate false alarms.
      // These should be removed when the underlying issues discussed in https://gus.lightning.force.com/a07B0000004j96jIAA
      // are resolved.
      "vir511-1-0-xrd",
      "vir512-1-0-xrd",
      // 2019/01/02 - mgrass: This self-serve DSR VIP doesn't have the associated puppet changes to allow it to work.
      // We need to either delete the definition (https://git.soma.salesforce.com/sam/manifests/blob/master/apps/team/cpt/vips/xrd/vips.yaml#L17)
      // or work with the customer to enable our realsvrcfg puppet module on their nodes.
      "cpt-dsr-validation-cpt-xrd",
    ],
    vivips:
    [
      // Artifactory VIPs
      "ops0-artifactrepo1-0-xrd.slb.sfdc.net:443",
      "ops0-artifactrepo2-0-xrd.slb.sfdc.net:443",
      // Edge VIPs
      "sledge-*.slb.sfdc.net:80",
      "sledge-*.slb.sfdc.net:443",
      "sledge-*.slb.sfdc.net:8443",
    ],
  },
  "hnd-sam":
  {
    serviceLists:
    [
      // 2019/01/28 - vyjayanthi.raja
      // Associated investigation: https://computecloud.slack.com/archives/G340CE86R/p1548731408150000
      // 2019/01/31 - pablo - re-enabled at customer request for an investigation
      // "pra-neutron-hnd",
      // "pra-mariadb-hnd",
      // "pra-keystone-apache-hnd",
      // "pra-ccn-1-0-hnd",
      // "pra-keystone-admin-hnd",
      // "pra-glance-api-hnd",
      // "pra-nova-hnd",
    ],
    vivips:
    [
      // Artifactory VIPs
      "ops0-artifactrepo1-0-hnd.slb.sfdc.net:443",
      // Edge VIPs
      "sledge-*.slb.sfdc.net:*",
      // Flowsnake VIPs
      "kubernetes-api-flowsnake-hnd.slb.sfdc.net:443",
      "ingress-flowsnake-hnd.slb.sfdc.net:443",
    ],
  },
  "phx-sam":
  {
    serviceLists:
    [
      // 2019/02/13 - vyjayanthi.raja
      // Associated investigation: https://computecloud.slack.com/archives/G340CE86R/p1550093301234000?thread_ts=1550091904.233300&cid=G340CE86R
      "spaasmeshlb",
    ],
    vivips:
    [
      // Artifactory VIPs
      "ops0-artifactrepo1-0-phx.slb.sfdc.net:443",
      // Edge VIPs
      "sledge-*.slb.sfdc.net:*",
      // Flowsnake VIPs
      "kubernetes-api-flowsnake-phx.slb.sfdc.net:443",
      "ingress-flowsnake-phx.slb.sfdc.net:443",
    ],
  },
  "cdg-sam":
  {
    vivips:
    [
      // Artifactory VIPs
      "ops0-artifactrepo1-0-cdg.slb.sfdc.net:443",
    ],
  },
  "dfw-sam":
  {
    vivips:
    [
      // Artifactory VIPs
      "ops0-artifactrepo1-0-dfw.slb.sfdc.net:443",
      // Edge VIPs
      "sledge-*.slb.sfdc.net:*",
      // Flowsnake VIPs
      "kubernetes-api-flowsnake-dfw.slb.sfdc.net:443",
      "ingress-flowsnake-dfw.slb.sfdc.net:443",
    ],
  },
  "fra-sam":
  {
    vivips:
    [
      // Artifactory VIPs
      "ops0-artifactrepo1-0-fra.slb.sfdc.net:443",
      // Edge VIPs
      "sledge-*.slb.sfdc.net:*",
    ],
  },
  "frf-sam":
  {
    vivips:
    [
      // Artifactory VIPs
      "ops0-artifactrepo1-0-frf.slb.sfdc.net:443",
      // Edge VIPs
      "sledge-*.slb.sfdc.net:*",
      // Flowsnake VIPs
      "kubernetes-api-flowsnake-frf.slb.sfdc.net:443",
      "ingress-flowsnake-frf.slb.sfdc.net:443",
    ],
  },
  "ia2-sam":
  {
    vivips:
    [
      // Artifactory VIPs
      "ops0-artifactrepo1-0-ia2.slb.sfdc.net:443",
      // Flowsnake VIPs
      "kubernetes-api-flowsnake-ia2.slb.sfdc.net:443",
      "ingress-flowsnake-ia2.slb.sfdc.net:443",
    ],
  },
  "iad-sam":
  {
    vivips:
    [
      // Artifactory VIPs
      "ops0-artifactrepo1-0-iad.slb.sfdc.net:443",
      // Edge VIPs
      "sledge-*.slb.sfdc.net:*",
      // Flowsnake VIPs
      "kubernetes-api-flowsnake-iad.slb.sfdc.net:443",
      "ingress-flowsnake-iad.slb.sfdc.net:443",
      // Customer360 VIPs
      "rsui-production-iad-lb.retail-rsui.iad-sam.iad.slb.sfdc.net:443",
      "rsui-production-iad-test-lb.retail-rsui.iad-sam.iad.slb.sfdc.net:443",
    ],
  },
  "ord-sam":
  {
    vivips:
    [
      // Artifactory VIPs
      "ops0-artifactrepo1-0-ord.slb.sfdc.net:443",
      // Edge VIPs
      "sledge-*.slb.sfdc.net:*",
      // Flowsnake VIPs
      "kubernetes-api-flowsnake-ord.slb.sfdc.net:443",
      "ingress-flowsnake-ord.slb.sfdc.net:443",
      // Customer360 VIPs
      "rsui-production-ord-lb.retail-rsui.ord-sam.iad.slb.sfdc.net:443",
      "rsui-production-ord-test-lb.retail-rsui.ord-sam.iad.slb.sfdc.net:443",
    ],
  },
  "par-sam":
  {
    vivips:
    [
      // Artifactory VIPs
      "ops0-artifactrepo1-0-par.slb.sfdc.net:443",
      // Edge VIPs
      "sledge-*.slb.sfdc.net:*",
      // Flowsnake VIPs
      "kubernetes-api-flowsnake-par.slb.sfdc.net:443",
      "ingress-flowsnake-par.slb.sfdc.net:443",
    ],
  },
  "ph2-sam":
  {
    vivips:
    [
      // Artifactory VIPs
      "ops0-artifactrepo1-0-ph2.slb.sfdc.net:443",
      // Flowsnake VIPs
      "kubernetes-api-flowsnake-ph2.slb.sfdc.net:443",
      "ingress-flowsnake-ph2.slb.sfdc.net:443",
    ],
  },
  "ukb-sam":
  {
    vivips:
    [
      // Artifactory VIPs
      "ops0-artifactrepo1-0-ukb.slb.sfdc.net:443",
      // Edge VIPs
      "sledge-*.slb.sfdc.net:*",
      // Flowsnake VIPs
      "kubernetes-api-flowsnake-ukb.slb.sfdc.net:443",
      "ingress-flowsnake-ukb.slb.sfdc.net:443",
    ],
  },
};

local getOptOutServiceListParameter(estateConfig) =
  if std.objectHas(estateConfig, "serviceLists") then [
    "--optOutServiceList=" + std.join(",", estateConfig.serviceLists),
  ] else [];

local getOptOutNamespaceParameter(estateConfig) =
  if std.objectHas(estateConfig, "namespaces") then [
    "--optOutNamespace=" + std.join(",", estateConfig.namespaces),
  ] else [];

local getVivipsParameter(estateConfig) =
  if std.objectHas(estateConfig, "vivips") then [
    "--veryImportantVips=" + std.join(",", estateConfig.vivips),
  ] else [];

{
  // getVipWdOptOutOptions builds the command line parameters to supply to VIP watchdog. `estate` is the name of the control
  // estate (e.g., "prd-sam") to retrieve opt-out options for.
  getVipWdConfigOptions(estate):: (
    if !std.objectHas(vipwdConfig, estate) then []
    else getOptOutServiceListParameter(vipwdConfig[estate]) + getOptOutNamespaceParameter(vipwdConfig[estate])
         + (if slbimages.phaseNum <= 2 then getVivipsParameter(vipwdConfig[estate]) else [])
  ),
}
