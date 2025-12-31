# SNS - Guide Complet & Référence 📬

Simple Notification Service : Service AWS pour envoyer notifications (email, SMS, push, Lambda, HTTP, etc).

---

## TABLE DES MATIÈRES

1. [Qu'est-ce que SNS ?](#qu-est-ce-que-sns-)
2. [Topics SNS](#topics-sns)
3. [Subscriptions](#subscriptions)
4. [Protocoles de Notification](#protocoles-de-notification)
5. [Publication de Messages](#publication-de-messages)
6. [Filtrage de Messages](#filtrage-de-messages)
7. [Dead Letter Queues](#dead-letter-queues)
8. [Sécurité](#sécurité)
9. [Pricing](#pricing)
10. [Best Practices](#best-practices)

---

## Qu'est-ce que SNS ?

Service de **notification pub/sub** (publish-subscribe) pour envoyer messages à **plusieurs destinataires en parallèle**.

### Vocabulaire

```
Topic SNS
│
├─ Publier (Publisher)
│  └─ Source: Alarme CloudWatch, Lambda, EC2, Application
│
└─ Souscrire (Subscribers)
   ├─ Email
   ├─ SMS
   ├─ Push Notification
   ├─ Lambda
   ├─ SQS
   ├─ HTTP/HTTPS
   └─ Application
```

### Analogie

```
Topic = Forum de discussion

Publisher = Crée post
│
├─ "CPU Alert"
├─ "Database Down"
└─ "Sales Report Ready"

Subscribers = Reçoit notifications
│
├─ Tom (email)
├─ Alice (SMS)
├─ Bot (Lambda)
└─ Dashboard (HTTP)
```

### Comparaison avec d'autres services

| Service | SNS | SQS | EventBridge | Webhook |
|---|---|---|---|---|
| **Type** | Pub/Sub | Queue | Event Router | Custom HTTP |
| **Parallèle** | ✅ Oui | ❌ Non | ✅ Oui | ❌ Non |
| **Email** | ✅ Oui | ❌ Non | ❌ Non | ❌ Non |
| **SMS** | ✅ Oui | ❌ Non | ❌ Non | ❌ Non |
| **Lambda** | ✅ Oui | ✅ Oui | ✅ Oui | ❌ Non |
| **Filtrage** | Basique | ❌ Non | ✅ Avancé | ❌ Non |
| **Idéal** | Alertes | Queues | Workflows | Custom |

---

## Topics SNS

### Qu'est-ce qu'un Topic ?

**Topic** = Canal de communication central

```
Topic: alerts-production
│
├─ Alarmes CloudWatch → publish message
├─ Lambda → publish message
│
└─ Subscribers reçoivent
   ├─ Email: ops-team@company.com
   ├─ SMS: +33612345678
   ├─ Lambda: slack-notifier
   └─ HTTP: https://webhook.example.com
```

### Créer un Topic

**Console AWS** :
1. SNS > Topics > Create Topic
2. Type: Standard (ou FIFO pour ordre garantis)
3. Nom: `alerts-production`
4. Créer

**CLI** :
```bash
aws sns create-topic --name alerts-production --region eu-west-3
```

### FIFO vs Standard

```
Standard Topics
├─ Message order NOT guaranteed
├─ Unlimited throughput
├─ Lowest latency
├─ Ideal pour alertes non-critiques

FIFO Topics
├─ Order GUARANTEED
├─ 300 messages/sec max
├─ Higher latency
├─ Ideal pour workflows exacts
├─ Coûts identiques
```

---

## Subscriptions

### Qu'est-ce qu'une Subscription ?

**Subscription** = Abonnement à un topic pour recevoir messages

```
Topic "alerts"
│
├─ Subscription 1: Email (ops@company.com)
├─ Subscription 2: SMS (+33612345678)
├─ Subscription 3: Lambda (slack-bot)
└─ Subscription 4: HTTP (webhook)

Quand message publié dans topic
→ Tous les subscribers le reçoivent EN PARALLÈLE
```

### États d'une Subscription

```
PendingConfirmation
├─ Juste créée
├─ Email: lien de confirmation requis
├─ SMS: numéro doit être confirmé
└─ Attend action utilisateur

Confirmed
├─ Confirmée
├─ Active et reçoit messages
└─ État normal

Deleted
├─ Supprimée
└─ Ne reçoit plus messages
```

### Ajouter une Subscription

**Console** :
1. SNS > Topics > Sélectionner topic
2. Create Subscription
3. Choisir Protocol
4. Entrer endpoint
5. Create

**CLI** :
```bash
# Email
aws sns subscribe --topic-arn arn:aws:sns:eu-west-3:123456789:alerts \
  --protocol email --notification-endpoint ops@company.com

# SMS
aws sns subscribe --topic-arn arn:aws:sns:eu-west-3:123456789:alerts \
  --protocol sms --notification-endpoint +33612345678

# Lambda
aws sns subscribe --topic-arn arn:aws:sns:eu-west-3:123456789:alerts \
  --protocol lambda --notification-endpoint arn:aws:lambda:eu-west-3:123456789:function:my-handler
```

---

## Protocoles de Notification

### 1. Email

```
Protocol: email
│
├─ Endpoint: email@company.com
│
├─ Message reçu:
│  From: no-reply@sns.amazonaws.com
│  Subject: AWS Notification
│  Body: Message JSON
│
└─ Confirmation: Email lien "Confirm subscription"
```

**Avantages** :
- Simple, universel
- Gratuit

**Inconvénients** :
- Peut être spam
- Lent (quelques secondes)
- Pas de format personnalisé facile

### 2. SMS

```
Protocol: sms
│
├─ Endpoint: +33612345678
│
├─ Message reçu: SMS texte
│  "AWS SNS: Your message here"
│
└─ Confirmation: Code SMS à confirmer
```

**Avantages** :
- Très rapide
- Hors-ligne possible

**Inconvénients** :
- Coûteux (0.04€/SMS environ)
- Limité à 160 caractères
- Pas gratuit

**Coût** :
- EU (France) : ~0.04€/SMS
- Riche limite: 1€/mois max par SMS

### 3. Lambda

```
Protocol: lambda
│
├─ Endpoint: arn:aws:lambda:eu-west-3:123456789:function:handler
│
├─ SNS envoie JSON à Lambda:
│  {
│    "TopicArn": "...",
│    "Message": "CPU Alert",
│    "Timestamp": "2025-12-27T15:30:45.123Z"
│  }
│
└─ Lambda execute immédiatement
```

**Avantages** :
- Automation complète
- Logique custom
- Intégration facile

**Inconvénients** :
- Lambda doit exister
- Permissions IAM requises
- Coûts Lambda s'ajoutent

**Cas d'Usage** :
- Envoyer sur Slack
- Créer ticket Jira
- Déclencher workflow
- Notifier dashboard

### 4. HTTP / HTTPS

```
Protocol: https
│
├─ Endpoint: https://webhook.example.com/alerts
│
├─ SNS POST request:
│  POST https://webhook.example.com/alerts
│  Content-Type: application/json
│  {
│    "TopicArn": "...",
│    "Message": "CPU Alert",
│    "Timestamp": "..."
│  }
│
└─ Application reçoit request
```

**Avantages** :
- Flexible
- Intégration facile
- Webhook personnalisé

**Inconvénients** :
- Endpoint doit être accessible (sécurité)
- Retry limités
- Rate limiting possible

### 5. SQS

```
Protocol: sqs
│
├─ SNS envoie message à SQS Queue
│  (Queue traite messages lentement)
│
├─ Avantages:
│  - Decoupling
│  - Messages en queue si crash
│  - Retry automatic
│
└─ Ideal pour: Batch processing
```

### 6. Application (Mobile Push)

```
Protocol: application
│
├─ Endpoint: Platform Endpoint
│  (iOS, Android, Kindle, etc)
│
├─ Reçoit Push Notification
│  - iOS: Apple Push
│  - Android: Firebase Cloud Messaging
│
└─ Ideal pour: Apps mobiles
```

### 7. Email JSON

```
Protocol: email-json
│
├─ Email contient JSON formaté
│  (au lieu de texte brut)
│
├─ Message reçu:
│  {
│    "Type": "Notification",
│    "TopicArn": "...",
│    "Message": "CPU Alert"
│  }
│
└─ Ideal pour: Email parsing
```

---

## Publication de Messages

### Format Simple

```python
import boto3

sns = boto3.client('sns')

sns.publish(
    TopicArn='arn:aws:sns:eu-west-3:123456789:alerts',
    Message='EC2 CPU Alert: 85%',
    Subject='AWS Alert'  # Email subject
)
```

### Format Message Attributes

```python
sns.publish(
    TopicArn='arn:aws:sns:eu-west-3:123456789:alerts',
    Message='CPU Alert',
    Subject='High CPU',
    MessageAttributes={
        'severity': {
            'DataType': 'String',
            'StringValue': 'critical'
        },
        'service': {
            'DataType': 'String',
            'StringValue': 'web-server'
        }
    }
)
```

### Format Structured (Cloud Formation)

```json
{
  "Type": "AWS::SNS::Topic",
  "Properties": {
    "TopicName": "alerts-production",
    "DisplayName": "Production Alerts",
    "KmsMasterKeyId": "alias/aws/sns",
    "Tags": [
      {
        "Key": "Environment",
        "Value": "Production"
      }
    ]
  }
}
```

---

## Filtrage de Messages

### Sans Filtrage

Topic → Tous les subscribers reçoivent TOUS les messages

### Avec Filtrage

Topic → Seulement les subscribers correspondant au filtre reçoivent

```python
# Subscription avec filtre
subscription_attributes = {
    'FilterPolicy': json.dumps({
        'severity': ['critical', 'warning'],
        'service': ['web-server', 'api']
    })
}

sns.set_subscription_attributes(
    SubscriptionArn='arn:aws:sns:eu-west-3:123456789:alerts:abc123',
    AttributeName='FilterPolicy',
    AttributeValue=json.dumps(subscription_attributes)
)
```

**Exemple** :

```
Topic: alerts
│
├─ Subscriber A (Email ops@...)
│  FilterPolicy: {"severity": "critical"}
│  → Reçoit: CRITICAL alerts seulement
│
├─ Subscriber B (Lambda slack-bot)
│  FilterPolicy: {"severity": ["warning", "critical"]}
│  → Reçoit: WARNING et CRITICAL
│
└─ Subscriber C (SMS +33...)
   NO FilterPolicy
   → Reçoit: TOUS les messages
```

---

## Dead Letter Queues

### Qu'est-ce ?

Queue qui reçoit les messages que SNS **ne peut pas** livrer

```
SNS Topic
│
├─ Try to deliver message
│  ├─ Success → Subscriber reçoit ✓
│  └─ Fail (email bounce, Lambda error, etc)
│     └─ Retry 3x
│        ├─ Success → Livré ✓
│        └─ Fail → Dead Letter Queue
```

### Configurer DLQ

```python
sns.set_topic_attributes(
    TopicArn='arn:aws:sns:eu-west-3:123456789:alerts',
    AttributeName='DeadLetterTargetArn',
    AttributeValue='arn:aws:sqs:eu-west-3:123456789:failed-alerts'
)
```

### Avantages

- Messages non-livrés ne sont pas perdus
- Analyser les échecs
- Retry manual possible
- Debugging

---

## Sécurité

### Permissions IAM

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sns:Publish",
        "sns:Subscribe"
      ],
      "Resource": "arn:aws:sns:eu-west-3:123456789:alerts"
    }
  ]
}
```

### Chiffrement KMS

```python
sns.create_topic(
    Name='alerts-production',
    Attributes={
        'KmsMasterKeyId': 'alias/aws/sns'
    }
)
```

### Access Control

```python
# Qui peut publier?
sns.set_topic_attributes(
    TopicArn='arn:aws:sns:eu-west-3:123456789:alerts',
    AttributeName='Policy',
    AttributeValue=json.dumps({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {"AWS": "arn:aws:iam::123456789:root"},
                "Action": "SNS:Publish",
                "Resource": "arn:aws:sns:eu-west-3:123456789:alerts"
            }
        ]
    })
)
```

---

## Pricing

### Coûts SNS

```
Publication
├─ 1 million requests / mois: GRATUIT
└─ Après: 0.50€ / million requests

Notifications
├─ Email: GRATUIT
├─ HTTP/HTTPS: GRATUIT
├─ SMS: ~0.04€ / SMS (très cher!)
├─ Push Mobile: ~0.50€ / million notifications
└─ Lambda: Coûts Lambda s'ajoutent

Free Tier
├─ 1000 SNS requests
└─ 100 Email notifications
```

### Calcul Coût

```
Exemple: 10,000 alarmes/jour, 1 email chaque

Coûts:
├─ 10,000 publications/jour
│  = 300,000/mois
│  → GRATUIT (inclus 1M)
│
└─ 10,000 emails/jour
   = 300,000/mois
   → GRATUIT
```

---

## Best Practices

### 1. Nommage Topics

```
❌ MAUVAIS
- alerts
- notifications
- events

✅ BON
- alerts-production-critical
- alerts-staging-warning
- notifications-ops-team
- events-payment-service
```

### 2. Structurer Messages

```
❌ MAUVAIS
"CPU Alert 85%"

✅ BON
{
  "alarm": "cpu-high",
  "value": 85,
  "threshold": 80,
  "instance": "i-1234567890",
  "timestamp": "2025-12-27T15:30:45Z",
  "severity": "warning"
}
```

### 3. Limiter Topics

```
1 Topic par Concern
├─ alerts-production (toutes alertes prod)
├─ alerts-staging (toutes alertes staging)
└─ notifications-reports (rapports)

Au lieu de:
├─ Topic per alarm (100+, compliqué)
└─ 1 Big topic (impossible filtrer)
```

### 4. Sécuriser Endpoints

```
❌ MAUVAIS
- Endpoint: http://webhook.example.com (non-sécurisé)
- SMS nombreux (cher!)
- Tous les subscribers reçoivent tout

✅ BON
- Endpoint: https://webhook.example.com (SSL)
- SMS seulement critiques
- Filtrer par severity/service
```

### 5. Monitorer Topics

```
Métriques importantes:
├─ NumberOfNotificationsFailed (DLQ)
├─ NumberOfMessagesPublished (traffic)
└─ NumberOfSubscriptions (abonnements)

Alarmes recommandées:
├─ DLQ non-empty
├─ PublishSize > limite
└─ subscription-fail rate > 5%
```

---

## Foire aux Questions

**Q: SNS vs SQS, quand utiliser quoi ?**
A: SNS = alertes / notifications instant, SQS = queue / batch processing

**Q: Peut-on filtrer emails ?**
A: Oui, avec FilterPolicy (mais pas le contenu du message)

**Q: Combien subscribers par topic ?**
A: Illimité techniquement, 100+ recommandé

**Q: Messages réessayés combien de fois ?**
A: 3 tentatives, puis DLQ si configuré

**Q: SMS très cher pourquoi ?**
A: Opérateurs télécom coûtent cher, AWS passe le coût

**Q: Peut-on envoyer email personnalisé ?**
A: Non directement, utiliser Lambda → SES pour plus de contrôle

---

**SUITE** : Voir 05-Alarms-Avances.md pour créer alarmes
