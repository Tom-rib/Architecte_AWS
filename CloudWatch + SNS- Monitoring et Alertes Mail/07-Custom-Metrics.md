# Custom Metrics - Envoyer vos Métriques 🎯

Monitorer n'importe quoi.

---

## Quand Utiliser

- Nombre utilisateurs connectés
- Transactions par seconde
- Queue length
- Custom business metrics

---

## Envoyer Métrique

### Python

```python
import boto3
from datetime import datetime

cloudwatch = boto3.client('cloudwatch')

cloudwatch.put_metric_data(
    Namespace='MyApplication',
    MetricData=[
        {
            'MetricName': 'TransactionsPerSecond',
            'Value': 42.5,
            'Unit': 'Count/Second',
            'Timestamp': datetime.utcnow(),
            'Dimensions': [
                {'Name': 'Environment', 'Value': 'production'},
                {'Name': 'Service', 'Value': 'payment'}
            ]
        }
    ]
)
```

### Coûts

- 50 first/mois: GRATUIT
- +0.30€ / metric / mois après

---

## Best Practices

- Batch requests (max 20/request)
- Use Dimensions pour filter
- Document metric meaning
- Monitor metric health

