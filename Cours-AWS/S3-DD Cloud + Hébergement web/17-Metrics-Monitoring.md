# Metrics & Monitoring - Surveillance CloudWatch 📊

Monitorer santé et performance du bucket S3.

---

## 🎯 À quoi ça sert ?

- Dashboard métriques
- Alertes (CPU, latence)
- Performance (requêtes/sec)
- Troubleshooting (4xx, 5xx errors)

---

## 📊 Métriques clés

| Métrique | Signification | Unité |
|----------|---|---|
| **NumberOfObjects** | Nb fichiers | count |
| **BucketSizeBytes** | Taille bucket | bytes |
| **AllRequests** | Toutes requêtes | count |
| **GetRequests** | Downloads | count |
| **PutRequests** | Uploads | count |
| **4xxErrors** | Client errors | count |
| **5xxErrors** | Server errors | count |
| **FirstByteLatency** | Latence première donnée | ms |
| **TotalRequestLatency** | Latence totale | ms |

---

## 🖼️ DASHBOARD AWS

### Activer RequestMetrics (payant)

```
1. Bucket > Properties > Request metrics
2. Create monitoring rule
3. Filter : All objects (ou prefix)
4. Create rule ✓
5. Attendre 15-20 min pour données
⚠️ Coûteux : 0.75€/règle/mois
```

### Voir métriques dans CloudWatch

```
CloudWatch > S3 metrics
- Dimensions : Bucket, Filter
- Graphiques : sélectionnez métriques
- Historique : jusqu'à 15 mois
```

### Créer Alarme

```
1. CloudWatch > Alarms > Create alarm
2. Metric : S3 BucketSizeBytes
3. Statistic : Average
4. Period : 1 day
5. Threshold : > 50 GB
6. Action : SNS notification
7. Create ✓
```

---

## 💻 CLI

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
  --comparison-operator GreaterThanThreshold \
  --alarm-actions arn:aws:sns:...
```

### Lister métriques

```bash
aws cloudwatch list-metrics --namespace AWS/S3
```

---

## 📌 NOTES

- **Basic Metrics** : gratuit (1 par jour, avec délai)
- **Request Metrics** : payant (0.75€/règle/mois)
- **Historique** : 1 mois (basic), 15 mois (avec request metrics)
- **Latency** : first byte = time to first byte, total = end-to-end

---

## 💡 EXEMPLE MONITORING

```
1. Bucket > Properties > Request metrics > Enable
2. CloudWatch > Alarms
3. Create alarme si :
   - 4xxErrors > 100 (bad requests)
   - 5xxErrors > 10 (server errors)
   - TotalRequestLatency > 500ms (lent)
4. SNS pour alert
```

---

[⬅️ Retour](./README.md)
