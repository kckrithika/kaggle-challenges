#!/bin/bash -e

display_usage() {
  echo 'Usage : ./add-secret.sh [argument=value]'
  echo '-n|--name : <secretName>'
  echo '-o|--org : <team/teamName> or <user/user-name>'
  echo '-k|--kingdom : <kingdom>[,<otherKingdom>]'
  echo '-s|--superpod : <superpod>[,<otherSuperpod>]'
  echo '-g|--global'
  echo '-f|--from-file : <pathToFile>'
  echo ''
  echo 'Example: ./add-secret.sh -n=mysecret -o=team/CSC_SAM -k=prd -f=$(pwd)/token.txt'
  echo 'This will create a K8S secret called "mysecret" which will contain a key "token.txt" with value from the file'
  echo 'See https://confluence.internal.salesforce.com/display/SAM/Using+K4A+for+your+SAM+Secrets'
}

# if no argument supplied, display usage
if [  $# -le 0 ]
    then
        display_usage
        exit 1
fi

index=0
GLOBAL=false
FROM_FILE_ARG="--fromFile="
for i in "$@"
do
case $i in
    --name=*|-n=*)
    NAME="${i#*=}"
    shift # past argument=value
    ;;
    --org=*|-o=*)
    ORG="${i#*=}"
    shift # past argument=value
    ;;
    --kingdom=*|-k=*)
    KINGDOM="${i#*=}"
    shift # past argument=value
    ;;
    --superpod=*|-s=*)
    SUPERPOD="${i#*=}"
    shift # past argument=value
    ;;
    --global*|-g*)
    GLOBAL=true
    shift # past argument=value
    ;;
    --from-file=*|-f=*)
    FROM_FILE[index]="$FROM_FILE_ARG${i#*=}"
    ((++index))
    shift # past argument=value
    ;;
    --default)
    DEFAULT=YES
    shift # past argument with no value
    ;;
    *)
          # unknown option
    ;;
esac
done

if [[ -n $1 ]];  then
	display_usage
        exit 1
fi

# Use this to get hypersam env var
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/sam-internal/hypersam.sh"

#Remove next line after the SMB release. This is just to use the updated hypersam image
HYPERSAM=ops0-artifactrepo1-0-prd.data.sfdc.net/tnrp/sam/hypersam:sam-0001746-68046186

docker run \
  --rm \
  -it \
  -u $(id -u):$(id -g) \
  -v ${PWD}:/repo \
  -v /:/hostroot \
  -v ${HOME}:/homedir \
  ${HYPERSAM} \
  manifestctl \
  encrypt \
  --manifestRepoRoot='/repo/' \
  --hostRoot='/hostroot/' \
  --userHomeDir='/homedir/' \
  --secretName=${NAME}\
  --teamOrUserName=${ORG}\
  --kingdomList=${KINGDOM}\
  --superPod=${SUPERPOD}\
  --global=${GLOBAL}\
  ${FROM_FILE[*]}
