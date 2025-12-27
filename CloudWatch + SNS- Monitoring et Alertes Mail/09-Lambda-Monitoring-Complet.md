# Lambda Monitoring 🚀

Monitorer fonctions Lambda.

---

## Métriques (Gratuites)

```
Invocations
├─ Nombre total appels
└─ Alarme: Traffic check

Duration (ms)
├─ Temps exécution
└─ Alarme: > 5000ms

Errors
├─ Nombre d'erreurs
└─ Alarme: > 1

Throttles
├─ Dépassement concurrence
└─ Alarme: > 0 (CRITIQUE)

ConcurrentExecutions
├─ Fonctions parallèles actuelles
└─ Limite: 1000 default
```

---

## CloudWatch Logs Automatic

Tous les logs Lambda vont dans CloudWatch.

```
Log Group: /aws/lambda/function-name
Log Stream: 2025/12/27/[$LATEST]abc123

Logs contiennent:
├─ print() statements
├─ logger.info() / logger.error()
├─ Duration & memory
└─ Errors & stack traces
```

---

## Best Practices

- Logguer structuré (JSON)
- Error handling
- Monitoring errors > 1%
- Alarme throttles IMMÉDIATE

