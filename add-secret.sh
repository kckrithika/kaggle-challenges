#/bin/bash

display_usage() {
  echo 'Usage : ./add-secret.sh [arguments]'
  echo '-n|-name : <secretName>'
  echo '-o|-org : <team/teamName> or <user/user-name>'
  echo '-k|-kingdom : <kingdomList>'
  echo '-g|-global'
  echo '-ff|-from-file : <pathToFile>'
}

# if no argument supplied, display usage
if [  $# -le 0 ]
    then
        display_usage
        exit 1
fi

index=0
GLOBAL=false
for i in "$@"
do
case $i in
    -n=*|-name=*)
    NAME="${i#*=}"
    shift # past argument=value
    ;;
    -o=*|-org=*)
    ORG="${i#*=}"
    shift # past argument=value
    ;;
    -k=*|-kingdom=*)
    KINGDOM="${i#*=}"
    shift # past argument=value
    ;;
    -g*|-global*)
    GLOBAL=true
    shift # past argument=value
    ;;
    -ff*|-from-file*)
    FROM_FILE[index]="${i#*=}"
    ((index++))	
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

#Remove next line after moratorium. This is just to use the updated hypersam image
HYPERSAM=ops0-artifactrepo1-0-prd.data.sfdc.net/tnrp/sam/hypersam:sam-0001451-cff3beb4

echo ${PWD}
docker run \
  --rm \
  -it \
  -u 0 \
  -v ${PWD}:/repo \
  -v /:/hostroot \
  ${HYPERSAM} \
  manifestctl \
  encrypt \
  --manifestRepoRoot='/repo/' \
  --hostRoot='/hostroot/' \
  --secretName=${NAME}\
  --teamOrUserName=${ORG}\
  --kingdomList=${KINGDOM}\
  --global=${GLOBAL}\
  --fromFile=${FROM_FILE[*]}\  

