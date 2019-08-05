#!/bin/sh

NEWVERSION=$1
shift

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
    sed -i "s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prod-warden-fra/manifest.yaml
    sed -i "s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prod-warden-cdg/manifest.yaml
}

set -e

if [ "$#" = 0 ]
then
    prd
    staging
    prod
    exit
fi

for env in "$@"
do
    $env
done