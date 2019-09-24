// This file declares the following VIP watchdog configurations:
// 1. Very Important VIPs (VIVIPs) that should receive 24/7 monitoring and alerting.
//
// We would like to reduce our operational burden by constraining the list of VIPs that receive 24/7 monitoring and
// page the oncall after hours. These VIPs are usually heavily used, optionally public facing VIPs that are fronting
// by production systems (eg. Artifactory, Edge etc). VIVIPs will be tagged by vip-wd as `veryImportantVip=true`
// and a special 24/7 alert can be created only for these VIPs.
//
// 2. slaOptOutVips -- VIPs that are opted out from SLA (but not from monitoring).
//
// Ideally, this list would be empty; however, bugs in our monitoring necessitate a way for us to temporarily exclude
// one or more VIPs from monitoring until the bug can be fixed.
//
// VIPs opted out of SLA do not receive any SLA guarantees. Use with caution. Bias for fixing the monitoring
// bug rather than adding to this list. When adding to this list, include a detailed comment (or link to a work item)
// indicating why the VIP is being included and when it can be removed.
//
// The structure of the JSON object is like:
// {
//    <controlEstate>: // The name of the k8s control estate hosting the VIP.
//    {
//      slaOptOutVips:  // Optional. If included, specifies one or more VIPs that should be explicitly opted out from SLA eligibility.
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
// The format of entries in the lists can be either:
// * FQDN:port (eg. ops0-dvaregistryssl1-0-prd.slb.sfdc.net:443)
// * VIP:port  (eg. 13.110.24.14:80)
// Simple glob-style wildcards are also permitted, e.g., "*dvaregistry*:*".

local slbimages = import "slbimages.jsonnet";

local vipwdConfig = {
  "prd-sdc":
  {
    // Some canary vivips for testing
    vivips:
    [
      "slb-canary-proxy-http.sam-system.prd-sdc.prd.slb.sfdc.net:*",
    ],
    slaOptOutVips:
    [
      // 2019/05/27 - mgrass: This VIP is configured to require client certs (mtls: true), but the backends (slb-canary) don't
      // require a client cert. VIP watchdog never presents a client cert on TLS sessions, so it is able to reach the backends
      // but unable to talk to the VIP, causing the VIP to be treated as SLA-eligible but failing (triggering alerts).
      // Remove once W-6182163 (https://gus.lightning.force.com/lightning/r/ADM_Work__c/a07B0000006uYhEIAU/view) is resolved.
      "slb-canary-envoy-svc.sam-system.prd-sdc.prd.slb.sfdc.net:8443",
    ],
  },
  "prd-sam":
  {
    slaOptOutVips:
    [
      // 2019/01/02 - mgrass: This VIP is using a rather interesting construct -- it's a VIP that points to a backend that is . . . a VIP:
      //  https://git.soma.salesforce.com/sam/manifests/blob/befcf4a6d97a0a4cb8904293aed5f9f78c571cb9/apps/user/vijay-kota/vips/vips.yaml#L3
      //  Vijay's reasoning for doing this:
      //    This is not a real scenario :slightly_smiling_face: I have defined a HTTP VIP with tls:true to enforce HTTPS. But I want to use
      //    the browser and just send HTTP requests. So I defined another VIP with tls:false and reencrypt:true to force an HTTPS request to
      //    the actual VIP. I will be removing the vips.yaml under apps/user after my debugging is over.
      //
      //  TODO: follow up with Vijay to see if this VIP is still needed. Now that https VIPs don't demand a client certificate, it shouldn't be
      //        necessary.
      "us99-sfproxytest-vip-vijay-kota-prd.slb.sfdc.net:*",
      // 2019/01/02 - mgrass: This VIP has a single backend, and that backend is sending unreliable health signals. See
      // https://computecloud.slack.com/archives/G340CE86R/p1545408207001700?thread_ts=1545402611.001100&cid=G340CE86R. This should be removed
      // when the underlying issues discussed in https://gus.lightning.force.com/a07B0000004j96jIAA are resolved.
      "us98-mist61sfproxy-lb.core-on-sam-sp2.prd-sam.prd.slb.sfdc.net:*",
      // 2019/01/31 - mgrass: Long-time flaky VIP in user namespace. Opting out to address more pressing matters.
      // Investigation here: https://computecloud.slack.com/archives/G340CE86R/p1548979993685500?thread_ts=1548979508.678000&cid=G340CE86R.
      "aqueduct.user-varun-vyas.prd-sam.prd.slb.sfdc.net:*",
      // 2019/01/02 - mgrass: Issues with our monitoring cause some of the steam VIPs to be incorrectly marked as SLA eligible even with flappy
      // backends.
      // TODO: it's possible that the steam VIPs are no longer symptomatic. Confirm whether https://gus.lightning.force.com/a07B0000004j96jIAA resolved.
      "*-prd-steam-prd*",
      // 2019/04/06 - mgrass: This VIP sporadically times out on VIP watchdog requests, leading to alert noise.
      // See discussion in https://computecloud.slack.com/archives/G340CE86R/p1554570646338100?thread_ts=1554495337.333600&cid=G340CE86R,
      // and W-5834420, which would allow VIP watchdog to look at paths other than `/` (which may be load-sensitive).
      "shared1-argustsdbw1-0-prd.slb.sfdc.net:*",
      // 2019/04/24 - hsuanyu-chen: All of the backend pods are not in running state and is causing noise.
      // See discussion in https://computecloud.slack.com/archives/G340CE86R/p1556125820094800
      "zipkin-alpha.distributed-tracing.prd-sam.prd.slb.sfdc.net:80",
      // 2019/05/03 - mgrass: Flappy upstreams timing out requests make VIP watchdog sad.
      "ceph0-dash-prd.slb.sfdc.net:*",
      // 2019/05/09 - hsuanyu-chen: Flappy updstreams and was down the next day.
      "mysql.flowsnake.prd-sam.prd.slb.sfdc.net:*",
      // 2019/05/28 - mgrass: upstream pod is in CrashLoopBackOff. See https://computecloud.slack.com/archives/G340CE86R/p1559077619296600?thread_ts=1559077522.296100&cid=G340CE86R.
      // W-6079563 (https://gus.lightning.force.com/a07B0000006JutqIAC), when implemented, should help reduce the alert noise by
      // requiring the backend servers to report a consistent signal.
      "topology-svc-lb.topology-svc.prd-sam.prd.slb.sfdc.net:*",
      // 2019/05/30 - mgrass: VIPs in firefly-<user> namespace frequently flap due to flaky backends.
      // W-6079563 (https://gus.lightning.force.com/a07B0000006JutqIAC), when implemented, should help reduce the alert noise by
      // requiring the backend servers to report a consistent signal.
      "*.firefly-*.prd-sam.prd.slb.sfdc.net:*",
      // .
      // 2019/05/27 - mgrass: This VIP is configured to require client certs (mtls: true), but the backends (slb-canary) don't
      // require a client cert. VIP watchdog never presents a client cert on TLS sessions, so it is able to reach the backends
      // but unable to talk to the VIP, causing the VIP to be treated as SLA-eligible but failing (triggering alerts).
      // Remove once W-6182163 (https://gus.lightning.force.com/lightning/r/ADM_Work__c/a07B0000006uYhEIAU/view) is resolved.
      "slb-canary-envoy-svc.sam-system.prd-sam.prd.slb.sfdc.net:8443",
      // Blacklisting VIPs in userspace
      "*.user-*.prd-sam.*",
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
       // Flowsnake VIPs
       "kubernetes-api-flowsnake-prd.slb.sfdc.net:443",
       "ingress-flowsnake-prd.slb.sfdc.net:443",
    ],
  },
  "prd-samtwo":
  {
    slaOptOutVips:
    [
      // 2019/04/15 - mgrass: The backends for this VIP periodically throw 502s,
      // which confuses our monitoring. See
      // https://computecloud.slack.com/archives/G340CE86R/p1554402693285500?thread_ts=1554399030.275100&cid=G340CE86R
      // W-5369186 is the user story in our backlog for addressing this.
      // https://gus.my.salesforce.com/one/one.app#/alohaRedirect/a07B0000005YHAjIAO
      "sfcd-onboarding-test.sfcd.prd-samtwo.prd.slb.sfdc.net:443",
      "*firefly*test*",
      "*test*firefly*",
      // 2019/05/26 - mgrass: This VIP has a single flappy backend (SAM app that is in crashloopbackoff).
      // W-6079563 (https://gus.my.salesforce.com/a07B0000006JutqIAC) should help filter out such VIPs by
      // implementing rise/fall counts in VIP watchdog.
      "zipkin-beta.distributed-tracing.*",
    ],
  },
  "xrd-sam":
  {
    slaOptOutVips:
    [
      // 2019/04/27 - mgrass: The backends for this VIP are throwing 502s, confusing our monitoring.
      // See https://computecloud.slack.com/archives/G340CE86R/p1556422517300100
      // Opting this VIP out of SLA eligibility for now.
      "vir501-1-0-xrd.slb.sfdc.net:9191",
      // 2018/12/27 - mgrass: A known issue in our monitoring is causing these RDI VIPs in XRD to generate false alarms.
      // These should be removed when the underlying issues discussed in https://gus.lightning.force.com/a07B0000004j96jIAA
      // are resolved.
      "vir511-1-0-xrd*",
      "vir512-1-0-xrd*",
      // 2019/05/03 - mgrass: Flappy upstreams timing out requests make VIP watchdog sad.
      "ceph0-dash-prd.slb.sfdc.net:*",
      // 2019/05/22 - pperger: 1x healthy by port check, 1x healthy by health check results in
      //              SLA-eligible VIP despite despite no single backend being 100% healthy.
      // W-6178236
      "horizon-xrd*",
      // 2019/07/25 nkatta: Taking sledge VIPs out because the backends are unstable due to patching.
      "sledge-xrd*",
      //2019/09/18 shravya-srinivas: Flappy upstreams timing out requests make VIP watchdog sad.
      "aqueduct-func.emp-aqueduct.xrd-sam.xrd*",
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
    slaOptOutVips:
    [
      // 2019/02/13 - vyjayanthi.raja
      // Associated investigation: https://computecloud.slack.com/archives/G340CE86R/p1550093301234000?thread_ts=1550091904.233300&cid=G340CE86R
      "spaasmeshlb.service-protection.phx-sam.phx.slb.sfdc.net:15399",
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
    slaOptOutVips:
    [
      // 2019/09/23 - shravya-srinivas
      // Investigating ia2 ACLs
      "org-cce2e-cs22-slb-ia2.slb.sfdc.net:*",
    ],
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

// List of VIPs that are opted out of SLA globally. Entries here must use glob syntax to identify VIPs.
local globalSlaOptOutVips = [
  // Portal has known issues where page load depends on how responsive DNS lookups are. This can lead to
  // flakiness in VIP watchdog's alerting.
  // see https://gus.lightning.force.com/lightning/r/ADM_Work__c/a07B0000006QrWiIAK/view for more details
  "*slb-portal-service*",
];

// List of global very important VIPs. Entries here must use glob syntax to identify VIPs.
local globalVivips = [
];

local getEstateSpecificVIPSet(estateConfig, vipSetName) =
  if std.objectHas(estateConfig, vipSetName) then estateConfig[vipSetName] else [];

local getEstateConfig(estate) =
  if std.objectHas(vipwdConfig, estate) then vipwdConfig[estate] else {};

local getVipWdVipParameter(estate, estateConfigName, globalVipSet, parameterName) = (
  local vipSet = getEstateSpecificVIPSet(getEstateConfig(estate), estateConfigName) + globalVipSet;
  if std.length(vipSet) > 0 then ["--%s=%s" % [parameterName, std.join(",", vipSet)]] else []
);

{
  // getVipWdOptOutOptions builds the command line parameters to supply to VIP watchdog. `estate` is the name of the control
  // estate (e.g., "prd-sam") to retrieve VIP watchdog options for.
  getVipWdConfigOptions(estate):: (
    getVipWdVipParameter(estate, "vivips", globalVivips, "veryImportantVips") +
    getVipWdVipParameter(estate, "slaOptOutVips", globalSlaOptOutVips, "slaOptOutVips")
  ),
}
