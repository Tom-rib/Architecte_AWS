# Troubleshooting - Problèmes Courants 🐛

Solutions aux problèmes CloudWatch et SNS.

---

## SNS

### Email de confirmation pas reçu

**Cause**: Email bloqué/spam, adresse incorrecte

**Solution**:
```
1. Vérifier email (spam folder)
2. Vérifier adresse (typo?)
3. Créer nouvelle subscription
4. Confirmer immédiatement
```

### Les alertes n'arrivent pas

**Cause**: 
- Subscriber non-confirmé
- Topic vide
- SNS permissions

**Solution**:
```bash
# Vérifier subscribers
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:eu-west-3:123456789:alerts-production

# Vérifier état
# Status = "Confirmed" = OK
# Status = "PendingConfirmation" = Confirmer email

# Test publier
aws sns publish \
  --topic-arn arn:aws:sns:eu-west-3:123456789:alerts-production \
  --message "Test"
```

---

## CloudWatch Alarms

### Alarme ne se déclenche pas

**Cause**:
- INSUFFICIENT_DATA (nouveau)
- Métrique n'existe pas
- Seuil trop haut
- SNS non configuré

**Solution**:
```
1. Attendre 5 min (initial)
2. Vérifier métrique existe (console)
3. Réduire seuil (test)
4. Vérifier SNS actions
5. Test alarm: aws cloudwatch set-alarm-state --state-value ALARM
```

### Trop d'alertes (Alarm Fatigue)

**Solution**:
- Augmenter seuil
- Augmenter évaluations (2-3 périodes)
- Utiliser Composite Alarms
- Filtrer SNS

### Alarme en INSUFFICIENT_DATA

**Cause**: Pas assez historique (< 5 min)

**Solution**:
- Attendre 5-10 minutes
- Vérifier métrique envoie data
- Augmenter period

---

## CloudWatch Logs

### Logs vides

**Cause**:
- Lambda ne produit pas logs
- Log Group n'existe pas
- IAM permissions manquent

**Solution**:
```bash
# Vérifier log group existe
aws logs describe-log-groups --log-group-name-prefix /aws/lambda/

# Vérifier IAM role Lambda a:
# logs:CreateLogGroup
# logs:CreateLogStream
# logs:PutLogEvents
```

### Logs trop cher

**Cause**: Rétention "Never", trop de logs

**Solution**:
```bash
# Réduire rétention à 7 jours
aws logs put-retention-policy \
  --log-group-name /aws/lambda/hello-api \
  --retention-in-days 7

# Archiver en S3 avant supprimer

# Réduire logs volume (moins de logging)
```

---

## Coûts

### CloudWatch Logs très cher

**Cause**: Rétention "never" + gros volume

**Solution**:
- Réduire rétention
- Archive S3
- Moins de logging

### Métriques trop cher

**Cause**: 50+ custom metrics

**Solution**:
- Réduire custom metrics
- Utiliser seulement essentiels
- Metric Math au lieu de custom

---

## Testing

### Simuler Alarme

```bash
aws cloudwatch set-alarm-state \
  --alarm-name ec2-cpu-high \
  --state-value ALARM \
  --state-reason "Manual test" \
  --region eu-west-3

# SNS devrait envoyer email
```

### Simuler Métrique Haute

```bash
# Charger EC2 CPU
ssh -i key.pem ec2-user@instance
yes > /dev/null &

# Attendre 10 min pour alarme
```

---

## Support / Escalade

Si problème non résolu:
1. Vérifier AWS Health Dashboard
2. Ouvrir Support Ticket (AWS Console)
3. Includer alarm name et récent logs

