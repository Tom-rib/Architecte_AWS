# SNS - Notifications par Email 📧

Recevoir des emails quand Auto Scaling ajoute/enlève des instances.

---

## 🎯 À quoi ça sert ?

- Alerte quand instance lancée
- Alerte quand instance supprimée
- Alerte quand instance devient "Unhealthy"
- Monitoring sans dashboard AWS

---

## 🖼️ DASHBOARD AWS

### Créer un SNS Topic

```
1. SNS > Topics > Create topic
2. Name : asg-notifications
3. Type : Standard
4. Create topic ✓
```

### S'abonner au Topic

```
1. Topics > asg-notifications
2. Subscriptions > Create subscription
3. Protocol : Email
4. Endpoint : votre@email.com
5. Create subscription ✓
6. Email reçu : cliquez "Confirm subscription"
```

### Attacher à Auto Scaling Group

```
1. Auto Scaling Groups > debian-asg
2. Onglet "Notifications"
3. Create notification ✓
4. SNS Topic : asg-notifications
5. Events :
   ☑ Instance launch successful
   ☑ Instance launch unsuccessful
   ☑ Instance terminate successful
   ☑ Instance terminate unsuccessful
6. Create ✓
```

### Voir les notifications

```
SNS > Subscriptions
- Status : Confirmed
- Messages sent : nb
```

---

## 💻 CLI

### Créer SNS Topic

```bash
aws sns create-topic --name asg-notifications
# Retourne : TopicArn
```

### S'abonner au Topic

```bash
aws sns subscribe \
  --topic-arn arn:aws:sns:eu-west-3:123456789:asg-notifications \
  --protocol email \
  --notification-endpoint votre@email.com
```

### Lister les Topics

```bash
aws sns list-topics
```

### Lister les Subscriptions

```bash
aws sns list-subscriptions
```

### Envoyer un message de test

```bash
aws sns publish \
  --topic-arn arn:aws:sns:eu-west-3:123456789:asg-notifications \
  --message "Test message"
```

### Créer notification ASG

```bash
aws autoscaling put-notification-configuration \
  --auto-scaling-group-name debian-asg \
  --topic-arn arn:aws:sns:eu-west-3:123456789:asg-notifications \
  --notification-types \
    "autoscaling:EC2_INSTANCE_LAUNCH" \
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR" \
    "autoscaling:EC2_INSTANCE_TERMINATE" \
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
```

---

## 📌 NOTES

- **Confirmation email** : OBLIGATOIRE (cliquer le lien)
- **Email indésirable** : vérifier spam/promotions
- **Topic vs Subscription** : Topic = canal, Subscription = abonné
- **Autres protocoles** : SMS, SQS, Lambda, HTTP

---

[⬅️ Retour](./README.md)
