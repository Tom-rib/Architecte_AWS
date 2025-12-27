# IAM & Sécurité Glue 🔒

Permissions et contrôle d'accès pour Glue.

---

## IAM Role pour Glue

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::mybucket/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "glue:GetDatabase",
        "glue:GetTable",
        "glue:GetPartitions"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
```

---

## Encryption

```
S3 Server-Side Encryption:
├─ SSE-S3 (default)
├─ SSE-KMS (custom key)
└─ Glue logs encrypted with SSE-S3
```

---

## Best Practices

```
✅ Least privilege
├─ Only S3 paths needed
├─ Only actions needed
└─ Not account-wide access

✅ Use IAM roles
├─ Never store credentials
├─ Rotate access keys
└─ Monitor CloudTrail
```

---

