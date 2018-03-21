# expand topomaster template
m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-dfw-dir1-1 -D__COUNT__=1 < manifest-ds.yaml > ../shared0-samminionatlasdir1-1-dfw/manifest.yaml
m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-dfw-dir -D__COUNT__=2 < manifest-ds.yaml > ../shared0-samminionatlasdir-dfw/manifest.yaml

# expand ds template
for kingdom in phx iad ord frf par; do
        m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-${kingdom}-dir -D__COUNT__=3 < manifest-ds.yaml > ../shared0-samminionatlasdir-${kingdom}/manifest.yaml
done

# expand proxy template
for kingdom in dfw phx iad ord frf par; do
        m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-${kingdom}-fe < manifest-proxy.yaml > ../shared0-samminionatlasfe-${kingdom}/manifest.yaml
done
