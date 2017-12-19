# Service Mesh
SAM Services owned by the [Service Mesh](https://gus.lightning.force.com/one/one.app#/sObject/0F9B0000000Cgm7KAC/view) team.

## geoip-nk
An implementation of the GeoIP service that always thinks the requester is from North Korea.

*But why?* For testing Dynamic Request Routing. GeoIP-NK announces itself under a different name. Using the dynamic request
routing headers, you can switch from the real and -NK service on a request-by-request basis.