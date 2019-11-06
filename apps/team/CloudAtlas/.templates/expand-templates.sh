# expand topomaster template
m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-dfw-dir1-1 -D__COUNT__=1 -D__KINGDOM__=dfw -D__AWS_BACKUP_SECRET_SERVICE_VAULT__=cloud-atlas-prod-na-1 -D__AWS_BACKUP_S3_BUCKET__=ccp-prod-cloud-atlas-na-1-backup-us-east-1 < manifest-ds.yaml > ../shared0-samminionatlasdir1-1-dfw/manifest.yaml

m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-dfw-dir -D__COUNT__=2 -D__KINGDOM__=dfw -D__AWS_BACKUP_SECRET_SERVICE_VAULT__=cloud-atlas-prod-na-1 -D__AWS_BACKUP_S3_BUCKET__=ccp-prod-cloud-atlas-na-1-backup-us-east-1 < manifest-ds.yaml > ../shared0-samminionatlasdir-dfw/manifest.yaml

# expand ds template - separating kingdoms as AWS parameters are different
for kingdom in phx iad ord; do
        m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-${kingdom}-dir -D__COUNT__=3 -D__KINGDOM__=${kingdom} -D__AWS_BACKUP_SECRET_SERVICE_VAULT__=cloud-atlas-prod-na-1 -D__AWS_BACKUP_S3_BUCKET__=ccp-prod-cloud-atlas-na-1-backup-us-east-1 < manifest-ds.yaml > ../shared0-samminionatlasdir-${kingdom}/manifest.yaml
done

for kingdom in frf par; do
        m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-${kingdom}-dir -D__COUNT__=3 -D__KINGDOM__=${kingdom} -D__AWS_BACKUP_SECRET_SERVICE_VAULT__=cloud-atlas-prod-eu-1 -D__AWS_BACKUP_S3_BUCKET__=ccp-prod-cloud-atlas-eu-1-backup-eu-central-1 < manifest-ds.yaml > ../shared0-samminionatlasdir-${kingdom}/manifest.yaml
done

for kingdom in hnd ukb; do
        m4 -D__MANIFEST_FUNCTION_NAME__=cloudatlas-${kingdom}-dir -D__COUNT__=3 -D__KINGDOM__=${kingdom} -D__AWS_BACKUP_SECRET_SERVICE_VAULT__=cloud-atlas-prod-ap-1 -D__AWS_BACKUP_S3_BUCKET__=ccp-prod-cloud-atlas-ap-1-backup-ap-northeast-1 < manifest-ds.yaml > ../shared0-samminionatlasdir-${kingdom}/manifest.yaml
done
