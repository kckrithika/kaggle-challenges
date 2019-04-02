#!/bin/sh
ARGS=("$@")

NEWVERSION=${ARGS[-1]}

#remove the last passed in param as it is the new version
unset ARGS[${#ARGS[@]}-1]

prd() {
    sed -i "s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prd-warden/manifest.yaml
}

staging() {
    sed -i "s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prd-warden-stage/manifest.yaml
}

prod() {
    sed -i "s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prod-warden-dfw/manifest.yaml
    sed -i "s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prod-warden-phx/manifest.yaml
    sed -i "s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prod-warden-iad/manifest.yaml
    sed -i "s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prod-warden-ord/manifest.yaml
    sed -i "s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prod-warden-ukb/manifest.yaml
    sed -i "s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prod-warden-par/manifest.yaml
    sed -i "s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prod-warden-frf/manifest.yaml
}

set -e

for env in ${ARGS[*]}
do
    $env
done