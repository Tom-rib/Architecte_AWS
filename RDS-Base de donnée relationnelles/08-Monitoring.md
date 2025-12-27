# Monitoring - Métriques CloudWatch 📊

Surveiller santé et performance de votre BD.

---

## 🎯 À quoi ça sert ?

- CPU, mémoire, disque
- Connexions
- Performance requêtes
- Alertes

---

## 📊 Métriques clés

| Métrique | Signification | Normal |
|---|---|---|
| **CPUUtilization** | % CPU | < 80% |
| **DatabaseConnections** | Nb connexions | < max_connections |
| **FreeableMemory** | Mémoire libre | > 500 MB |
| **FreeStorageSpace** | Disque libre | > 10% |
| **ReadLatency** | Latence lecture | < 1ms |
| **WriteLatency** | Latence écriture | < 1ms |

---

## 🖼️ DASHBOARD AWS

### Voir métriques

```
1. RDS > Databases > my-database
2. Monitoring tab
3. CloudWatch metrics
```

### Créer alarme

```
1. CloudWatch > Alarms > Create alarm
2. Metric : RDS > DBInstanceIdentifier > CPUUtilization
3. Statistic : Average
4. Period : 5 minutes
5. Threshold : > 80%
6. Action : SNS notification
7. Create ✓
```

---

## 💻 CLI

### Voir métriques

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=my-database \
  --start-time 2024-12-24T00:00:00Z \
  --end-time 2024-12-26T00:00:00Z \
  --period 3600 \
  --statistics Average
```

---

## 📌 NOTES

- **Gratuit** : CloudWatch basic metrics
- **Enhanced Monitoring** : payant (0.02€/h)
- **Granularité** : 1 min ou 5 min

---

[⬅️ Retour](./README.md)
