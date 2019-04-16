# Email Infra (EaaS)

https://git.soma.salesforce.com/eaas/EmailService

##NOTES - PRD:

##### #mount pki client certs (and CA cert) for SMTP connection Eaas -> MTA`
`- mountPath: /etc/pki_service
name: eaas-client-cert`

##### #Generally we have set this to ~10 seconds longer than the readiness initialDelaySeconds
`livenessProbe:
	initialDelaySeconds: 120`

###### #This needs to be longer than the time for scone to start. Search the logs for 'Started EaasSconeApp' to get a sense of the startup time which is primary dependent on CPU resources.
`readinessProbe:
	initialDelaySeconds: 110`

##### #Namespaced, mTLS HTTP2 GRPC
`- emailinfra/eaas:DATACENTER_ALLENV:7443`

##### #Non namespaced, plain-text HTTP2 GRPC (PRD ONLY)
`- eaas:DATACENTER_ALLENV:7012`

##### #Non namespaced, plain-text HTTP1 for Chaos endpoint (PRD ONLY)
`- eaas-chaos:DATACENTER_ALLENV:7014`

##### #plain-text HTTP2 GRPC port (PRD ONLY)
`- name: sherpa-eaas-in`

##### #plain-text HTTP1 Jetty port (PRD ONLY)
`- name: sherpa-eaas-jet`

##### #mTLS HTTP2 GRPC port
`- name: sherpa-eaas-tls`

##### #management port (health, metrics, etc.)
`- name: sherpa-eaas-adm`

##### #Enable a load balancer in PRD so we have a stable FQDN to hit from the dev desktops or anywhere without Sherpa/Zookeeper (PRD ONLY)
##### #Full FQDN template: {lbname}.{namespace}.{estate}.{kingdom}.slb.sfdc.net
##### #Actual FQDN: emailinfra-eaas-lb.emailinfra.prd-sam.prd.slb.sfdc.net
` loadbalancers: - lbname: emailinfra-eaas-lb`


##NOTES - PROD

##### #See https://salesforce.quip.com/wbjKA0Z8kZk0 for a discussion of the number of pods (8) per node (5)
`- name: eaas count: 40`
