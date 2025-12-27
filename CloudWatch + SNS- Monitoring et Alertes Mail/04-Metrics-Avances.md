# CloudWatch Metrics Avancées 📊

Métriques personnalisées, agrégations, math.

---

## Custom Metrics

Envoyer vos propres métriques.

### Python Example

```python
import boto3

cloudwatch = boto3.client('cloudwatch')

cloudwatch.put_metric_data(
    Namespace='MyApp',
    MetricData=[
        {
            'MetricName': 'ActiveUsers',
            'Value': 150,
            'Unit': 'Count',
            'Timestamp': datetime.now()
        }
    ]
)
```

### Coûts

- 50 first/mois GRATUIT
- Après: 0.30€ / metric / mois

---

## Metric Math

Combiner plusieurs métriques.

### Exemples

```
Error Rate = (Errors / Invocations) × 100

Expression:
(m1 / m2) × 100

m1 = Errors Sum
m2 = Invocations Sum
```

---

## Statistiques

Average, Maximum, Minimum, Sum, SampleCount, pNN.NN

Voir 01-CloudWatch-Concepts-Complets.md

---

## Dimensions

Filtrer métriques par dimensions.

```
Metric: CPUUtilization
Dimensions:
├─ InstanceId: i-1234567890
├─ ImageId: ami-0123456789
└─ InstanceType: t2.medium

Query:
CPUUtilization for InstanceId=i-1234567890
```

