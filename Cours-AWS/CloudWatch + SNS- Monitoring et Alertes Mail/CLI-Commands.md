# CloudWatch + SNS CLI Commands 🔧

Toutes les commandes AWS CLI pour CloudWatch et SNS.

---

## SNS Commands

### Créer Topic

```bash
aws sns create-topic --name alerts-production --region eu-west-3
```

### Lister Topics

```bash
aws sns list-topics --region eu-west-3
```

### S'abonner (Email)

```bash
aws sns subscribe \
  --topic-arn arn:aws:sns:eu-west-3:123456789:alerts-production \
  --protocol email \
  --notification-endpoint your-email@company.com \
  --region eu-west-3
```

### S'abonner (Lambda)

```bash
aws sns subscribe \
  --topic-arn arn:aws:sns:eu-west-3:123456789:alerts-production \
  --protocol lambda \
  --notification-endpoint arn:aws:lambda:eu-west-3:123456789:function:notify-slack \
  --region eu-west-3
```

### Lister Subscriptions

```bash
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:eu-west-3:123456789:alerts-production \
  --region eu-west-3
```

### Publier Message

```bash
aws sns publish \
  --topic-arn arn:aws:sns:eu-west-3:123456789:alerts-production \
  --message "Test message" \
  --subject "Test Subject" \
  --region eu-west-3
```

---

## CloudWatch Alarms Commands

### Créer Alarme (Metric)

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name ec2-cpu-high \
  --alarm-description "EC2 CPU > 80%" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --threshold 80 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 2 \
  --alarm-actions arn:aws:sns:eu-west-3:123456789:alerts-production \
  --region eu-west-3
```

### Créer Alarme (Composite)

```bash
aws cloudwatch put-composite-alarm \
  --alarm-name production-critical \
  --alarm-description "Multiple issues" \
  --alarm-rule "ALARM(ec2-cpu-high) AND ALARM(lambda-errors)" \
  --alarm-actions arn:aws:sns:eu-west-3:123456789:alerts-production \
  --region eu-west-3
```

### Lister Alarmes

```bash
aws cloudwatch describe-alarms --region eu-west-3
```

### Voir État Alarme Spécifique

```bash
aws cloudwatch describe-alarms \
  --alarm-names ec2-cpu-high \
  --region eu-west-3
```

### Supprimer Alarme

```bash
aws cloudwatch delete-alarms \
  --alarm-names ec2-cpu-high \
  --region eu-west-3
```

### Mettre Alarm en Manual

```bash
aws cloudwatch set-alarm-state \
  --alarm-name ec2-cpu-high \
  --state-value ALARM \
  --state-reason "Manual test" \
  --region eu-west-3
```

---

## CloudWatch Logs Commands

### Créer Log Group

```bash
aws logs create-log-group \
  --log-group-name /aws/lambda/test \
  --region eu-west-3
```

### Lister Log Groups

```bash
aws logs describe-log-groups --region eu-west-3
```

### Voir Logs

```bash
aws logs tail /aws/lambda/hello-api --region eu-west-3 --follow
```

### Définir Rétention

```bash
aws logs put-retention-policy \
  --log-group-name /aws/lambda/hello-api \
  --retention-in-days 7 \
  --region eu-west-3
```

### Supprimer Log Group

```bash
aws logs delete-log-group \
  --log-group-name /aws/lambda/test \
  --region eu-west-3
```

---

## CloudWatch Metrics Commands

### Envoyer Custom Metric

```bash
aws cloudwatch put-metric-data \
  --namespace MyApp \
  --metric-name ActiveUsers \
  --value 150 \
  --unit Count \
  --region eu-west-3
```

### Lister Métriques

```bash
aws cloudwatch list-metrics --namespace AWS/EC2 --region eu-west-3
```

### Récupérer Statistiques Métrique

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --start-time 2025-12-27T10:00:00Z \
  --end-time 2025-12-27T11:00:00Z \
  --period 300 \
  --statistics Average,Maximum \
  --region eu-west-3
```

---

## Scripts Utiles

### Créer toutes les 10 alarmes en une fois

```bash
#!/bin/bash

TOPIC_ARN="arn:aws:sns:eu-west-3:123456789:alerts-production"
REGION="eu-west-3"

# EC2 CPU
aws cloudwatch put-metric-alarm --alarm-name ec2-cpu-high --metric-name CPUUtilization --namespace AWS/EC2 --statistic Average --period 300 --threshold 80 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 2 --alarm-actions $TOPIC_ARN --region $REGION

# Lambda Errors
aws cloudwatch put-metric-alarm --alarm-name lambda-errors-high --metric-name Errors --namespace AWS/Lambda --statistic Sum --period 300 --threshold 1 --comparison-operator GreaterThanThreshold --evaluation-periods 1 --alarm-actions $TOPIC_ARN --dimensions Name=FunctionName,Value=hello-api --region $REGION

# RDS Connections
aws cloudwatch put-metric-alarm --alarm-name rds-connections-high --metric-name DatabaseConnections --namespace AWS/RDS --statistic Average --period 300 --threshold 160 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 2 --alarm-actions $TOPIC_ARN --region $REGION

# API 5XX
aws cloudwatch put-metric-alarm --alarm-name api-5xx-errors --metric-name 5XXError --namespace AWS/ApiGateway --statistic Sum --period 300 --threshold 5 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 1 --alarm-actions $TOPIC_ARN --region $REGION

# API Latency
aws cloudwatch put-metric-alarm --alarm-name api-latency-high --metric-name Latency --namespace AWS/ApiGateway --statistic Average --period 300 --threshold 1000 --comparison-operator GreaterThanOrEqualToThreshold --evaluation-periods 2 --alarm-actions $TOPIC_ARN --region $REGION

echo "✅ All alarms created!"
```

---

## Pro Tips

```bash
# Afficher toutes les alarmes en rouge
aws cloudwatch describe-alarms --state-value ALARM

# Supprimer TOUTES les alarmes (⚠️ ATTENTION!)
aws cloudwatch describe-alarms --query 'MetricAlarms[*].AlarmName' --output text | xargs -I {} aws cloudwatch delete-alarms --alarm-names {}

# Monitorer logs en temps réel
aws logs tail /aws/lambda/hello-api --follow

# Compter erreurs dans les logs
aws logs filter-log-events --log-group-name /aws/lambda/hello-api --filter-pattern "ERROR"
```

