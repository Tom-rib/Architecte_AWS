# Alarms - Créer Alertes 🔔

CloudWatch Alarms = notifications automatiques si problèmes détectés.

---

## 🎯 CONCEPT

Alarm = surveillance metrique + notification si seuil dépassé

```
Métrique (Errors) → Seuil (> 1) → Alert (email)
```

---

## 📋 ÉTAPES

### 1. Créer Alarm (Console)

```
1. CloudWatch > Alarms > Create alarm
2. Select metric > Lambda > my-api-function
3. Metric name: Errors
4. Statistic: Sum
5. Period: 5 minutes
```

### 2. Configurer condition

```
┌─────────────────────────────────────┐
│ Condition                           │
│                                     │
│ Threshold: 1                        │
│ Comparison: Greater than or equal   │
│                                     │
│ ✓ If Errors >= 1 in 5 min          │
│   THEN trigger alarm                │
└─────────────────────────────────────┘
```

### 3. Configurer action

```
┌─────────────────────────────────────┐
│ Actions                             │
│                                     │
│ When alarm state is: ALARM          │
│                                     │
│ Send SNS notification to:           │
│ ┌─────────────────────────────────┐ │
│ │ Create new SNS topic       ▼   │ │
│ │ lambda-errors                   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Email address:                      │
│ ┌─────────────────────────────────┐ │
│ │ tom@example.com                 │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 4. Confirmer email SNS

Vous recevrez email : "AWS Notification - Subscription Confirmation"

→ Cliquer le lien de confirmation

---

## 💻 VIA CLI

### Créer alarm (erreurs)

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name lambda-errors-alarm \
  --alarm-description "Alert if Lambda errors > 1" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --dimensions Name=FunctionName,Value=my-api-function \
  --alarm-actions arn:aws:sns:eu-west-3:ACCOUNT:lambda-errors \
  --region eu-west-3
```

### Créer alarm (latence)

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name lambda-duration-alarm \
  --alarm-description "Alert if avg duration > 1 sec" \
  --metric-name Duration \
  --namespace AWS/Lambda \
  --statistic Average \
  --period 300 \
  --threshold 1000 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=FunctionName,Value=my-api-function \
  --alarm-actions arn:aws:sns:eu-west-3:ACCOUNT:lambda-alerts \
  --region eu-west-3
```

### Créer alarm (throttles)

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name lambda-throttles-alarm \
  --alarm-description "Alert if throttles > 0" \
  --metric-name Throttles \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 0 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=FunctionName,Value=my-api-function \
  --alarm-actions arn:aws:sns:eu-west-3:ACCOUNT:lambda-alerts \
  --region eu-west-3
```

---

## 📊 TYPES D'ALARMS

| Métrique | Seuil | Action |
|----------|-------|--------|
| **Errors** | >= 1 | Envoyer email |
| **Duration** | > 1000 ms | Envoyer email + SMS |
| **Throttles** | > 0 | Envoyer email + Slack |
| **Memory** | > 512 MB | Log warning |
| **Invocations** | > 10000 | Notifier admin |

---

## 🔔 ACTIONS POSSIBLES

| Action | Coût | Utilité |
|--------|------|---------|
| **SNS Email** | Gratuit | Notifications |
| **SNS SMS** | $0.75/SMS | Urgent |
| **Lambda Function** | Gratuit | Auto-remediation |
| **Slack Webhook** | Gratuit | Notifications Slack |
| **PagerDuty** | Payant | On-call alerting |

---

## 🎯 ALARME RECOMMANDÉE (MVP)

```bash
# 1. Créer topic SNS
aws sns create-topic \
  --name lambda-alerts \
  --region eu-west-3

# Récupérer Topic ARN
TOPIC_ARN=$(aws sns list-topics \
  --region eu-west-3 \
  --query 'Topics[0].TopicArn' \
  --output text)

# 2. S'abonner par email
aws sns subscribe \
  --topic-arn $TOPIC_ARN \
  --protocol email \
  --notification-endpoint tom@example.com \
  --region eu-west-3

# 3. Créer alarm
aws cloudwatch put-metric-alarm \
  --alarm-name lambda-errors \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --dimensions Name=FunctionName,Value=my-api-function \
  --alarm-actions $TOPIC_ARN \
  --region eu-west-3

echo "Alarm créée ! Confirmez l'email SNS"
```

---

## 📝 EXEMPLE NOTIFICATION

Quand alarm déclenche, vous recevez email :

```
Subject: AWS Alarm Notification

Alarm: lambda-errors-alarm
Status: ALARM

Reason: Threshold Crossed: 1 datapoint [1 (average)] was greater than or equal to 1 threshold [1].

Alarm ARN: arn:aws:cloudwatch:eu-west-3:ACCOUNT:alarm:lambda-errors-alarm
Time: Wed Dec 26 12:00:00 UTC 2024
Region: eu-west-3
Alarm Dimensions:
 FunctionName = my-api-function

State Change: INSUFFICIENT_DATA -> ALARM
Action: arn:aws:sns:eu-west-3:ACCOUNT:lambda-alerts

Link: https://eu-west-3.console.aws.amazon.com/cloudwatch/...
```

---

## 🛡️ BONNES PRATIQUES

✅ **À FAIRE :**
```
- Alarmes sur erreurs (seuil >= 1)
- Alarmes sur latence (> 1 sec)
- Alarmes sur throttles (> 0)
- SNS topic par severité (critical, warning)
- Test de l'alarm (voir "Test alarm")
```

❌ **À ÉVITER :**
```
- Trop d'alarmes (alert fatigue)
- Seuils trop sensibles
- Pas de notification
- Ignorer les alerts
```

---

## 🧪 TESTER L'ALARM

Pour vérifier que alarm fonctionne :

```
1. CloudWatch > Alarms > lambda-errors-alarm
2. Actions > Test Alarm Action
3. Vous recevrez email de test
```

---

## 📌 NOTES

- **Historique** : 15 mois gratuit
- **Cost** : 10 alarmes gratuites/mois
- **SNS** : $1.50 par million notifications
- **Delay** : 1-2 minutes entre trigger et notification

---

[⬅️ Retour](./README.md) | [➡️ Versions](./12-Versions.md)

