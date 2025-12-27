# CloudWatch Alarms Setup - 10 Alarmes Optimisées
# Job 5: Surveillance et Alertes avec CloudWatch
# 
# Usage:
# 1. Modifier $AWS_ACCOUNT_ID et $SNS_TOPIC_NAME avec vos valeurs
# 2. Exécuter ce script dans PowerShell
#
# Requirements:
# - AWS CLI configured (aws configure)
# - AWS credentials with CloudWatch permissions
# - SNS Topic créé avec subscribers

# ===== CONFIGURATION =====
# ⚠️ À MODIFIER AVEC VOS VALEURS

# Ton AWS Account ID (ex: 703216717306)
$AWS_ACCOUNT_ID = "YOUR_AWS_ACCOUNT_ID_HERE"

# Ton SNS Topic Name (le topic doit exister)
$SNS_TOPIC_NAME = "alerts-production"

# Région AWS
$REGION = "eu-west-3"

# ===== FIN CONFIGURATION =====

# Construire le Topic ARN
$TOPIC_ARN = "arn:aws:sns:$($REGION):$($AWS_ACCOUNT_ID):$($SNS_TOPIC_NAME)"

Write-Host "================================"
Write-Host "CloudWatch Alarms Setup"
Write-Host "================================"
Write-Host "Topic ARN: $TOPIC_ARN"
Write-Host "Region: $REGION"
Write-Host ""

# ===== ALARME 1: EC2 CPU =====
Write-Host "Création Alarme 1: EC2 CPU High..."
aws cloudwatch put-metric-alarm `
  --alarm-name ec2-cpu-high-sim `
  --alarm-description "EC2 CPU > 5% (simulation)" `
  --metric-name CPUUtilization `
  --namespace AWS/EC2 `
  --statistic Average `
  --period 300 `
  --threshold 5 `
  --comparison-operator GreaterThanOrEqualToThreshold `
  --evaluation-periods 1 `
  --alarm-actions $TOPIC_ARN `
  --region $REGION

if ($LASTEXITCODE -eq 0) { Write-Host "✅ Alarme 1 créée" } else { Write-Host "❌ Erreur Alarme 1" }

# ===== ALARME 2: Lambda Errors =====
Write-Host "Création Alarme 2: Lambda Errors..."
aws cloudwatch put-metric-alarm `
  --alarm-name lambda-errors-sim `
  --alarm-description "Lambda errors > 0 (simulation)" `
  --metric-name Errors `
  --namespace AWS/Lambda `
  --dimensions Name=FunctionName,Value=hello-api `
  --statistic Sum `
  --period 300 `
  --threshold 0 `
  --comparison-operator GreaterThanThreshold `
  --evaluation-periods 1 `
  --alarm-actions $TOPIC_ARN `
  --region $REGION

if ($LASTEXITCODE -eq 0) { Write-Host "✅ Alarme 2 créée" } else { Write-Host "❌ Erreur Alarme 2" }

# ===== ALARME 3: Lambda Duration =====
Write-Host "Création Alarme 3: Lambda Duration..."
aws cloudwatch put-metric-alarm `
  --alarm-name lambda-duration-sim `
  --alarm-description "Lambda duration > 100ms (simulation)" `
  --metric-name Duration `
  --namespace AWS/Lambda `
  --dimensions Name=FunctionName,Value=hello-api `
  --statistic Average `
  --period 300 `
  --threshold 100 `
  --comparison-operator GreaterThanThreshold `
  --evaluation-periods 1 `
  --alarm-actions $TOPIC_ARN `
  --region $REGION

if ($LASTEXITCODE -eq 0) { Write-Host "✅ Alarme 3 créée" } else { Write-Host "❌ Erreur Alarme 3" }

# ===== ALARME 4: RDS Connections =====
Write-Host "Création Alarme 4: RDS Connections..."
aws cloudwatch put-metric-alarm `
  --alarm-name rds-connections-sim `
  --alarm-description "RDS connections > 1 (simulation)" `
  --metric-name DatabaseConnections `
  --namespace AWS/RDS `
  --statistic Average `
  --period 300 `
  --threshold 1 `
  --comparison-operator GreaterThanThreshold `
  --evaluation-periods 1 `
  --alarm-actions $TOPIC_ARN `
  --region $REGION

if ($LASTEXITCODE -eq 0) { Write-Host "✅ Alarme 4 créée" } else { Write-Host "❌ Erreur Alarme 4" }

# ===== ALARME 5: API 5XX Errors =====
Write-Host "Création Alarme 5: API 5XX Errors..."
aws cloudwatch put-metric-alarm `
  --alarm-name api-5xx-errors-sim `
  --alarm-description "API 5XX errors > 0 (simulation)" `
  --metric-name 5XXError `
  --namespace AWS/ApiGateway `
  --dimensions Name=ApiName,Value=hello-api `
  --statistic Sum `
  --period 300 `
  --threshold 0 `
  --comparison-operator GreaterThanThreshold `
  --evaluation-periods 1 `
  --alarm-actions $TOPIC_ARN `
  --region $REGION

if ($LASTEXITCODE -eq 0) { Write-Host "✅ Alarme 5 créée" } else { Write-Host "❌ Erreur Alarme 5" }

# ===== ALARME 6: API Latency =====
Write-Host "Création Alarme 6: API Latency..."
aws cloudwatch put-metric-alarm `
  --alarm-name api-latency-sim `
  --alarm-description "API latency > 100ms (simulation)" `
  --metric-name Latency `
  --namespace AWS/ApiGateway `
  --dimensions Name=ApiName,Value=hello-api `
  --statistic Average `
  --period 300 `
  --threshold 100 `
  --comparison-operator GreaterThanThreshold `
  --evaluation-periods 1 `
  --alarm-actions $TOPIC_ARN `
  --region $REGION

if ($LASTEXITCODE -eq 0) { Write-Host "✅ Alarme 6 créée" } else { Write-Host "❌ Erreur Alarme 6" }

# ===== ALARME 7: DynamoDB Read Throttles =====
Write-Host "Création Alarme 7: DynamoDB Read Throttles..."
aws cloudwatch put-metric-alarm `
  --alarm-name dynamodb-read-throttles-sim `
  --alarm-description "DynamoDB read throttles > 0 (simulation)" `
  --metric-name ReadThrottleEvents `
  --namespace AWS/DynamoDB `
  --statistic Sum `
  --period 300 `
  --threshold 0 `
  --comparison-operator GreaterThanThreshold `
  --evaluation-periods 1 `
  --alarm-actions $TOPIC_ARN `
  --region $REGION

if ($LASTEXITCODE -eq 0) { Write-Host "✅ Alarme 7 créée" } else { Write-Host "❌ Erreur Alarme 7" }

# ===== ALARME 8: DynamoDB Write Throttles =====
Write-Host "Création Alarme 8: DynamoDB Write Throttles..."
aws cloudwatch put-metric-alarm `
  --alarm-name dynamodb-write-throttles-sim `
  --alarm-description "DynamoDB write throttles > 0 (simulation)" `
  --metric-name WriteThrottleEvents `
  --namespace AWS/DynamoDB `
  --statistic Sum `
  --period 300 `
  --threshold 0 `
  --comparison-operator GreaterThanThreshold `
  --evaluation-periods 1 `
  --alarm-actions $TOPIC_ARN `
  --region $REGION

if ($LASTEXITCODE -eq 0) { Write-Host "✅ Alarme 8 créée" } else { Write-Host "❌ Erreur Alarme 8" }

# ===== ALARME 9: EC2 Network =====
Write-Host "Création Alarme 9: EC2 Network In..."
aws cloudwatch put-metric-alarm `
  --alarm-name ec2-network-in-sim `
  --alarm-description "EC2 network in > 1000 bytes (simulation)" `
  --metric-name NetworkIn `
  --namespace AWS/EC2 `
  --statistic Sum `
  --period 300 `
  --threshold 1000 `
  --comparison-operator GreaterThanThreshold `
  --evaluation-periods 1 `
  --alarm-actions $TOPIC_ARN `
  --region $REGION

if ($LASTEXITCODE -eq 0) { Write-Host "✅ Alarme 9 créée" } else { Write-Host "❌ Erreur Alarme 9" }

# ===== ALARME 10: Composite =====
Write-Host "Création Alarme 10: Composite Alarm..."
aws cloudwatch put-composite-alarm `
  --alarm-name production-issues-sim `
  --alarm-description "EC2 OR Lambda issues (simulation)" `
  --alarm-rule "ALARM(ec2-cpu-high-sim) OR ALARM(lambda-errors-sim)" `
  --alarm-actions $TOPIC_ARN `
  --region $REGION

if ($LASTEXITCODE -eq 0) { Write-Host "✅ Alarme 10 créée" } else { Write-Host "❌ Erreur Alarme 10" }

# ===== RÉSUMÉ =====
Write-Host ""
Write-Host "================================"
Write-Host "Setup Terminé!"
Write-Host "================================"
Write-Host ""
Write-Host "Prochaines étapes:"
Write-Host "1. Vérifier les alarmes dans AWS Console"
Write-Host "   CloudWatch > Alarms > All Alarms"
Write-Host ""
Write-Host "2. Tester une alarme manuellement:"
Write-Host "   aws cloudwatch set-alarm-state --alarm-name ec2-cpu-high-sim --state-value ALARM --state-reason 'Test'"
Write-Host ""
Write-Host "3. Vérifier les emails SNS"
Write-Host ""