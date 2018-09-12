local configs = import "config.jsonnet";

std.prune({
"cert_age.sh": "#!/bin/sh;
                kubedns_output=kubedns
                wget -q --timeout=30 http://localhost:10054/healthcheck/kubedns  -O $kubedns_output
                if [ $? -eq 0 ]; then
                  cat $kubedns_output | grep -i 'true'
                  if [ $? -ne 0 ]; then
                    echo \"KubeDns is not healthy. Fail liveness check\"
                    exit 1
                  fi
                else
                  echo \"KubeDns is not healthy(couldnot reach kubedns). Fail liveness check\"
                fi

                #Find how long the kube-dns process has been running
                PROC_UPTIME_MIN_SEC=$(ps -o etime= | head -n 1);

                #Convert the age into seconds
                PROC_UPTIME=$(( $(( $(echo $PROC_UPTIME_MIN_SEC | cut -d: -f1) * 60 )) + $(echo $PROC_UPTIME_MIN_SEC | cut -d: -f2) ));

                #Check when the cert was installed
                CERT_AGE=$(echo $((($(date +%s) - $(date +%s -r /etc/pki_service/kubernetes/chain-client.pem)))));

                DIFF=$(( PROC_UPTIME - CERT_AGE ));

                expr $DIFF \\< 60 && echo \"Certs are older than process.\" && exit 0; echo \"Process is older than certs, failing liveness check\" && exit 1;",
})
