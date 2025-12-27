# EC2 Monitoring 🖥️

Monitorer instances EC2.

---

## Métriques Standard (Gratuites)

```
CPUUtilization (%)
├─ Attention: > 80%
└─ Alarme recommandée

NetworkIn / NetworkOut (bytes)
├─ Volumes réseau
└─ Détecter anomalies

DiskReadOps / DiskWriteOps
├─ I/O operations
└─ Détecter disque plein

StatusCheckFailed
├─ Instance health
└─ Alarme: > 0
```

---

## Enhanced Monitoring (Payant)

Besoin agent CloudWatch:

```
RAM utilization
Swap
Disk space
Process list
Custom metrics
```

### Installer Agent

```bash
wget https://s3.amazonaws.com/amazoncloudwatch-agent/...
sudo ./install.sh
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl ...
```

### Coûts

- Agent install/mois: 3.50€
- Per metric: 0.10€ / mois

---

## Best Practices

- Alarme CPU > 80%
- Alarme Disk > 80%
- Dashboard par instance group
- Review monthly

