# Job 5 : CloudWatch + SNS - Surveillance et Alertes 📊

> Monitorer les ressources et recevoir des notifications

---

## 🎯 Objectif

Mettre en place une surveillance et des alertes pour une application AWS. Monitorer les ressources (CPU, mémoire) et recevoir des notifications lorsque des seuils sont dépassés.

---

## 📦 Ressources AWS Utilisées

| Service | Rôle |
|---------|------|
| CloudWatch | Monitoring, métriques, alarmes |
| SNS | Notifications (email, SMS) |
| EC2 | Ressource à monitorer |

---

## 💰 Coûts

| Service | Free Tier |
|---------|-----------|
| CloudWatch | 10 alarmes gratuites |
| SNS | 1000 notifications/mois |
| CloudWatch Logs | 5 GB gratuits |

✅ **Entièrement gratuit pour ce projet**

---

# Étape 1 : Créer un Topic SNS

## 🖥️ Dashboard

```
1. SNS → Topics → Create topic

2. Type : Standard

3. Name : ServerAlerts

4. Display name : Server Alerts (optionnel)

5. Create topic ✓

6. Notez l'ARN :
   arn:aws:sns:eu-west-3:123456789:ServerAlerts
```

## 💻 CLI

```bash
# Créer le topic SNS
TOPIC_ARN=$(aws sns create-topic \
  --name ServerAlerts \
  --query 'TopicArn' \
  --output text \
  --region eu-west-3)

echo "Topic ARN: $TOPIC_ARN"
```

---

# Étape 2 : S'abonner au Topic (Email)

## 🖥️ Dashboard

```
1. SNS → Topics → ServerAlerts

2. Create subscription

3. Protocol : Email

4. Endpoint : votre-email@example.com

5. Create subscription ✓

6. ⚠️ Vérifiez votre boîte email !
   - Cliquez sur "Confirm subscription"
   - Status doit passer à "Confirmed"
```

## 💻 CLI

```bash
# Créer l'abonnement email
aws sns subscribe \
  --topic-arn $TOPIC_ARN \
  --protocol email \
  --notification-endpoint votre-email@example.com \
  --region eu-west-3

# ⚠️ Confirmez via l'email reçu !
```

---

# Étape 3 : Créer un Dashboard CloudWatch

## 🖥️ Dashboard

```
1. CloudWatch → Dashboards → Create dashboard

2. Dashboard name : ServerMonitoring

3. Create dashboard ✓

4. Add widget → Line

5. Metrics → EC2 → Per-Instance Metrics

6. Sélectionnez votre instance → CPUUtilization

7. Create widget ✓

8. Répétez pour ajouter :
   - NetworkIn
   - NetworkOut
   - StatusCheckFailed

9. Save dashboard ✓
```

## 💻 CLI

```bash
# Créer un dashboard (JSON)
aws cloudwatch put-dashboard \
  --dashboard-name ServerMonitoring \
  --dashboard-body '{
    "widgets": [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "i-xxxxxxxxx"]
          ],
          "title": "CPU Utilization",
          "region": "eu-west-3"
        }
      }
    ]
  }' \
  --region eu-west-3
```

---

# Étape 4 : Créer une Alarme CloudWatch

## 🖥️ Dashboard

```
1. CloudWatch → Alarms → Create alarm

2. Select metric → EC2 → Per-Instance Metrics

3. Sélectionnez : CPUUtilization (votre instance)

4. Select metric ✓

5. Conditions :
   - Threshold type : Static
   - Whenever CPUUtilization is : Greater than
   - Threshold : 70
   - Period : 5 minutes
   - Datapoints to alarm : 2 out of 2

6. Next

7. Notification :
   - Alarm state trigger : In alarm
   - Select an existing SNS topic : ServerAlerts

8. Next

9. Alarm name : ec2-cpu-high

10. Alarm description : CPU > 70% pendant 10 minutes

11. Create alarm ✓
```

## 💻 CLI

```bash
# Créer l'alarme CPU
aws cloudwatch put-metric-alarm \
  --alarm-name ec2-cpu-high \
  --alarm-description "CPU > 70% pendant 10 minutes" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 70 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 2 \
  --dimensions Name=InstanceId,Value=i-xxxxxxxxx \
  --alarm-actions $TOPIC_ARN \
  --region eu-west-3
```

---

# Étape 5 : Créer d'autres alarmes utiles

## Alarme : Disque plein (> 80%)

### 🖥️ Dashboard

```
1. CloudWatch → Alarms → Create alarm

2. Select metric → CWAgent → DiskUsed (si CloudWatch Agent installé)
   OU EC2 → EBSVolumeUsed

3. Threshold : Greater than 80%

4. Notification : ServerAlerts

5. Name : ec2-disk-high
```

### 💻 CLI

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name ec2-disk-high \
  --alarm-description "Disk usage > 80%" \
  --metric-name disk_used_percent \
  --namespace CWAgent \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 2 \
  --dimensions Name=InstanceId,Value=i-xxxxxxxxx \
  --alarm-actions $TOPIC_ARN \
  --region eu-west-3
```

## Alarme : Instance down (Status Check Failed)

### 🖥️ Dashboard

```
1. CloudWatch → Alarms → Create alarm

2. Select metric → EC2 → Per-Instance Metrics

3. Sélectionnez : StatusCheckFailed

4. Threshold : Greater than 0

5. Period : 1 minute

6. Notification : ServerAlerts

7. Name : ec2-status-check-failed
```

### 💻 CLI

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name ec2-status-check-failed \
  --alarm-description "Instance status check failed" \
  --metric-name StatusCheckFailed \
  --namespace AWS/EC2 \
  --statistic Maximum \
  --period 60 \
  --threshold 0 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --dimensions Name=InstanceId,Value=i-xxxxxxxxx \
  --alarm-actions $TOPIC_ARN \
  --region eu-west-3
```

---

# Étape 6 : Tester les alarmes

## 🖥️ Dashboard - Forcer une alarme

```
1. CloudWatch → Alarms → ec2-cpu-high

2. Actions → Set alarm state → In alarm

3. Confirm ✓

4. Vérifiez votre email → Vous devez recevoir une notification

5. Remettez l'état normal :
   Actions → Set alarm state → OK
```

## 💻 CLI

```bash
# Forcer l'état ALARM
aws cloudwatch set-alarm-state \
  --alarm-name ec2-cpu-high \
  --state-value ALARM \
  --state-reason "Test manuel" \
  --region eu-west-3

# Vérifiez votre email !

# Remettre en OK
aws cloudwatch set-alarm-state \
  --alarm-name ec2-cpu-high \
  --state-value OK \
  --state-reason "Test terminé" \
  --region eu-west-3
```

## 💻 Test réel : Charger le CPU

```bash
# Se connecter à l'instance EC2
ssh -i aws_arch.pem admin@IP_PUBLIQUE

# Installer stress
sudo apt install stress -y

# Charger le CPU pendant 10 minutes
stress --cpu 2 --timeout 600

# Observer l'alarme se déclencher dans CloudWatch
# Et recevoir l'email !
```

---

# Étape 7 : Voir les métriques

## 🖥️ Dashboard

```
1. CloudWatch → Metrics → All metrics

2. EC2 → Per-Instance Metrics

3. Sélectionnez les métriques à visualiser :
   - CPUUtilization
   - NetworkIn
   - NetworkOut
   - DiskReadOps
   - DiskWriteOps

4. Ajustez la période (1h, 3h, 12h, 1d, etc.)
```

## 💻 CLI

```bash
# Récupérer les métriques CPU des dernières 3 heures
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-xxxxxxxxx \
  --start-time $(date -u -d '3 hours ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average \
  --region eu-west-3

# Lister toutes les alarmes
aws cloudwatch describe-alarms \
  --query 'MetricAlarms[*].[AlarmName,StateValue]' \
  --output table \
  --region eu-west-3
```

---

# Étape 8 : CloudWatch Logs

## Voir les logs de vos services

```
1. CloudWatch → Log groups

2. Groupes courants :
   - /aws/lambda/xxx → Logs Lambda
   - /var/log/messages → Logs système (si agent installé)
   - /aws/rds/xxx → Logs RDS
```

## 💻 CLI

```bash
# Lister les log groups
aws logs describe-log-groups \
  --query 'logGroups[*].logGroupName' \
  --region eu-west-3

# Voir les derniers logs
aws logs tail /aws/lambda/hello-api \
  --follow \
  --region eu-west-3
```

---

# 🔧 Troubleshooting

## ❌ Pas de notification reçue

```
1. Vérifiez que l'abonnement SNS est "Confirmed"
2. Vérifiez vos spams
3. Testez manuellement :
   aws sns publish --topic-arn $TOPIC_ARN --message "Test"
```

## ❌ Alarme toujours en "Insufficient data"

```
1. Vérifiez que l'instance envoie des métriques
2. Vérifiez l'ID de l'instance dans la dimension
3. Attendez quelques minutes (les métriques sont envoyées toutes les 5 min)
```

## ❌ Métriques custom non visibles

```
1. Installez CloudWatch Agent sur l'instance
2. Configurez les métriques à collecter
3. Vérifiez que l'agent tourne : systemctl status amazon-cloudwatch-agent
```

---

# 🧹 Nettoyage

```bash
# 1. Supprimer les alarmes
aws cloudwatch delete-alarms \
  --alarm-names ec2-cpu-high ec2-disk-high ec2-status-check-failed \
  --region eu-west-3

# 2. Supprimer le dashboard
aws cloudwatch delete-dashboards \
  --dashboard-names ServerMonitoring \
  --region eu-west-3

# 3. Supprimer l'abonnement SNS
aws sns unsubscribe \
  --subscription-arn arn:aws:sns:eu-west-3:xxx:ServerAlerts:xxx

# 4. Supprimer le topic SNS
aws sns delete-topic \
  --topic-arn $TOPIC_ARN \
  --region eu-west-3
```

---

## ✅ Checklist Finale

- [ ] Topic SNS créé (ServerAlerts)
- [ ] Abonnement email confirmé
- [ ] Dashboard CloudWatch créé
- [ ] Alarme CPU (> 70%) créée
- [ ] Alarme Status Check créée
- [ ] Test d'alarme effectué
- [ ] Notification email reçue

---

[⬅️ Retour : Job4](./Job4_Lambda_API.md) | [➡️ Suite : Job6_Glue_ETL.md](./Job6_Glue_ETL.md)
