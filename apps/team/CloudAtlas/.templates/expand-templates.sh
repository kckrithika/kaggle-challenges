# expand topomaster template
m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-dfw-dir1-1 -D__COUNT__=1 < manifest-ds.yaml > ../shared0-samminionatlasdir1-1-dfw/manifest.yaml
m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-dfw-dir -D__COUNT__=2 < manifest-ds.yaml > ../shared0-samminionatlasdir-dfw/manifest.yaml

# expand ds template
for kingdom in phx iad ord frf par ukb hnd; do
        m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-${kingdom}-dir -D__COUNT__=3 < manifest-ds.yaml > ../shared0-samminionatlasdir-${kingdom}/manifest.yaml
done

# expand service templates
for kingdom in dfw phx iad ord frf par ukb hnd; do
        m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-${kingdom}-service -D__COUNT__=3 < manifest-service.yaml > ../shared0-samminionatlasservice-${kingdom}/manifest.yaml
done
