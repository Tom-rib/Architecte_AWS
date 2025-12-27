# CLI Commands - Référence complète 💻

Toutes les commandes AWS CLI pour S3.

---

## 📌 Configuration

```bash
# Configurer AWS CLI
aws configure
# Entrez :
# AWS Access Key ID: YOUR_KEY
# AWS Secret Access Key: YOUR_SECRET
# Default region: eu-west-3
# Default output format: json
```

---

## 🪣 BUCKETS

### Créer Bucket

```bash
aws s3api create-bucket \
  --bucket mon-bucket \
  --region eu-west-3 \
  --create-bucket-configuration LocationConstraint=eu-west-3
```

### Lister Buckets

```bash
aws s3 ls
# ou
aws s3api list-buckets
```

### Voir infos Bucket

```bash
aws s3api head-bucket --bucket mon-bucket
```

### Ajouter Tags au Bucket

```bash
aws s3api put-bucket-tagging \
  --bucket mon-bucket \
  --tagging 'TagSet=[{Key=Environment,Value=prod}]'
```

### Supprimer Bucket (vide)

```bash
aws s3 rb s3://mon-bucket
```

### Supprimer Bucket (avec fichiers)

```bash
aws s3 rm s3://mon-bucket --recursive
aws s3 rb s3://mon-bucket
```

---

## 📤 UPLOAD/DOWNLOAD

### Uploader un fichier

```bash
aws s3 cp mon-fichier.txt s3://mon-bucket/
aws s3 cp mon-fichier.txt s3://mon-bucket/dossier/
```

### Uploader un dossier

```bash
aws s3 cp mon-dossier/ s3://mon-bucket/ --recursive
```

### Télécharger un fichier

```bash
aws s3 cp s3://mon-bucket/mon-fichier.txt .
```

### Télécharger un dossier

```bash
aws s3 cp s3://mon-bucket/dossier/ ./dossier/ --recursive
```

### Synchroniser (upload)

```bash
aws s3 sync mon-dossier/ s3://mon-bucket/ --recursive
```

### Synchroniser (download)

```bash
aws s3 sync s3://mon-bucket/ ./mon-dossier/
```

### Synchroniser bidirectionnel (avec delete)

```bash
aws s3 sync s3://mon-bucket/ ./mon-dossier/ --delete
```

---

## 📋 LISTER FICHIERS

### Lister fichiers d'un Bucket

```bash
aws s3 ls s3://mon-bucket/
```

### Lister avec préfixe

```bash
aws s3 ls s3://mon-bucket/dossier/
```

### Lister avec plus de détails

```bash
aws s3api list-objects-v2 --bucket mon-bucket
```

### Lister tous les fichiers (paginer)

```bash
aws s3api list-objects-v2 \
  --bucket mon-bucket \
  --max-items 1000
```

---

## 🗑️ SUPPRIMER

### Supprimer un fichier

```bash
aws s3 rm s3://mon-bucket/mon-fichier.txt
```

### Supprimer avec pattern

```bash
aws s3 rm s3://mon-bucket/ --recursive --exclude "*" --include "*.log"
```

### Supprimer tous les fichiers

```bash
aws s3 rm s3://mon-bucket/ --recursive
```

---

## 🔐 PERMISSIONS

### Ajouter Bucket Policy

```bash
aws s3api put-bucket-policy \
  --bucket mon-bucket \
  --policy file://policy.json
```

### Voir Bucket Policy

```bash
aws s3api get-bucket-policy --bucket mon-bucket
```

### Supprimer Bucket Policy

```bash
aws s3api delete-bucket-policy --bucket mon-bucket
```

### Générer Presigned URL (1 heure)

```bash
aws s3 presign s3://mon-bucket/mon-fichier.txt \
  --expires-in 3600
```

### Générer Presigned URL (7 jours)

```bash
aws s3 presign s3://mon-bucket/mon-fichier.txt \
  --expires-in 604800
```

---

## 🌐 STATIC WEBSITE

### Activer Static Website

```bash
aws s3api put-bucket-website \
  --bucket mon-bucket \
  --website-configuration '{
    "IndexDocument": {"Suffix": "index.html"},
    "ErrorDocument": {"Key": "error.html"}
  }'
```

### Voir config Website

```bash
aws s3api get-bucket-website --bucket mon-bucket
```

### Supprimer Static Website

```bash
aws s3api delete-bucket-website --bucket mon-bucket
```

---

## 📜 VERSIONING

### Activer Versioning

```bash
aws s3api put-bucket-versioning \
  --bucket mon-bucket \
  --versioning-configuration Status=Enabled
```

### Voir Versioning Status

```bash
aws s3api get-bucket-versioning --bucket mon-bucket
```

### Lister Versions

```bash
aws s3api list-object-versions --bucket mon-bucket
```

### Restaurer Version

```bash
aws s3api copy-object \
  --bucket mon-bucket \
  --copy-source mon-bucket/fichier.txt?versionId=ABC123 \
  --key fichier.txt
```

### Supprimer Version Spécifique

```bash
aws s3api delete-object \
  --bucket mon-bucket \
  --key fichier.txt \
  --version-id ABC123
```

---

## ♻️ LIFECYCLE

### Ajouter Lifecycle Policy

```bash
aws s3api put-bucket-lifecycle-configuration \
  --bucket mon-bucket \
  --lifecycle-configuration file://lifecycle.json
```

### Voir Lifecycle Policy

```bash
aws s3api get-bucket-lifecycle-configuration --bucket mon-bucket
```

### Supprimer Lifecycle Policy

```bash
aws s3api delete-bucket-lifecycle --bucket mon-bucket
```

---

## 🌍 CLOUDFRONT

### Créer Distribution

```bash
aws cloudfront create-distribution \
  --distribution-config file://config.json
```

### Lister Distributions

```bash
aws cloudfront list-distributions
```

### Créer Invalidation

```bash
aws cloudfront create-invalidation \
  --distribution-id E123ABC \
  --paths "/*"
```

### Voir Invalidations

```bash
aws cloudfront list-invalidations --distribution-id E123ABC
```

---

## 🔄 REPLICATION

### Créer Replication Rule

```bash
aws s3api put-bucket-replication \
  --bucket source-bucket \
  --replication-configuration file://replication.json
```

### Lister Replication Rules

```bash
aws s3api get-bucket-replication --bucket source-bucket
```

### Supprimer Replication

```bash
aws s3api delete-bucket-replication --bucket source-bucket
```

---

## 🚪 ACCESS POINTS

### Créer Access Point

```bash
aws s3api create-access-point \
  --bucket mon-bucket \
  --name app1-access-point \
  --region eu-west-3
```

### Lister Access Points

```bash
aws s3api list-access-points --bucket mon-bucket
```

### Ajouter Policy à Access Point

```bash
aws s3api put-access-point-policy \
  --name app1-access-point \
  --policy file://policy.json
```

### Supprimer Access Point

```bash
aws s3api delete-access-point \
  --name app1-access-point
```

---

## 🔒 OBJECT LOCK

### Uploader avec Object Lock

```bash
aws s3api put-object \
  --bucket mon-bucket \
  --key mon-fichier.txt \
  --body mon-fichier.txt \
  --object-lock-mode COMPLIANCE \
  --object-lock-retain-until-date 2025-12-31T00:00:00Z
```

### Voir Object Lock

```bash
aws s3api get-object-retention \
  --bucket mon-bucket \
  --key mon-fichier.txt
```

### Ajouter Legal Hold

```bash
aws s3api put-object-legal-hold \
  --bucket mon-bucket \
  --key mon-fichier.txt \
  --legal-hold Status=ON
```

---

## 📝 SERVER LOGGING

### Activer Server Logging

```bash
aws s3api put-bucket-logging \
  --bucket mon-bucket \
  --bucket-logging-status '{
    "LoggingEnabled": {
      "TargetBucket": "mon-bucket-logs",
      "TargetPrefix": "logs/"
    }
  }'
```

### Voir Server Logging

```bash
aws s3api get-bucket-logging --bucket mon-bucket
```

### Désactiver Server Logging

```bash
aws s3api put-bucket-logging \
  --bucket mon-bucket \
  --bucket-logging-status '{}'
```

---

## 🚀 TRANSFER ACCELERATION

### Activer Transfer Acceleration

```bash
aws s3api put-bucket-accelerate-configuration \
  --bucket mon-bucket \
  --accelerate-configuration Status=Enabled
```

### Vérifier statut

```bash
aws s3api get-bucket-accelerate-configuration --bucket mon-bucket
```

### Upload avec accélération

```bash
aws s3 cp mon-gros-fichier.zip s3://bucket/ \
  --region eu-west-3 \
  --use-accelerate-endpoint
```

---

## 🧠 INTELLIGENT-TIERING

### Upload en Intelligent-Tiering

```bash
aws s3api put-object \
  --bucket mon-bucket \
  --key mon-fichier.txt \
  --body mon-fichier.txt \
  --storage-class INTELLIGENT_TIERING
```

### Lister objets par storage class

```bash
aws s3api list-objects-v2 --bucket mon-bucket
# Filter result par StorageClass
```

---

## 🌐 CORS

### Ajouter CORS

```bash
aws s3api put-bucket-cors \
  --bucket mon-bucket \
  --cors-configuration file://cors.json
```

### Voir CORS

```bash
aws s3api get-bucket-cors --bucket mon-bucket
```

### Supprimer CORS

```bash
aws s3api delete-bucket-cors --bucket mon-bucket
```

---

## 📢 EVENT NOTIFICATIONS

### Ajouter Event pour SNS

```bash
aws s3api put-bucket-notification-configuration \
  --bucket mon-bucket \
  --notification-configuration '{
    "TopicConfigurations": [
      {
        "TopicArn": "arn:aws:sns:eu-west-3:123456789:mon-topic",
        "Events": ["s3:ObjectCreated:*"]
      }
    ]
  }'
```

### Ajouter Event pour Lambda

```bash
aws s3api put-bucket-notification-configuration \
  --bucket mon-bucket \
  --notification-configuration '{
    "LambdaFunctionConfigurations": [
      {
        "LambdaFunctionArn": "arn:aws:lambda:...",
        "Events": ["s3:ObjectCreated:*"]
      }
    ]
  }'
```

### Voir Notifications

```bash
aws s3api get-bucket-notification-configuration --bucket mon-bucket
```

---

## 📊 METRICS & MONITORING

### Créer monitoring rule

```bash
aws s3api put-bucket-metrics-configuration \
  --bucket mon-bucket \
  --id EntireBucket \
  --metrics-configuration Id=EntireBucket,Filter={Prefix=}
```

### Voir métriques (CloudWatch)

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name NumberOfObjects \
  --dimensions Name=BucketName,Value=mon-bucket \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Average
```

### Créer alarme

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name bucket-size-alert \
  --metric-name BucketSizeBytes \
  --namespace AWS/S3 \
  --statistic Average \
  --period 86400 \
  --threshold 52428800 \
  --comparison-operator GreaterThanThreshold
```

---

## 💡 TIPS

### Copy avec permissions publiques

```bash
aws s3 cp mon-fichier.txt s3://mon-bucket/ --acl public-read
```

### Copy avec métadonnées

```bash
aws s3 cp mon-fichier.txt s3://mon-bucket/ \
  --metadata "author=tom,version=1"
```

### Filtrer fichiers

```bash
aws s3 ls s3://mon-bucket/ --recursive | grep ".jpg"
```

### Copier entre buckets

```bash
aws s3 cp s3://source-bucket/fichier.txt s3://dest-bucket/
```

### Sync avec exclusions

```bash
aws s3 sync . s3://mon-bucket/ \
  --exclude "*.tmp" \
  --exclude ".git/*"
```

---

[⬅️ Retour](./README.md)
