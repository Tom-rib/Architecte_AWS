#!/bin/bash

# CloudWatch Alarms Setup - 10 Alarmes Optimisées
# Job 5: Surveillance et Alertes avec CloudWatch
#
# Usage:
# chmod +x setup-alarms.sh
# ./setup-alarms.sh
#
# Requirements:
# - AWS CLI installed and configured (aws configure)
# - AWS credentials with CloudWatch permissions
# - SNS Topic créé avec subscribers

# ===== CONFIGURATION =====
# ⚠️ À MODIFIER AVEC VOS VALEURS

# Ton AWS Account ID (ex: 703216717306)
AWS_ACCOUNT_ID="YOUR_AWS_ACCOUNT_ID_HERE"

# Ton SNS Topic Name (le topic doit exister)
SNS_TOPIC_NAME="alerts-production"

# Région AWS
REGION="eu-west-3"

# ===== FIN CONFIGURATION =====

# Construire le Topic ARN
TOPIC_ARN="arn:aws:sns:${REGION}:${AWS_ACCOUNT_ID}:${SNS_TOPIC_NAME}"

echo "================================"
echo "CloudWatch Alarms Setup"
echo "================================"
echo "Topic ARN: $TOPIC_ARN"
echo "Region: $REGION"
echo ""

# Fonction pour créer une alarme métrique
create_metric_alarm() {
    local alarm_name=$1
    local description=$2
    local metric_name=$3
    local namespace=$4
    local threshold=$5
    local stat=${6:-Average}
    local comparison=${7:-GreaterThanOrEqualToThreshold}
    local dimensions=${8:-}

    echo "Création: $alarm_name..."
    
    if [ -z "$dimensions" ]; then
        aws cloudwatch put-metric-alarm \
            --alarm-name "$alarm_name" \
            --alarm-description "$description" \
            --metric-name "$metric_name" \
            --namespace "$namespace" \
            --statistic "$stat" \
            --period 300 \
            --threshold "$threshold" \
            --comparison-operator "$comparison" \
            --evaluation-periods 1 \
            --alarm-actions "$TOPIC_ARN" \
            --region "$REGION" 2>/dev/null
    else
        aws cloudwatch put-metric-alarm \
            --alarm-name "$alarm_name" \
            --alarm-description "$description" \
            --metric-name "$metric_name" \
            --namespace "$namespace" \
            --dimensions $dimensions \
            --statistic "$stat" \
            --period 300 \
            --threshold "$threshold" \
            --comparison-operator "$comparison" \
            --evaluation-periods 1 \
            --alarm-actions "$TOPIC_ARN" \
            --region "$REGION" 2>/dev/null
    fi

    if [ $? -eq 0 ]; then
        echo "✅ $alarm_name créée"
    else
        echo "❌ Erreur $alarm_name"
    fi
}

# ===== ALARME 1: EC2 CPU =====
create_metric_alarm \
    "ec2-cpu-high-sim" \
    "EC2 CPU > 5% (simulation)" \
    "CPUUtilization" \
    "AWS/EC2" \
    "5" \
    "Average" \
    "GreaterThanOrEqualToThreshold"

# ===== ALARME 2: Lambda Errors =====
create_metric_alarm \
    "lambda-errors-sim" \
    "Lambda errors > 0 (simulation)" \
    "Errors" \
    "AWS/Lambda" \
    "0" \
    "Sum" \
    "GreaterThanThreshold" \
    "Name=FunctionName,Value=hello-api"

# ===== ALARME 3: Lambda Duration =====
create_metric_alarm \
    "lambda-duration-sim" \
    "Lambda duration > 100ms (simulation)" \
    "Duration" \
    "AWS/Lambda" \
    "100" \
    "Average" \
    "GreaterThanThreshold" \
    "Name=FunctionName,Value=hello-api"

# ===== ALARME 4: RDS Connections =====
create_metric_alarm \
    "rds-connections-sim" \
    "RDS connections > 1 (simulation)" \
    "DatabaseConnections" \
    "AWS/RDS" \
    "1" \
    "Average" \
    "GreaterThanThreshold"

# ===== ALARME 5: API 5XX Errors =====
aws cloudwatch put-metric-alarm \
    --alarm-name "api-5xx-errors-sim" \
    --alarm-description "API 5XX errors > 0 (simulation)" \
    --metric-name "5XXError" \
    --namespace "AWS/ApiGateway" \
    --dimensions "Name=ApiName,Value=hello-api" \
    --statistic "Sum" \
    --period 300 \
    --threshold 0 \
    --comparison-operator "GreaterThanThreshold" \
    --evaluation-periods 1 \
    --alarm-actions "$TOPIC_ARN" \
    --region "$REGION" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ api-5xx-errors-sim créée"
else
    echo "❌ Erreur api-5xx-errors-sim"
fi

# ===== ALARME 6: API Latency =====
create_metric_alarm \
    "api-latency-sim" \
    "API latency > 100ms (simulation)" \
    "Latency" \
    "AWS/ApiGateway" \
    "100" \
    "Average" \
    "GreaterThanThreshold" \
    "Name=ApiName,Value=hello-api"

# ===== ALARME 7: DynamoDB Read Throttles =====
create_metric_alarm \
    "dynamodb-read-throttles-sim" \
    "DynamoDB read throttles > 0 (simulation)" \
    "ReadThrottleEvents" \
    "AWS/DynamoDB" \
    "0" \
    "Sum" \
    "GreaterThanThreshold"

# ===== ALARME 8: DynamoDB Write Throttles =====
create_metric_alarm \
    "dynamodb-write-throttles-sim" \
    "DynamoDB write throttles > 0 (simulation)" \
    "WriteThrottleEvents" \
    "AWS/DynamoDB" \
    "0" \
    "Sum" \
    "GreaterThanThreshold"

# ===== ALARME 9: EC2 Network =====
create_metric_alarm \
    "ec2-network-in-sim" \
    "EC2 network in > 1000 bytes (simulation)" \
    "NetworkIn" \
    "AWS/EC2" \
    "1000" \
    "Sum" \
    "GreaterThanThreshold"

# ===== ALARME 10: Composite =====
echo "Création Alarme 10: Composite Alarm..."
aws cloudwatch put-composite-alarm \
    --alarm-name "production-issues-sim" \
    --alarm-description "EC2 OR Lambda issues (simulation)" \
    --alarm-rule "ALARM(ec2-cpu-high-sim) OR ALARM(lambda-errors-sim)" \
    --alarm-actions "$TOPIC_ARN" \
    --region "$REGION" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ production-issues-sim créée"
else
    echo "❌ Erreur production-issues-sim"
fi

# ===== RÉSUMÉ =====
echo ""
echo "================================"
echo "Setup Terminé!"
echo "================================"
echo ""
echo "Prochaines étapes:"
echo "1. Vérifier les alarmes dans AWS Console"
echo "   CloudWatch > Alarms > All Alarms"
echo ""
echo "2. Tester une alarme manuellement:"
echo "   aws cloudwatch set-alarm-state --alarm-name ec2-cpu-high-sim --state-value ALARM --state-reason 'Test'"
echo ""
echo "3. Vérifier les emails SNS"
echo ""