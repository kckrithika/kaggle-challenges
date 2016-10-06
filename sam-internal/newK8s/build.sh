#/bin/bash -xe

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
generateYAMLs() {
  currentEstate=$1

  mkdir -p generated/$currentEstate/appConfigs/yaml
  mkdir -p generated/$currentEstate/appConfigs/json

  for filename in templates/*.jsonnet; do
      appName=$(basename "$filename" .jsonnet)
      echo "Generating yaml file for $appName in estate $currentEstate"
      ./jsonnet/jsonnet -V estate=$currentEstate templates/$appName.jsonnet -o generated/$currentEstate/appConfigs/json/$appName.json --jpath .

      #Convert all the files from json to yaml
      #TODO: Make this as a separate python script 
      python -c "import sys, yaml, json; print yaml.dump(yaml.load(json.dumps(json.loads(open('generated/$currentEstate/appConfigs/json/$appName.json').read()))), default_flow_style=False)" > generated/$currentEstate/appConfigs/yaml/$appName.yaml

  done
  #Delete json files
  rm -rf generated/$currentEstate/appConfigs/json
}


rm -rf generated/

declare -a estates=("prd-sam" "prd-samtemp")

for anEstate in "${estates[@]}"
do
  generateYAMLs $anEstate
done

# TODO: Add warning when running against out-of-sync git repo

# TODO: Add some basic validations
