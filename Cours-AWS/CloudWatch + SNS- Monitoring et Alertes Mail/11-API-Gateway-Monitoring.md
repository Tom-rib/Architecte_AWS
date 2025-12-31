# API Gateway Monitoring 🔗

Monitorer vos APIs REST.

---

## Métriques

```
4XXError
├─ Client errors (Bad Request, Unauthorized)
└─ Alarme: > 5%

5XXError
├─ Server errors (Lambda crash, timeout)
└─ Alarme: > 1%

Latency (ms)
├─ Response time
└─ Alarme: > 1000ms

Count
├─ Total requests
└─ Detecter traffic drops

IntegrationLatency
├─ Lambda execution time
└─ vs total latency
```

---

## Log Requests (Optionnel)

Enable CloudWatch Logs:

```
1. API Gateway > Stages > Logs
2. Enable CloudWatch Logs
3. Select Log Group: /aws/apigateway/api-name
4. Full request log (verbose)
```

### Coûts

0.50€ / GB logs

---

## Best Practices

- Monitorer 5XX errors (critical)
- Check latency trend
- Alarme response times
- Review error patterns

