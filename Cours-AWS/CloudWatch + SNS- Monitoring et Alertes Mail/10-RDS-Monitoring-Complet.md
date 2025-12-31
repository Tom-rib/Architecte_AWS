# RDS Monitoring 🗄️

Monitorer bases de données.

---

## Métriques (Gratuites)

```
DatabaseConnections
├─ Connexions actives
└─ Alarme: > 80% max

CPUUtilization (%)
├─ CPU database
└─ Alarme: > 80%

ReadLatency / WriteLatency (ms)
├─ Query response time
└─ Alarme: > 100ms

ReadThroughput / WriteThroughput
├─ MB/sec
└─ Alarme: Drop soudaine

FailedSQLServerAgentJobsCount
├─ Erreurs SQL
└─ Alarme: > 5
```

---

## Enhanced Monitoring

Avec agent RDS:

```
OS metrics
├─ RAM usage
├─ I/O activity
├─ Processes
└─ Locks
```

### Configurer

```
1. RDS Console > Modify DB Instance
2. Enable Enhanced Monitoring
3. Select Granularity (60 sec)
4. Select Monitoring Role
```

### Coûts

0.02€ / instance / hour

---

## Best Practices

- Monitorer connections
- Check latency regularly
- Alarme failed queries
- Review slow logs

