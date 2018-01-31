# expand ds template
for kingdom in dfw phx iad ord frf par; do
        for instance in 1-1 1-2 2-1; do
                m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-${kingdom}-dir${instance} < manifest-ds.yaml > ../shared0-samminionatlasdir${instance}-${kingdom}/manifest.yaml
        done
done

# expand proxy template
for kingdom in dfw phx iad ord frf; do
        for instance in 1-1 2-1; do
                m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-${kingdom}-fe${instance} < manifest-proxy.yaml > ../shared0-samminionatlasfe${instance}-${kingdom}/manifest.yaml
        done
done
