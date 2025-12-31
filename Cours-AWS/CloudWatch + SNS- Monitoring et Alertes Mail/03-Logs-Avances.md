# CloudWatch Logs Avancés 📝

Voir 01-CloudWatch-Concepts-Complets.md pour détails complets sur les logs.

**Ici:** Requêtes avancées, filtrage, archivage.

---

## CloudWatch Logs Insights

### Syntaxe Basique

```
Voir tous les logs
fields @timestamp, @message

Filtrer erreurs
fields @timestamp, @message | filter @message like /ERROR/

Compter par heure
stats count() as errors by bin(1h)

Percentile latency
stats pct(@duration, 95) as p95

Logs de X minutes
fields @timestamp, @message | filter @timestamp > ago(30m)
```

### Exemples Concrets

**Lambda - Logs lents**
```
fields @timestamp, @duration
| filter @duration > 5000
| stats count() as slow_invocations
```

**API - Erreurs par endpoint**
```
fields @path, statusCode
| filter statusCode >= 400
| stats count() as errors by @path
```

**RDS - Queries longues**
```
fields @timestamp, queryTime
| filter queryTime > 1000
| stats max(queryTime) as max_time by bin(5m)
```

### Coûts

- 0.55€ / GB analysé
- 1ère requête/jour gratuite (1GB)

---

## Metric Filters

Créer alarmes depuis logs sans envoyer custom metrics.

```
Pattern: [ERROR]
Action: Incrémenter métrique ErrorCount
Alarme: ErrorCount > 5 → SNS Alert
```

### Créer Metric Filter

**CLI**

```bash
aws logs put-metric-filter \
  --log-group-name /aws/lambda/hello-api \
  --filter-name ErrorCount \
  --filter-pattern "[ERROR]" \
  --metric-transformations metricName=ErrorCount,metricNamespace=CustomMetrics,metricValue=1 \
  --region eu-west-3
```

---

## Rétention des Logs

### Réduire Coûts

```
Never (default) = TRÈS CHER
Changer à 7 jours = Moins cher

Calcul:
30 jours × 10GB = 300GB
0.50€/GB = 150€/mois

7 jours = 70GB = 35€/mois
```

### Archiver en S3

```
CloudWatch Logs (1 semaine)
  ↓
Subscription Filter
  ↓
S3 (1 an, moins cher)
```

---

## Log Groups Best Practices

- Nommer par service: `/aws/lambda/hello-api`
- Documenter rétention
- Archive ancien logs
- Supprimer groups inutilisés

