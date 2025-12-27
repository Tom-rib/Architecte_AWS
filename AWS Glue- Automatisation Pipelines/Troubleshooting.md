# Troubleshooting AWS Glue 🐛

Solutions aux problèmes courants.

---

## Crawler

### Crawler runs mais aucune table créée

**Causes**:
- Source vide (pas de fichiers)
- Mauvais chemin S3
- Include patterns trop restrictif
- Permissions IAM insuffisantes

**Solutions**:
```bash
# Vérifier fichiers existent
aws s3 ls s3://mybucket/customers/

# Vérifier include patterns
# Modifier: *.csv → * (plus large)

# Vérifier IAM permissions
# Role doit avoir s3:GetObject, s3:ListBucket
```

### Types détectés incorrectement

**Cause**: Données ambigues

**Solution**:
1. Vérifier données source
2. Augmenter crawler sample size
3. Éditer schéma manuellement après crawl

---

## Job

### Job timeout (> 2880 min)

**Cause**: Données trop grandes, code inefficace

**Solutions**:
- Augmenter DPU allocation
- Optimiser code (filter early, partition)
- Partitionner source data
- Utiliser Parquet au lieu CSV

### OutOfMemory (OOM)

**Cause**: Pas assez de RAM

**Solutions**:
- Augmenter DPU (G.1X → G.2X)
- Augmenter nombre de workers
- Optimiser code (pas de collect to driver)
- Utiliser partitions

### Job slow

**Cause**: Mauvaise allocation resources

**Solutions**:
- Monitor CloudWatch metrics
- Augmenter DPU si CPU < 50%
- Profile avec spark.eventLog
- Optimiser partitions

---

## S3

### Permission denied reading S3

**Cause**: IAM role missing s3:GetObject

**Solution**:
```json
{
  "Effect": "Allow",
  "Action": ["s3:GetObject"],
  "Resource": "arn:aws:s3:::mybucket/*"
}
```

### Parquet schema mismatch

**Cause**: Schéma changer entre exécutions

**Solution**:
- Re-run crawler pour mettre à jour
- Vérifier données source consistent

---

## General

### How to debug?

```bash
# 1. Voir crawler logs
aws logs tail /aws-glue/crawlers/NAME

# 2. Voir job logs
aws logs tail /aws-glue/jobs/NAME

# 3. Check metrics CloudWatch
# CloudWatch > Metrics > Glue > Jobs

# 4. View job run details
aws glue get-job-run --job-name NAME --run-id RUNID
```

---

