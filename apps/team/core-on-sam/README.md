# Core App on SAM Manifest Generator

Primary **Goals** of the template is to

- Host `jsonnet` templates for generating [SAM Manifests](https://git.soma.salesforce.com/sam/manifests) for all CASAM deployments
- Provides necessary scripts to generate and validate the `jsonnet` files before committing them to SAM manifest repo
- Streamline and provide consistent deployment configs/setups for various _CoreApp_ deployments that are based on `Kubernetes`

```bash
casam manifest generator
Usage: ./scripts/gen [-b|--build-dir <build-dr>] [-f|--for <region/env>]
        [-j|--json-only] [-v|--version] [-h|--help]

        -b,--build-dir: Build ouptput dir. (default: 'build')
        -f,--for: Generate manifest only for an env (default: all)
        -j,--json-only: Generate the manifest in json-format. (default is 'yaml')
        -v,--version: Prints version
        -h,--help: Prints help
```

## Naving Convention

```bash
 |
 |- <region>
   |
   |- <environment name>
```

#### For example

```bash
├── fra
│   └── env.json
│   ├── cs103
│   │   ├── env.json
│   │   └── manifest.jsonnet
│   └── cs104
│       ├── env.json
│       └── manifest.jsonnet
├── gcp
│   ├── env.json
│   └── alpha
│       ├── env.json
│       └── manifest.jsonnet
├── prd
│   ├── env.json
│   ├── gatekeeper
│   │   ├── env.json
│   │   └── manifest.jsonnet
│   ├── mist61-a
│   │   ├── env.json
│   │   └── manifest.jsonnet
```

## Getting started

Fork [SAM Manifest](https://git.soma.salesforce.com/sam/manifests) repo.

Typical work flow if you are creating a new environment would be to create a appropriate folders as noted above and specify the env specific overrides. Similarly if you are modifying you would modify the files under the appropriate directory for an environment.

After creating or modifying the environment sepcific files you need to run `./scripts/gen`.

```bash
./scripts/gen
```

### Environment Config
There is a [default env file](https://git.soma.salesforce.com/sam/manifests/blob/master/templates/default-env.json) that includes all possible variables that can be used for substitution while compiling the jsonnet template files for various environments. In otherwords every name/value environment property that is expected to changed either at the `region` or `instance` level must be defined in this file.

The values defined in the default env file can be overriden either at the `region` level or at the `instance` level. For example the `db connect` information is instance sepcific and can be specified at `<region>/<instance>/env.json`. Similarly `superpod` level service or the `data center/region` wide service can be specified as property name/values properties at `region/env.json` file. 

### Formatting the jsonnet files

```bash
./scripts/fmt
```

### Generating the manfiest for all environments

```bash
./scripts/gen
```

### Generating the manfiest for a specific environment

```bash
./scripts/gen --for prd/gatekeeper --json-only
```

### Misc Notes

- [Pool Map](https://git.soma.salesforce.com/sam/manifests/blob/master/apps/team/core-on-sam/pool-map.yaml) still needs to be updated accordingly so SAM will actually target these apps to the right nodes in the cluster

- In transitioniong to public clould, one of the term that will often be repeated would be `region`. Roughly our data center or kingdome maps to a region in the public cloud. Similarly a Salesforce Pod or an Instance is just a deployment environment. Examples `gs0, cs103, na44, alpha`

#### TODO

- Automate this workflow to update the sam manifest with a CI process
