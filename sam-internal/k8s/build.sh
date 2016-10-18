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
      ./jsonnet/jsonnet -V estate=$currentEstate templates/$appName.jsonnet -o generated/$currentKingdom/$currentEstate/appConfigs/json/$appName.json --jpath .

  done
}


rm -rf generated/

declare -a estates=("prd-sam" "prd-samtemp" "prd-samdev" "dfw-sam")
declare -a kingdoms=("prd" "dfw")

for estate in "${estates[@]}"
do
  for kingdom in "${kingdoms[@]}"
  do
      if [[ $estate == $kingdom* ]]
      then
          generateConfigs $kingdom $estate
      fi
  done
done

# TODO: Add warning when running against out-of-sync git repo

# TODO: Add some basic validations
