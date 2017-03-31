#!/bin/bash

# Script to generate yaml files for all our apps in all estates
# ./build.sh


#Check if jsonnet is available, if not get it.
if [ ! -f jsonnet/jsonnet ]; then
    echo "Getting jsonnet..."
    git clone git@git.soma.salesforce.com:sam/jsonnet.git
    pushd jsonnet
    make
    popd
fi

rm -rf ../k8s-out/**

#Generates YAML files for a given cluster.
generateConfigs() {
  currentKingdom=$1
  currentEstate=$2

  dir=../k8s-out/$currentKingdom/$currentEstate/
  mkdir -p $dir

  for filename in templates/*.jsonnet; do
      appName=$(basename "$filename" .jsonnet)
      echo "Generating config file for $appName in estate $currentEstate"
      ./jsonnet/jsonnet -V kingdom=$currentKingdom -V estate=$currentEstate templates/$appName.jsonnet -o $dir/$appName.json --jpath .
      # For some experimental features, we'd like to generate manifests only for
      # certain SAM clusters. To achieve this, the jsonnet templates may emit
      # the quoted string "SKIP" where their output is not wanted.
      if [ "x$(head -n 1 $dir/$appName.json)" == 'x"SKIP"' ]; then
        echo "(skipped)"
        rm $dir/$appName.json
      fi
  done
}


rm -rf generated/

declare -a kingdomEstates=("prd/prd-sam" "prd/prd-samdev" "prd/prd-samtest" "prd/prd-sdc" "dfw/dfw-sam" "phx/phx-sam" "frf/frf-sam" "par/par-sam")

for kingdomEstate in "${kingdomEstates[@]}"
do
      IFS='/' read -ra arr <<< "$kingdomEstate"
      kingdom=${arr[0]}
      estate=${arr[1]}
      generateConfigs $kingdom $estate
done

# TODO: Add warning when running against out-of-sync git repo

# TODO: Add some basic validations
