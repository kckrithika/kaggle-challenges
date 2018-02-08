## SAM Team Folders

Process for adding a new SAM team folder:

1. Start with a PR that creates just the team folder, access.yaml and pool-map.yaml.  Do not include any other changes.
1. Team names need to be unique across the company and not ambiguous.  
1. Team names are used to generate Kubernetes namespaces, so the team name needs to follow the same rules as kubernetes namespaces.  You can find the name restrictions [here](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture/identifiers.md), essentially (a-z0-9) and '-' not as first or last character.  To keep pod and superpod namespaces unique, SAM needs to add characters to generated namespace in these cases, so we restrict customers to 50 characters instead of 63.  A good number of existing team folders don't follow these restrictions, but we will migrate them over time.
1. In the PR, please include a link to your team's service object in GUS.  These live [here](https://gus.lightning.force.com/lightning/o/Service__c/list?filterName=00BB0000001zRFx)
1. For a quick response, send a note to sam@salesforce.com with a link to the PR.
1. A SAM Admin will register the team name in the [GlobalRegistry](https://git.soma.salesforce.com/Infrastructure-Security/GlobalRegistry/) which is a requirement to give certificates to this namespace.  This process can take a few days.  Only after the SAM admin has verified uniqueness will we merge the PR in sam/manifests.
1. Only SAM Admins can approve a PR that adds a new team.  List of admins can be found [here](https://git.soma.salesforce.com/sam/manifests/blob/master/access.yaml)
