#!/bin/bash
SRC=/systemd-files
DEST=/host/etc/systemd/system
CHANGES=false
for f in flowsnake.service flowsnake-start.sh flowsnake-stop.sh; do
    if ! [[ -e ${DEST}/${f} ]] || ! diff ${SRC}/${f} ${DEST}/${f}; then
        echo "$(date) Updating ${DEST}/${f} to SHA-1 $(sha1sum ${SRC}/${f} | awk '{print $1}')"
        cp --force ${SRC}/${f} ${DEST}/
        CHANGES=true
    fi
done
if [[ ${CHANGES} == 'true' ]]; then
    echo "$(date) flowsnake.service changed; systemd reload"
    chroot /host systemctl daemon-reload
else
    echo "${date} flowsnake.service unchanged."
fi
# Our old version of systemd does not support listing which things are enabled.
# So just do it unconditionally.
chroot /host systemctl enable flowsnake
chroot /host systemctl start flowsnake
chroot /host systemctl status flowsnake
# DaemonSet restart policy is Always, so after sleep we exit and pod gets recreated.
# No need to run this very frequently. But to make updating easier, detect
# when there were changes and exit early.
SLEEP=14400
START_TIME=$(date '+%s')
echo "$(date) Waiting for $SLEEP seconds before pod restart"
while true; do
    for f in flowsnake.service flowsnake-start.sh flowsnake-stop.sh; do
        if ! diff ${SRC}/${f} ${DEST}/${f}; then
            echo "$(date) Detected change in ${f}. Exiting early."
            exit 0
        fi
    done
    if (( $(date '+%s') - START_TIME >= SLEEP )); then
        exit 0
    fi
    sleep 10
done
