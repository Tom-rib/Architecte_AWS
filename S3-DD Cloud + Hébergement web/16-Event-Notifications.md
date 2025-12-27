# Event Notifications - Déclencher Actions 📢

Déclencher SNS/SQS/Lambda quand fichiers uploadés/supprimés.

---

## 🎯 À quoi ça sert ?

- Workflow automatisés (upload → process)
- Notifications (email quand fichier ajouté)
- Intégrations (Lambda, SQS)
- Real-time processing

---

## 📊 Événements

| Événement | Quand | Cas |
|-----------|-------|-----|
| s3:ObjectCreated:* | Fichier ajouté | Notifier upload |
| s3:ObjectRemoved:* | Fichier supprimé | Nettoyer resources |
| s3:ObjectRestored:* | Archive restaurée | Process restauré |

---

## 🖼️ DASHBOARD AWS

### Ajouter Event Notification

```
1. Bucket > Properties > Event notifications
2. Create event notification
3. Name : on-upload
4. Events : s3:ObjectCreated:*
5. Destination :
   - SNS (email)
   - SQS (queue)
   - Lambda (code)
6. Topic/Queue/Function : sélectionnez
7. Save ✓
```

### Exemple avec SNS

```
1. Créer SNS Topic (voir Job1-EC2)
2. S'abonner par email
3. Event notification → Topic
4. Chaque upload = email ✓
```

### Exemple avec Lambda

```
1. Créer fonction Lambda
2. Event notification → Lambda function
3. Quand fichier uploadé → Lambda s'exécute
4. Lambda peut : compresser, watermark, etc
```

---

## 💻 CLI

### Ajouter Event pour SNS

```bash
aws s3api put-bucket-notification-configuration \
  --bucket mon-bucket \
  --notification-configuration '{
    "TopicConfigurations": [
      {
        "TopicArn": "arn:aws:sns:eu-west-3:123456789:mon-topic",
        "Events": ["s3:ObjectCreated:*"]
      }
    ]
  }'
```

### Ajouter Event pour Lambda

```bash
aws s3api put-bucket-notification-configuration \
  --bucket mon-bucket \
  --notification-configuration '{
    "LambdaFunctionConfigurations": [
      {
        "LambdaFunctionArn": "arn:aws:lambda:...",
        "Events": ["s3:ObjectCreated:*"]
      }
    ]
  }'
```

### Voir Notifications

```bash
aws s3api get-bucket-notification-configuration --bucket mon-bucket
```

---

## 📌 NOTES

- **SNS** : notifications (email, SMS)
- **SQS** : queue messages (asynchrone)
- **Lambda** : code exécuté (process fichier)
- **Permissions** : Lambda/SNS/SQS besoin permissions

---

[⬅️ Retour](./README.md)
