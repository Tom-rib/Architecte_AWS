# CloudWatch Alarms - Guide Complet & Référence 🚨

Tout sur la création d'alarmes CloudWatch et actions associées.

---

## TABLE DES MATIÈRES

1. [Concepts Fondamentaux](#concepts-fondamentaux)
2. [Metric Alarms](#metric-alarms)
3. [Composite Alarms](#composite-alarms)
4. [Anomaly Detection](#anomaly-detection)
5. [Actions d'Alarme](#actions-dalarme)
6. [Best Practices](#best-practices)

---

## Concepts Fondamentaux

### États d'une Alarme

```
                    OK
                   ↑ ↓
         ┌──────────┴──────────┐
         ↓                      ↓
      ALARM            INSUFFICIENT_DATA
   (Condition TRUE)    (Pas assez données)

OK (Vert) ✅
├─ Condition FALSE
├─ Métrique < seuil
├─ Tout normal
└─ Email: "OK" optionnelle

ALARM (Rouge) 🚨
├─ Condition TRUE
├─ Métrique >= seuil
├─ Action déclenchée
└─ Email: Alert

INSUFFICIENT_DATA (Gris) ❓
├─ Juste créée
├─ Historique insuffisant
├─ Attend 5 minutes
└─ Pas d'action
```

### Période d'Évaluation

```
Alarme: CPU > 80%
│
├─ Period: 5 minutes
├─ EvaluationPeriods: 2
│
└─ TRIGGER si:
   CPU > 80% pour 2 périodes
   = 10 minutes d'affilée
   (évite faux positifs)
```

**Pourquoi 2 périodes ?**
- Spike CPU 85% 1 seconde : ignoré
- CPU 85% pendant 10 min : ALARME (grave)

---

## Metric Alarms

### Structure

```
Metric Alarm
│
├─ Métrique: CPUUtilization
├─ Comparaison: GreaterThanOrEqualToThreshold
├─ Seuil: 80
├─ Statistique: Average
├─ Période: 5 minutes
├─ Évaluations: 2 périodes
│
├─ IF CPUUtilization >= 80 FOR 10 min
│  THEN ALARM
│
└─ Actions:
   ├─ Envoyer SNS
   ├─ Auto Scaling (augmenter)
   ├─ EC2 Action (reboot)
   └─ OpsCenter (ticket)
```

### Créer une Metric Alarm

**Console AWS**

```
1. CloudWatch > Alarms > Create Alarm
2. Select Metric
   ├─ Service: EC2
   ├─ Metric Name: CPUUtilization
   └─ Instance: i-1234567890

3. Alarm Details
   ├─ Alarm Name: ec2-cpu-high
   ├─ Description: CPU > 80%
   └─ Alarm Condition:
      └─ Threshold: 80 %

4. Alarm State Trigger
   ├─ Statistic: Average
   ├─ Period: 5 minutes
   ├─ Evaluation: 1 datapoint
   ├─ Comparison: >=
   └─ Threshold: 80

5. Actions
   ├─ Alarm State: ALARM
   ├─ Send notification to: SNS topic
   └─ Select topic: alerts-production

6. Create
```

**CLI**

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name ec2-cpu-high \
  --alarm-description "CPU > 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 1 \
  --alarm-actions arn:aws:sns:eu-west-3:123456789:alerts-production \
  --region eu-west-3
```

**Python (Boto3)**

```python
import boto3

cloudwatch = boto3.client('cloudwatch')

cloudwatch.put_metric_alarm(
    AlarmName='ec2-cpu-high',
    ComparisonOperator='GreaterThanOrEqualToThreshold',
    EvaluationPeriods=1,
    MetricName='CPUUtilization',
    Namespace='AWS/EC2',
    Period=300,
    Statistic='Average',
    Threshold=80.0,
    ActionsEnabled=True,
    AlarmActions=[
        'arn:aws:sns:eu-west-3:123456789:alerts-production'
    ],
    AlarmDescription='EC2 CPU > 80%',
)
```

### Statistiques Disponibles

```
Average
├─ Moyenne de la métrique
├─ Exemple: CPU moyen 45%
└─ Recommandé pour la plupart

Maximum
├─ Pic maximum
├─ Exemple: CPU peak 95%
└─ Bon pour détecter spikes

Minimum
├─ Valeur minimale
├─ Exemple: CPU min 5%
└─ Moins utilisé

Sum
├─ Total cumulatif
├─ Exemple: Erreurs total 150
└─ Bon pour comptes

SampleCount
├─ Nombre de points
├─ Exemple: 120 invocations
└─ Bon pour traffic

pNN.NN (Percentile)
├─ Exemple: p99 = 99ème percentile
├─ p99 Latency = 2.5 secondes
└─ Bon pour SLA
```

### Comparateurs

```
GreaterThanOrEqualToThreshold (>=)
├─ x >= 80
└─ Idéal pour "trop haut"

GreaterThanThreshold (>)
├─ x > 80
└─ Strictement supérieur

LessThanOrEqualToThreshold (<=)
├─ x <= 5
└─ Idéal pour "trop bas"

LessThanThreshold (<)
├─ x < 5
└─ Strictement inférieur

LessThanLowerOrGreaterThanUpperThreshold
├─ x < 10 OR x > 80
└─ Plage anormale
```

---

## Composite Alarms

### Qu'est-ce ?

Alarme basée sur **plusieurs autres alarms**, avec **logique AND/OR**

```
Composite Alarm: "Production Down"
│
└─ IF (CPU High) AND (Latency High) AND (Errors High)
   THEN Send Alert

Au lieu de 3 alertes séparées
```

### Créer Composite Alarm

**Console**

```
1. CloudWatch > Alarms > Create Alarm
2. Select: Composite Alarm
3. Name: production-critical
4. Alarm Rule:
   ├─ (ALARM ec2-cpu-high) AND
   ├─ (ALARM api-latency-high) AND
   └─ (ALARM lambda-errors-high)
5. Actions: Send SNS
6. Create
```

**CLI**

```bash
aws cloudwatch put-composite-alarm \
  --alarm-name production-critical \
  --alarm-rule "ALARM(ec2-cpu-high) AND ALARM(api-latency-high)" \
  --alarm-actions arn:aws:sns:eu-west-3:123456789:alerts-production
```

### Logique Possible

```
Conditions Simples
├─ ALARM(alarm-name) - Vrai si ALARM
├─ OK(alarm-name) - Vrai si OK
└─ INSUFFICIENT_DATA(alarm-name)

Opérateurs
├─ AND - Toutes vraies
├─ OR - Au moins une vraie
└─ NOT - Opposé

Exemples
├─ ALARM(cpu-high) AND ALARM(mem-high)
   → Alarme si CPU ET RAM hauts

├─ ALARM(api-error) OR ALARM(db-error)
   → Alarme si API OU DB en erreur

├─ NOT INSUFFICIENT_DATA(cpu)
   → Alarme si données disponibles
```

---

## Anomaly Detection

### Qu'est-ce ?

Alarme qui détecte automatiquement **patterns anormaux** via ML

```
Anomaly Detection
│
├─ ML apprend pattern normal
│  (2 semaines historique)
│
├─ Détecte déviation > 2 sigma
│  (probabilité < 5%)
│
└─ Trigger si anormal
   Exemple: CPU normalement 30%
           Soudain 70% → ANOMALY
```

### Créer Anomaly Alarm

**Console**

```
1. CloudWatch > Alarms > Create Alarm
2. Select Metric
3. Anomaly Detector
   ├─ Select Metric: CPUUtilization
   └─ Anomaly Detector automatically created
4. Threshold: 2 (sigma)
5. Actions: SNS
6. Create
```

**CLI**

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name cpu-anomaly \
  --comparison-operator LessThanLowerOrGreaterThanUpperThreshold \
  --evaluation-periods 1 \
  --metrics '[{
    "Id": "m1",
    "ReturnData": true,
    "MetricStat": {
      "Metric": {"Namespace": "AWS/EC2", "MetricName": "CPUUtilization"},
      "Period": 300,
      "Stat": "Average"
    }
  }, {
    "Id": "ad1",
    "Expression": "ANOMALY_DETECTION_BAND(m1, 2)",
    "ReturnData": true
  }]' \
  --threshold-metric-id ad1
```

### Sigma (σ)

```
2 sigma = 95% confiance
├─ Catches 5% anormal
├─ Moins sensible
└─ Recommandé

3 sigma = 99.7% confiance
├─ Catches 0.3% anormal
├─ Plus sensible
└─ Pour très critique
```

---

## Actions d'Alarme

### SNS Notification

```
Alarm État Change
│
└─ Envoyer message SNS
   │
   ├─ Topic: alerts-production
   │
   ├─ Message contient:
   │  ├─ Alarm Name
   │  ├─ Reason
   │  ├─ Metric Value
   │  └─ Timestamp
   │
   └─ Subscribers reçoivent:
      ├─ Email
      ├─ SMS
      ├─ Lambda
      └─ HTTP
```

### Auto Scaling Action

```
Alarm ALARM State
│
└─ Trigger Auto Scaling Policy
   │
   ├─ Scale UP: Ajouter 2 instances
   │
   └─ Scale DOWN: Supprimer 1 instance
```

### EC2 Instance Action

```
Alarm ALARM State
│
└─ EC2 Action
   │
   ├─ Stop Instance
   ├─ Terminate Instance
   ├─ Reboot Instance
   └─ Recover Instance
```

### Lambda Action

```
Alarm ALARM State
│
└─ Invoke Lambda Function
   │
   ├─ Passer Alarm Details en input
   │
   └─ Lambda peut:
      ├─ Envoyer Slack message
      ├─ Créer ticket Jira
      ├─ Lancer remediation
      └─ Notifier équipe
```

### OpsCenter (Incident Management)

```
Alarm ALARM State
│
└─ Create OpsCenter Item
   │
   ├─ Ticket automatique
   ├─ Historique
   └─ Track resolution
```

### CloudFormation Action

```
Alarm ALARM State
│
└─ Update CloudFormation Stack
   │
   └─ Change infrastructure
      Exemple: Auto-heal resource
```

---

## Configuration Multi-Service

### Alarmes Recommandées Par Service

**EC2**

```
1. CPU High (>80%)
2. Network In/Out Unusual
3. Instance Status Check Failed
```

**Lambda**

```
1. Errors > 1%
2. Throttles > 0
3. Duration > 5 sec
```

**RDS**

```
1. Connections > 80%
2. CPU > 80%
3. Failed SQL Statements > 5
```

**API Gateway**

```
1. 4XX Errors > 5%
2. 5XX Errors > 1%
3. Latency > 1000 ms
```

**DynamoDB**

```
1. Read Throttles > 0
2. Write Throttles > 0
3. Replication Latency > 1 sec
```

### Centraliser sur 1 Topic SNS

```
Topic: alerts-production
│
├─ EC2 Alarm 1 → publishes
├─ EC2 Alarm 2 → publishes
├─ Lambda Alarm 1 → publishes
├─ RDS Alarm 1 → publishes
└─ API Alarm 1 → publishes

1 Topic = Facile gérer
1 Email = Reçoit toutes
```

---

## Best Practices

### 1. Seuils Réalistes

```
❌ MAUVAIS
CPU > 90%
├─ Trop stricte
├─ Trop alertes
└─ "Alarm fatigue"

✅ BON
CPU > 80%
├─ Basé historique
├─ Temps réagir
└─ Évite faux positif
```

### 2. Statistic Appropriée

```
❌ MAUVAIS
CPU Maximum > 80%
├─ Spike 1 sec = alarme
├─ Faux positifs

✅ BON
CPU Average > 80% for 2 periods
├─ 10 min d'affilée
├─ Problème réel
```

### 3. Évaluation Périodes

```
❌ MAUVAIS
Période 1 min, Evaluations 1
├─ Très sensible
├─ Spike mineur = alarme

✅ BON
Période 5 min, Evaluations 2
├─ 10 min d'affilée
├─ Moins sensible
├─ Coûts réduits
```

### 4. Actions Cohérentes

```
❌ MAUVAIS
Alarm CPU High
├─ Action: SNS
├─ Alarm Memory High
   └─ Action: Rien
├─ Alarm Errors High
   └─ Action: Lambda (auto-restart)

✅ BON
Toutes alertes → SNS topic unique
Logique similaire
```

### 5. Monitoring des Alarms

```
❌ MAUVAIS
Créer alarms et ignorer

✅ BON
Monitorer alarms elles-mêmes:
├─ Sont-elles déclenchées ?
├─ SNS fonctionne ?
├─ Action exécutée ?
└─ Seuils toujours pertinents ?
```

---

## Troubleshooting Alarms

### Alarm ne se déclenche pas

```
Causes possibles:
├─ INSUFFICIENT_DATA (pas assez historique)
│  → Attendre 5 minutes
│
├─ Métrique n'existe pas
│  → Vérifier nom métrique
│
├─ Seuil trop haut
│  → Baisser threshold
│
└─ SNS ne fonctionne pas
   → Vérifier Topic, Subscribers
```

### Trop d'alertes (Alarm Fatigue)

```
Solutions:
├─ Augmenter seuil
├─ Augmenter évaluations (2-3)
├─ Utiliser Composite Alarms
├─ Filtrer SNS
└─ Grouper dans Dashboard
```

### Alert n'arrive pas

```
Causes:
├─ Subscriber non-confirmé (email)
│  → Confirmer lien email
│
├─ SNS Topic vide
│  → Ajouter subscribers
│
├─ Permissions IAM
│  → Vérifier policy
│
└─ Limite dépassée
   → Vérifier coûts/quotas
```

---

## Free Tier CloudWatch Alarms

```
Gratuit:
├─ 10 alarms/mois
├─ Metric Alarms
├─ SNS notifications
└─ Standard Monitoring

Payant:
├─ +0.10€ / alarm / mois
├─ Detailed Monitoring (1 min)
├─ Composite Alarms (+0.50€)
└─ Custom Metrics (0.30€ / metric)

Stratégie Free Tier (10 alarms):
├─ 1 EC2 CPU High
├─ 1 Lambda Errors
├─ 1 RDS Connections
├─ 1 API 5XX Errors
├─ 1 API Latency
├─ 1 DynamoDB Read Throttles
├─ 1 DynamoDB Write Throttles
├─ 1 S3 Errors (optionnel)
├─ 1 Composite Alarm (multi-service)
└─ 1 Reserve (futur)
```

---

**SUITE** : Voir GUIDE-SETUP-JOB5.md pour mettre en place les 10 alarmes du projet
