## Mobile Health Monitoring

This houses various services to monitor the health of our mobile applications
on Google Play Store, iTunes App Store.
These apps run in PRD sandbox, they do not run in production data centers.

The monitoring sends data to Argus as well as Appulse org (a salesforce org in
production)

## Team
See `access.yaml`

## Network access (work in progress)
- Direct access
  - https://secretservice.dmz.salesforce.com:8271
  - grpc: 10.252.130.228:50051
- Through PRD HTTP(s) proxy:
  - https://login.salesforce.com
  - https://appulse.my.salesforce.com
  - https://www.googleapis.com
  - https://itunes.apple.com
  - https://login.microsoftonline.com
  - https://manage.devcenter.microsoft.com
  - https://storage.googleapis.com (optional)


### Resources and Links

- [Appulse](https://appulse.my.salesforce.com/) (Aloha SSO)
- [GUS Service record](https://gus.my.salesforce.com/a6fB0000000Cb6TIAS)
- [PagerDuty](https://salesforce.pagerduty.com/services/P0HMGXM)
- [Team wiki](https://sites.google.com/a/salesforce.com/q3-mobile-team/home)
