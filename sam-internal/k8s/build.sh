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
  currentEstate=$1

  mkdir -p generated/$currentEstate/appConfigs/json

  for filename in templates/*.jsonnet; do
      appName=$(basename "$filename" .jsonnet)
      echo "Generating config file for $appName in estate $currentEstate"
      ./jsonnet/jsonnet -V estate=$currentEstate templates/$appName.jsonnet -o generated/$currentEstate/appConfigs/json/$appName.json --jpath .

  done
}


rm -rf generated/

declare -a estates=("prd-sam" "prd-samtemp")

for anEstate in "${estates[@]}"
do
  generateConfigs $anEstate
done

# TODO: Add warning when running against out-of-sync git repo

# TODO: Add some basic validations
