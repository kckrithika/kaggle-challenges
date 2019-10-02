#!/bin/sh

NEWVERSION=$1
shift

warden_prd() {
    perl -i -pe"s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prd-warden/manifest.yaml
    perl -i -pe"s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prd-warden-stage/manifest.yaml
}

warden_prod() {
    perl -i -pe"s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prod-warden/manifest.yaml
    perl -i -pe"s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prod-warden-alternate/manifest.yaml
    perl -i -pe"s/image: dva\/casp\/warden_strata:[0-9]*/image: dva\/casp\/warden_strata:$NEWVERSION/g" prod-warden-mofo/manifest.yaml
}

warden() {
    warden_prd
    warden_prod
}

maiev_prd() {
    perl -i -pe"s/image: dva\/maiev-receiver:[0-9]*/image: dva\/maiev-receiver:$NEWVERSION/g" prd-maiev-receiver/manifest.yaml
}

maiev_prod() {
    perl -i -pe"s/image: dva\/maiev-receiver:[0-9]*/image: dva\/maiev-receiver:$NEWVERSION/g" prod-maiev-receiver/manifest.yaml
    perl -i -pe"s/image: dva\/maiev-receiver:[0-9]*/image: dva\/maiev-receiver:$NEWVERSION/g" prod-maiev-receiver-alternate/manifest.yaml
    perl -i -pe"s/image: dva\/maiev-receiver:[0-9]*/image: dva\/maiev-receiver:$NEWVERSION/g" prod-maiev-receiver-mofo/manifest.yaml
}

maiev() {
    maiev_prd
    maiev_prod
}

cantor_prd() {
    perl -i -pe"s/image: dva\/casp\/cantor_strata:[0-9]*/image: dva\/casp\/cantor_strata:$NEWVERSION/g" prd-cantor-grpc-server/manifest.yaml
}

cantor_prod() {
    perl -i -pe"s/image: dva\/casp\/cantor_strata:[0-9]*/image: dva\/casp\/cantor_strata:$NEWVERSION/g" prod-cantor-grpc-server/manifest.yaml
    perl -i -pe"s/image: dva\/casp\/cantor_strata:[0-9]*/image: dva\/casp\/cantor_strata:$NEWVERSION/g" prod-cantor-grpc-server-frf/manifest.yaml
    perl -i -pe"s/image: dva\/casp\/cantor_strata:[0-9]*/image: dva\/casp\/cantor_strata:$NEWVERSION/g" prod-cantor-grpc-server-drop-1-1/manifest.yaml
    perl -i -pe"s/image: dva\/casp\/cantor_strata:[0-9]*/image: dva\/casp\/cantor_strata:$NEWVERSION/g" prod-cantor-grpc-server-alternate/manifest.yaml
}

cantor() {
    cantor_prd
    cantor_prod
}

mysql_prd() {
    perl -i -pe"s/image: dva\/casp\/mysql_strata:[0-9]*/image: dva\/casp\/mysql_strata:$NEWVERSION/g" prd-mysql-shard-a/manifest.yaml
    perl -i -pe"s/image: dva\/casp\/mysql_strata:[0-9]*/image: dva\/casp\/mysql_strata:$NEWVERSION/g" prd-mysql-shard-a-stage/manifest.yaml
}

mysql_prod() {
    perl -i -pe"s/image: dva\/casp\/mysql_strata:[0-9]*/image: dva\/casp\/mysql_strata:$NEWVERSION/g" prod-mysql-shard-a/manifest.yaml
    perl -i -pe"s/image: dva\/casp\/mysql_strata:[0-9]*/image: dva\/casp\/mysql_strata:$NEWVERSION/g" prod-mysql-shard-a-alternate/manifest.yaml
    perl -i -pe"s/image: dva\/casp\/mysql_strata:[0-9]*/image: dva\/casp\/mysql_strata:$NEWVERSION/g" prod-mysql-shard-a-fast/manifest.yaml
}

mysql() {
    mysql_prd
    mysql_prod
}

set -e

if [ "$#" = 0 ]
then
    warden
    exit
fi

for env in "$@"
do
    $env
done
