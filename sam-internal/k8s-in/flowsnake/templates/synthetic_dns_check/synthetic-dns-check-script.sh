#!/bin/bash
function do_log {
    # Join together into a single line so that it sends up in a single Splunk entry. :-(
    echo "$(date +'%Y-%m-%d %H:%M:%S %Z') [$TEST] $@" | awk '{printf $0 " "}'
    echo
}

function do_dig {
    IP=$1
    shift
    # 1 second is the minimum supported timeout by dig
    CMD=(dig +noall +answer +stats +tries=1 +time=1 "$@")
    OUTPUT=$(${CMD[@]})
    RESULT=$?
    if [ $RESULT != 0 ]; then
        do_log "${CMD[@]} failed ($RESULT). DNS server unavailable? -> $OUTPUT"
    else
        echo $OUTPUT | grep -q "IN A $IP"
        if [ $? != 0 ]; then
            do_log "${CMD[@]} mismatch. Expected: IN A $IP -> $OUTPUT"
        fi
    fi
}

function do_getent {
    IP=$1
    shift
    CMD=(getent hosts "$@")
    OUTPUT=$(${CMD[@]})
    RESULT=$?
    if [ $RESULT != 0 ]; then
        do_log "${CMD[@]} failed ($RESULT). (Could be unknown host or failure to reach DNS server.) -> $OUTPUT"
    else
        echo $OUTPUT | grep -q $1
        if [ $? != 0 ]; then
            do_log "${CMD[@]} mismatch. Expected $IP -> $OUTPUT"
        fi
    fi
}

function do_test_every_host {
    SERVER=$1
    STAMP2=$SECONDS
    I2=0
    for TEST_LINE in "${HOST_DATA[@]}"; do
        read -r -a TEST_ARRAY <<< "$TEST_LINE"
        IP=${TEST_ARRAY[0]}
        HOST=${TEST_ARRAY[1]}
        if [ "$MODE" == "dig" ]; then
            do_dig $IP $HOST $SERVER
        elif [ "$MODE" == "getent" ]; then
            # gentent test only possible against default resolver
            if [ "$SERVER" == "" ]; then
                do_getent $IP $HOST
            else
                do_log "Cannot run getent tests against explicitly specified DNS server $SERVER."
                exit 1
            fi
        else
            do_log "Unknown test mode $MODE."
            exit 1
        fi
        I2=$((I2+1))
        if (( $STAMP2 != $SECONDS || $I2 >= $QPS )); then
            # Second has elapsed or we have done all the work we want to this second.
            # Await next second. Or no-op if we're already behind
            while (( $STAMP2 == $SECONDS )); do
                sleep 0.01
            done
            # A new second has begun; reset counters
            STAMP2=$SECONDS
            I2=0
        fi
    done;
}

function do_loop {
    I=0
    I_PREVIOUS=0
    STAMP=$SECONDS
    while true; do
        if (( $SECONDS - $STAMP > 60 )); then
            do_log "Heart beat. $I iterations completed $(( ($I - $I_PREVIOUS) * ${#HOST_DATA[@]} / ($SECONDS - $STAMP) )) QPS."
            STAMP=$SECONDS
            I_PREVIOUS=$I
        fi
        for SERVER in "${SERVERS[@]}"; do
            if [ "$SERVER" == "" ]; then
                do_test_every_host
            else
                do_test_every_host "@$SERVER"
            fi
        done;
        I=$((I+1))
    done;
}

yum install -q -y bind-utils
readarray HOST_DATA < $(dirname $0)/host-data
TEST=$1
QPS=$2
if [ "$TEST" == "dig_kubedns" ]; then
    SERVERS=( "" )
    MODE=dig
    do_log "Beginning DNS $MODE tests (kubedns). (${#HOST_DATA[@]} test lines; $QPS queries per second target)"
elif [ "$TEST" == "dig_external" ]; then
    # TODO: parameterize for other data centers
    SERVERS=(
        $(dig dig +noall +short "ops0-ns1-1-prd.eng.sfdc.net")
        $(dig dig +noall +short "ops0-ns1-2-prd.eng.sfdc.net")
        $(dig dig +noall +short "ops0-ns4-1-prd.eng.sfdc.net")
    )
    MODE=dig
    do_log "Beginning DNS $MODE tests (${#SERVERS[@]} external DNS servers). (${#HOST_DATA[@]} test lines; $QPS queries per second target)"
elif [ "$TEST" == "getent" ]; then
    SERVERS=( "" )
    MODE=getent
    do_log "Beginning DNS $MODE tests (kubedns). (${#HOST_DATA[@]} test lines; $QPS queries per second target)"
else
    do_log "Must specify TEST: dig_kubedns | dig_external | getent"
    exit 1
fi
do_loop
