// This file declares VIP configurations that are currently omitted from monitoring by VIP watchdog.
//
// Ideally, this list would be empty; however, bugs in our monitoring necessitate a way for us to temporarily exclude
// one or more VIPs from monitoring until the bug can be fixed.
//
// This is a rather large hammer -- VIPs filtered from monitoring do not receive any SLA guarantees, and VIP metrics
// (availability, backend health, etc), are not emitted to Argus. Use with caution. Bias for fixing the monitoring
// bug rather than adding to this list. When adding to this list, include a detailed comment (or link to a work item)
// indicating why the VIP is being filtered and when the filter can be expected to be removed.
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
//    },
// },
//
// A "service list" is an internal SLB concept. It has a mapping for both k8s services and self-service vips.
// * For VIPs bound to a k8s service, the "service list" name is the name of the k8s service declaring the VIP.
// * For self-service VIPs, the "service list" name corresponds to the "lbname" field in the VIP declaration.
//
// Similarly, the "namespace" used here depends on whether the VIP is bound to a k8s service or self-service:
// * For VIPs bound to a k8s service, the namespace is the containing namespace for the service resource.
// * For self-service VIPs, the namespace is always "kne".

local vipwdOptOutConfig = {
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
    ],
    namespaces:
    [
      // 2018/12/19 - mgrass: As best I can tell, this was added with https://git.soma.salesforce.com/sam/manifests/pull/12007/files#diff-e4ae2ca13fca104e5cff4a498c5f1c87R151.
      // I can't find a concrete reason for why it was added, but slack messages proximate to this PR suggest that it may have been
      // because the VIP were using DSR but the real servers were not running our puppet module.
      // It appears the VIP has since been converted to tcp instead of dsr with https://git.soma.salesforce.com/sam/manifests/pull/12147,
      // so this exclusion should probably just be removed.
      "podgroup-prebuild",
    ],
  },

  "xrd-sam":
  {
    serviceLists:
    [
      // 2018/12/19 - mgrass: This exclusion was added with https://git.soma.salesforce.com/sam/manifests/pull/12007.
      // It is unclear why that VIP was excluded from monitoring, but in any case, the  "slb-canary-service-ext" service was deleted
      // in https://git.soma.salesforce.com/sam/manifests/pull/14314, so this exclusion can be removed.
      "slb-canary-service-ext",
      // 2018/12/27 - mgrass: A known issue in our monitoring is causing these RDI VIPs in XRD to generate false alarms.
      // These should be removed when the underlying issues discussed in https://gus.lightning.force.com/a07B0000004j96jIAA
      // are resolved.
      "vir501-1-0-xrd",
      "vir502-1-0-xrd",
      "vir503-1-0-xrd",
      "vir504-1-0-xrd",
      "vir505-1-0-xrd",
      "vir506-1-0-xrd",
      "vir507-1-0-xrd",
      "vir508-1-0-xrd",
      "vir509-1-0-xrd",
      "vir510-1-0-xrd",
      "vir511-1-0-xrd",
      "vir512-1-0-xrd",
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

{
  // getVipWdOptOutOptions builds the command line parameters to supply to VIP watchdog. `estate` is the name of the control
  // estate (e.g., "prd-sam") to retrieve opt-out options for.
  getVipWdOptOutOptions(estate):: (
    if !std.objectHas(vipwdOptOutConfig, estate) then []
    else getOptOutServiceListParameter(vipwdOptOutConfig[estate]) + getOptOutNamespaceParameter(vipwdOptOutConfig[estate])
  ),
}
