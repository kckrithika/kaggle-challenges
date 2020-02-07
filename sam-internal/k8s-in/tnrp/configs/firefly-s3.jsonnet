{
  s3: {
    enabled: true,
    "s3-access-key-id": "${s3AccessKeyId#FromSecretService}",
    "s3-secret-access-key": "${s3SecretAccessKey#FromSecretService}",
    "s3-grid-configs": [
      {
        "environment-type": "ffdev",
        "region": "us-east-2",
        "access-key-id": "${s3AccessKeyId#FromSecretService}",
        "secret-access-key": "${s3SecretAccessKey#FromSecretService}",
        "bucket-configs-by-type": {
          helm: [{"bucket-name": "sfcd-helm"},],
          terraform: [{"bucket-name": "sfcd-terraform"},],
          fcp: [{"bucket-name": "fcparchive"},],
        },
      },
      {
        "environment-type": "dev1",
        "region": "us-west-2",
        "access-key-id": "${dev1_service_firefly_key#FromSecretService}",
        "secret-access-key": "${dev1_service_firefly_secret#FromSecretService}",
        "role-arn": "${dev1RoleArn#FromSecretService}",
        "bucket-configs-by-type": {
          helm: [{"bucket-name": "dev-us-west-2-sfcd-helm-archive"},],
          terraform: [{"bucket-name": "dev-us-west-2-sfcd-terraform"},],
          fcp: [{"bucket-name": "dev-us-west-2-sfcd-fcp-archive"},],
        },
      },
      {
        "environment-type": "prod",
        "region": "us-east-2",
        "access-key-id": "${ESVC1_service_firefly_key#FromSecretService}",
        "secret-access-key": "${ESVC1_service_firefly_secret#FromSecretService}",
        "role-arn": "${prodRoleArn#FromSecretService}",
        "bucket-configs-by-type": {
          helm: [{"bucket-name": "esvc-us-east-2-sfcd-helm-archive"},],
          terraform: [{"bucket-name": "esvc-us-east-2-sfcd-terraform"},],
          fcp: [{"bucket-name": "esvc-us-east-2-sfcd-fcp-archive"},],
        },
      },
    ],
  }
}
