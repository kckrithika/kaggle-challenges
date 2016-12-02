#!/bin/bash 

# Script to generate yaml files for all our apps in all estates 
# ./build.sh 


#Check if jsonnet is available, if not get it.
if [ ! -f jsonnet/jsonnet ]; then
    echo "Getting jsonnet..."
    git clone https://github.com/google/jsonnet.git
    pushd jsonnet
    make
    popd
fi

#Generates YAML files for a given cluster.
generateConfigs() {
  currentKingdom=$1
  currentEstate=$2

  mkdir -p generated/$currentKingdom/$currentEstate/appConfigs/json

  for filename in templates/*.jsonnet; do
      appName=$(basename "$filename" .jsonnet)
      echo "Generating config file for $appName in estate $currentEstate"
      ./jsonnet/jsonnet -V kingdom=$currentKingdom -V estate=$currentEstate templates/$appName.jsonnet -o generated/$currentKingdom/$currentEstate/appConfigs/json/$appName.json --jpath .

  done
}


rm -rf generated/

declare -a kingdomEstates=("prd/prd-sam" "prd/prd-samtemp" "prd/prd-samdev" "dfw/dfw-sam" "phx/phx-sam")

for kingdomEstate in "${kingdomEstates[@]}"
do
      IFS='/' read -ra arr <<< "$kingdomEstate"
      kingdom=${arr[0]}
      estate=${arr[1]}
      generateConfigs $kingdom $estate
done

# TODO: Add warning when running against out-of-sync git repo

# TODO: Add some basic validations
