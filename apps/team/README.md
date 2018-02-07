## SAM Team Folders

Process for adding a new SAM team folder:

1. Start with a PR that creates just the team folder, access.yaml and pool-map.yaml.  Do not include any other changes.
1. Team names are used to generate Kubernetes namespaces, so the team name needs to follow the same rules as kubernetes namespaces.  You can find the name restrictions [here](https://github.com/kubernetes/community/blob/master/contributors/design-proposals/architecture/identifiers.md), essentially (a-z0-9) and '-' not as first or last character.  To keep pod and superpod namespaces unique, SAM needs to add characters to generated namespace in these cases, so we restrict customers to 50 characters instead of 63.  A good number of existing team folders don't follow these restrictions, but we will migrate them over time.
1. A SAM Admin needs to approve any PR that adds a new team.  List of admins can be found [here](https://git.soma.salesforce.com/sam/manifests/blob/master/access.yaml)
1. The SAM Admin will register the team name in the [GlobalRegistry](https://git.soma.salesforce.com/Infrastructure-Security/GlobalRegistry/) so that this namespace can get unique certificates.  This means your team name needs to be clearly unique across the company.  This process can take a few days.
