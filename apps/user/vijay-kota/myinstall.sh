#!/bin/bash
#
# off-core sayonara installer
# relies on artifacts existing in nexus: e.g. https://nexus.soma.salesforce.com/nexus/content/repositories/workspaces/sfdc.core/sayonara/Linux/
# Based on gbaker's sdb-installer
# nmuthukrishnan

# The following env vars has to be present in the manifest. If not found, fail.
# [ -z "${NEXUS_USERNAME:-}" ] && echo "NEXUS_USERNAME env var missing" && exit 1
# [ -z "${NEXUS_PASSWORD:-}" ] && echo "NEXUS_PASSWORD env var missing" && exit 1
# [ -z "${SDB_VERSION:-}" ] && echo "SDB_VERSION env var missing" && exit 1
# [ -z "${SFDC_BRANCH:-}" ] && echo "SFDC_BRANCH env var missing" && exit 1
# [ -z "${CHANGELIST:-}" ] && echo "CHANGELIST env var missing" && exit 1

PGHOST=${PGHOST:-localhost}
PGPORT=${PGPORT:-1521}
NEXUS_BASE_URL="https://nexus.soma.salesforce.com/nexus/content/repositories/workspaces/sfdc.core"

DOWNLOAD_REQUIRED="true"
# optimization for linux only - if the installed version matches then don't download again
if [[ "$(uname)" == "Linux" ]]
then
  if type pgbuild/bin/psql
  then
    if [[ "$(pgbuild/bin/psql --version | grep -oP '\d+\.\d+\.\d+')" == "$SDB_VERSION" ]]
    then
      DOWNLOAD_REQUIRED="false"
    fi
  fi
fi


# Download SDB binaries
if [[ "${DOWNLOAD_REQUIRED}" == "true" ]]
then
  SDB_VERSION=${SDB_VERSION:-324.10.1}
  IMAGE_NAME="deploy.$SDB_VERSION.ssl.tar.bz2"
  cat /home/sdb/mydir/$IMAGE_NAME | bunzip2 -c | tar xfpB -

  #NEXUS_SDB_BINARY_URL="${NEXUS_BASE_URL}/sayonara/$(uname)/${IMAGE_NAME}"

  #f curl --silent --head --insecure --fail -u ${NEXUS_USERNAME}:${NEXUS_PASSWORD} ${NEXUS_SDB_BINARY_URL}; then
  # # fetch the executable
  # echo "Downloading ${IMAGE_NAME} from nexus..."
  # curl --insecure --fail -s -u ${NEXUS_USERNAME}:${NEXUS_PASSWORD} ${NEXUS_SDB_BINARY_URL} | bunzip2 -c | tar xfpB -
  #lse
  # echo "${IMAGE_NAME} artifact doesnot exist in nexus"
  # exit 1
  #i

fi

CHANGELIST=${CHANGELIST:-19252256}
cat /home/sdb/mydir/${CHANGELIST}.sdbdata.tar.bz2 | bunzip2 -c | tar xfpB - --strip-components=1

#Download corresponding SDB data
#NEXUS_SDB_DATA_URL="${NEXUS_BASE_URL}/${SFDC_BRANCH}/${CHANGELIST}/sfdc/sayonara/sdbdata.tar.bz2"
#f curl --silent --head --insecure --fail -u ${NEXUS_USERNAME}:${NEXUS_PASSWORD} ${NEXUS_SDB_DATA_URL}; then
# echo "Downloading sdbdata artifact from nexus..."
# curl --insecure --fail -s -u ${NEXUS_USERNAME}:${NEXUS_PASSWORD} ${NEXUS_SDB_DATA_URL} | bunzip2 -c | tar xfpB - --strip-components=1
#lse
# echo  -e "Failed to download sdbdata artifact from nexus.  This could be for one of the following reasons:\n 1) you are on old perforce changelist (${CHANGELIST}) that no longer has artifacts in nexus. resolution: Consider sync'ing to a newer changelist. \n 2) there is no producer build for your branch (${SFDC_BRANCH}). resolution: Consider setting up a local SDB. \n 3) nexus is down.  resolution: Check internal trust chatter group \n 4) You can't reach nexus.  resolution: Connect to the internet, get on the VPN and/or authenticate to SFM."
# exit 1
#i

# Add bin to PATH
export PATH=$(pwd)/pgbuild/bin:${PATH}

SFDC_BRANCH=${SFDC_BRANCH:-main}
SAYONARA_DBNAME=sdb$(echo $SFDC_BRANCH | awk -F_ '{print $1}')

# fix the pgfilestore guc in postgresql.conf
echo "sdb_store = pgfilestore:$(pwd)/${SAYONARA_DBNAME}_common_store" >> ${SAYONARA_DBNAME}/postgresql.conf
if [ -f $(pwd)/postgresql.conf.dev ]
    then
        echo "Appending postgresql.conf.dev to $(pwd)/${SAYONARA_DBNAME}/postgresql.conf"
        cat $(pwd)/postgresql.conf.dev  >> ${SAYONARA_DBNAME}/postgresql.conf
fi

#TODO: Trusting all connections now. But need to change this to let cix set the 
# list of ips that it wants to trust to make a connection.
echo "Appending host all all 0.0.0.0/0 trust to $(pwd)/${SAYONARA_DBNAME}/pg_hba.conf"
echo "host all all 0.0.0.0/0 trust" >> ${SAYONARA_DBNAME}/pg_hba.conf

# Start SDB
echo "Starting SDB"
pg_ctl -D ${SAYONARA_DBNAME} start -o "-p $PGPORT" -w -l startup.log

echo Tailing startup log...
tail --retry -f startup.log
