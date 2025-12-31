# CLI Commands - Step Functions + Lambda 💻

Toutes les commandes AWS CLI pour Step Functions et Lambda.

---

## 📋 TABLE DES MATIÈRES

1. [Configuration](#-configuration)
2. [Lambda Functions](#-lambda-functions)
3. [State Machines](#-state-machines)
4. [Executions](#-executions)
5. [Monitoring](#-monitoring)
6. [IAM](#-iam)
7. [Scripts utiles](#-scripts-utiles)

---

## ⚙️ CONFIGURATION

### Variables d'environnement

```bash
# Région
export AWS_DEFAULT_REGION=eu-west-3

# Account ID
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Vérifier l'identité
aws sts get-caller-identity
```

---

## 🔧 LAMBDA FUNCTIONS

### Créer une fonction

```bash
# Créer le fichier ZIP
zip function.zip index.py

# Créer la fonction
aws lambda create-function \
  --function-name validate-input \
  --runtime python3.12 \
  --role arn:aws:iam::${AWS_ACCOUNT_ID}:role/lambda-execution-role \
  --handler index.lambda_handler \
  --zip-file fileb://function.zip \
  --timeout 30 \
  --memory-size 256
```

### Lister les fonctions

```bash
# Toutes les fonctions
aws lambda list-functions \
  --query 'Functions[*].[FunctionName,Runtime,MemorySize]' \
  --output table

# Fonctions par préfixe
aws lambda list-functions \
  --query 'Functions[?starts_with(FunctionName, `workflow-`)].[FunctionName]' \
  --output text
```

### Mettre à jour le code

```bash
# Mettre à jour depuis un ZIP
zip function.zip index.py
aws lambda update-function-code \
  --function-name validate-input \
  --zip-file fileb://function.zip

# Mettre à jour la configuration
aws lambda update-function-configuration \
  --function-name validate-input \
  --timeout 60 \
  --memory-size 512
```

### Invoquer une fonction (test)

```bash
# Invocation synchrone
aws lambda invoke \
  --function-name validate-input \
  --payload '{"data": {"email": "test@example.com"}, "userId": "user123"}' \
  --cli-binary-format raw-in-base64-out \
  output.json

# Voir le résultat
cat output.json

# Invocation avec logs
aws lambda invoke \
  --function-name validate-input \
  --payload '{"data": {"email": "test@example.com"}, "userId": "user123"}' \
  --cli-binary-format raw-in-base64-out \
  --log-type Tail \
  output.json \
  --query 'LogResult' \
  --output text | base64 --decode
```

### Supprimer une fonction

```bash
aws lambda delete-function --function-name validate-input
```

### Voir les versions et alias

```bash
# Lister les versions
aws lambda list-versions-by-function \
  --function-name validate-input

# Lister les alias
aws lambda list-aliases \
  --function-name validate-input
```

---

## 🔄 STATE MACHINES

### Créer une State Machine

```bash
# Depuis un fichier JSON
aws stepfunctions create-state-machine \
  --name my-workflow \
  --definition file://state-machine.json \
  --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/step-functions-role \
  --type STANDARD

# Express workflow
aws stepfunctions create-state-machine \
  --name my-express-workflow \
  --definition file://state-machine.json \
  --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/step-functions-role \
  --type EXPRESS \
  --logging-configuration '{
    "level": "ALL",
    "includeExecutionData": true,
    "destinations": [
      {
        "cloudWatchLogsLogGroup": {
          "logGroupArn": "arn:aws:logs:eu-west-3:'${AWS_ACCOUNT_ID}':log-group:/aws/stepfunctions/my-express-workflow:*"
        }
      }
    ]
  }'
```

### Lister les State Machines

```bash
# Toutes
aws stepfunctions list-state-machines \
  --query 'stateMachines[*].[name,stateMachineArn,type]' \
  --output table

# Par nom
aws stepfunctions list-state-machines \
  --query 'stateMachines[?contains(name, `workflow`)]'
```

### Décrire une State Machine

```bash
# Obtenir les détails
aws stepfunctions describe-state-machine \
  --state-machine-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow

# Obtenir juste la définition
aws stepfunctions describe-state-machine \
  --state-machine-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow \
  --query 'definition' \
  --output text | jq .
```

### Mettre à jour une State Machine

```bash
aws stepfunctions update-state-machine \
  --state-machine-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow \
  --definition file://state-machine-v2.json

# Mettre à jour le rôle IAM
aws stepfunctions update-state-machine \
  --state-machine-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow \
  --role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/new-role
```

### Supprimer une State Machine

```bash
aws stepfunctions delete-state-machine \
  --state-machine-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow
```

---

## ▶️ EXECUTIONS

### Démarrer une exécution

```bash
# Exécution simple
aws stepfunctions start-execution \
  --state-machine-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow \
  --input '{"orderId": "123", "amount": 99.99}'

# Avec un nom personnalisé
aws stepfunctions start-execution \
  --state-machine-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow \
  --name "order-123-$(date +%s)" \
  --input '{"orderId": "123", "amount": 99.99}'

# Depuis un fichier
aws stepfunctions start-execution \
  --state-machine-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow \
  --input file://input.json
```

### Lister les exécutions

```bash
# Toutes les exécutions
aws stepfunctions list-executions \
  --state-machine-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow

# Exécutions en cours
aws stepfunctions list-executions \
  --state-machine-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow \
  --status-filter RUNNING

# Exécutions échouées
aws stepfunctions list-executions \
  --state-machine-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow \
  --status-filter FAILED \
  --query 'executions[*].[name,startDate,stopDate]' \
  --output table

# Les 10 dernières
aws stepfunctions list-executions \
  --state-machine-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow \
  --max-results 10
```

### Décrire une exécution

```bash
# Détails complets
aws stepfunctions describe-execution \
  --execution-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:execution:my-workflow:execution-name

# Statut seulement
aws stepfunctions describe-execution \
  --execution-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:execution:my-workflow:execution-name \
  --query 'status'

# Input et output
aws stepfunctions describe-execution \
  --execution-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:execution:my-workflow:execution-name \
  --query '[input,output]'
```

### Historique d'une exécution

```bash
# Tous les événements
aws stepfunctions get-execution-history \
  --execution-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:execution:my-workflow:execution-name

# Événements formatés
aws stepfunctions get-execution-history \
  --execution-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:execution:my-workflow:execution-name \
  --query 'events[*].[timestamp,type,stateEnteredEventDetails.name]' \
  --output table

# Seulement les erreurs
aws stepfunctions get-execution-history \
  --execution-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:execution:my-workflow:execution-name \
  --query 'events[?contains(type, `Failed`) || contains(type, `Error`)]'
```

### Arrêter une exécution

```bash
aws stepfunctions stop-execution \
  --execution-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:execution:my-workflow:execution-name \
  --error "ManualStop" \
  --cause "Stopped by administrator"
```

### Redémarrer une exécution (redemarre avec le même input)

```bash
# Récupérer l'input de l'ancienne exécution
INPUT=$(aws stepfunctions describe-execution \
  --execution-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:execution:my-workflow:failed-execution \
  --query 'input' \
  --output text)

# Relancer
aws stepfunctions start-execution \
  --state-machine-arn arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow \
  --input "$INPUT"
```

---

## 📊 MONITORING

### Logs CloudWatch

```bash
# Créer le log group
aws logs create-log-group \
  --log-group-name /aws/stepfunctions/my-workflow

# Définir la rétention
aws logs put-retention-policy \
  --log-group-name /aws/stepfunctions/my-workflow \
  --retention-in-days 30

# Voir les derniers logs
aws logs tail /aws/stepfunctions/my-workflow --since 1h

# Suivre en temps réel
aws logs tail /aws/stepfunctions/my-workflow --follow
```

### Métriques CloudWatch

```bash
# Exécutions réussies (dernière heure)
aws cloudwatch get-metric-statistics \
  --namespace AWS/States \
  --metric-name ExecutionsSucceeded \
  --dimensions Name=StateMachineArn,Value=arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Sum

# Exécutions échouées
aws cloudwatch get-metric-statistics \
  --namespace AWS/States \
  --metric-name ExecutionsFailed \
  --dimensions Name=StateMachineArn,Value=arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Sum
```

### Créer une alarme

```bash
# Alarme si exécution échoue
aws cloudwatch put-metric-alarm \
  --alarm-name "StepFunctions-Failures" \
  --alarm-description "Step Functions execution failed" \
  --metric-name ExecutionsFailed \
  --namespace AWS/States \
  --statistic Sum \
  --period 60 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 1 \
  --dimensions Name=StateMachineArn,Value=arn:aws:states:eu-west-3:${AWS_ACCOUNT_ID}:stateMachine:my-workflow \
  --alarm-actions arn:aws:sns:eu-west-3:${AWS_ACCOUNT_ID}:alerts
```

---

## 🔐 IAM

### Créer le rôle Step Functions

```bash
# Trust policy
cat > trust-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Créer le rôle
aws iam create-role \
  --role-name step-functions-role \
  --assume-role-policy-document file://trust-policy.json
```

### Policy pour invoquer Lambda

```bash
# Lambda invoke policy
cat > lambda-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": [
        "arn:aws:lambda:eu-west-3:*:function:validate-input",
        "arn:aws:lambda:eu-west-3:*:function:process-data",
        "arn:aws:lambda:eu-west-3:*:function:send-notification"
      ]
    }
  ]
}
EOF

# Attacher la policy
aws iam put-role-policy \
  --role-name step-functions-role \
  --policy-name LambdaInvokePolicy \
  --policy-document file://lambda-policy.json
```

### Policy pour CloudWatch Logs

```bash
cat > logs-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogDelivery",
        "logs:GetLogDelivery",
        "logs:UpdateLogDelivery",
        "logs:DeleteLogDelivery",
        "logs:ListLogDeliveries",
        "logs:PutLogEvents",
        "logs:PutResourcePolicy",
        "logs:DescribeResourcePolicies",
        "logs:DescribeLogGroups"
      ],
      "Resource": "*"
    }
  ]
}
EOF

aws iam put-role-policy \
  --role-name step-functions-role \
  --policy-name CloudWatchLogsPolicy \
  --policy-document file://logs-policy.json
```

### Créer le rôle Lambda

```bash
# Trust policy pour Lambda
cat > lambda-trust.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws iam create-role \
  --role-name lambda-execution-role \
  --assume-role-policy-document file://lambda-trust.json

# Attacher la policy de base
aws iam attach-role-policy \
  --role-name lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

---

## 📋 SCRIPTS UTILES

### Déployer le workflow complet

```bash
#!/bin/bash
set -e

REGION="eu-west-3"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "=== Déploiement des fonctions Lambda ==="

# Deploy Lambda functions
for func in validate-input process-data send-notification; do
  echo "Déploiement de $func..."
  cd lambda/$func
  zip -r function.zip .
  
  # Créer ou mettre à jour
  if aws lambda get-function --function-name $func 2>/dev/null; then
    aws lambda update-function-code \
      --function-name $func \
      --zip-file fileb://function.zip
  else
    aws lambda create-function \
      --function-name $func \
      --runtime python3.12 \
      --role arn:aws:iam::${ACCOUNT_ID}:role/lambda-execution-role \
      --handler index.lambda_handler \
      --zip-file fileb://function.zip
  fi
  
  rm function.zip
  cd ../..
done

echo "=== Déploiement de la State Machine ==="

# Remplacer les ARN dans la définition
sed "s/\${AWS_ACCOUNT_ID}/${ACCOUNT_ID}/g; s/\${REGION}/${REGION}/g" \
  state-machine-template.json > state-machine.json

# Créer ou mettre à jour
SM_ARN="arn:aws:states:${REGION}:${ACCOUNT_ID}:stateMachine:my-workflow"

if aws stepfunctions describe-state-machine --state-machine-arn $SM_ARN 2>/dev/null; then
  aws stepfunctions update-state-machine \
    --state-machine-arn $SM_ARN \
    --definition file://state-machine.json
else
  aws stepfunctions create-state-machine \
    --name my-workflow \
    --definition file://state-machine.json \
    --role-arn arn:aws:iam::${ACCOUNT_ID}:role/step-functions-role
fi

echo "=== Déploiement terminé ==="
```

### Tester le workflow

```bash
#!/bin/bash

REGION="eu-west-3"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
SM_ARN="arn:aws:states:${REGION}:${ACCOUNT_ID}:stateMachine:my-workflow"

# Lancer l'exécution
echo "Lancement de l'exécution..."
EXEC_ARN=$(aws stepfunctions start-execution \
  --state-machine-arn $SM_ARN \
  --input '{"data": {"email": "test@example.com", "items": [{"name": "Item1", "price": 10}]}, "userId": "user123"}' \
  --query 'executionArn' \
  --output text)

echo "Execution ARN: $EXEC_ARN"

# Attendre la fin
echo "En attente de la fin..."
while true; do
  STATUS=$(aws stepfunctions describe-execution \
    --execution-arn $EXEC_ARN \
    --query 'status' \
    --output text)
  
  echo "Status: $STATUS"
  
  if [ "$STATUS" != "RUNNING" ]; then
    break
  fi
  
  sleep 2
done

# Afficher le résultat
echo ""
echo "=== Résultat ==="
aws stepfunctions describe-execution \
  --execution-arn $EXEC_ARN \
  --query '[status,output]'
```

### Nettoyer les exécutions échouées

```bash
#!/bin/bash

REGION="eu-west-3"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
SM_ARN="arn:aws:states:${REGION}:${ACCOUNT_ID}:stateMachine:my-workflow"

echo "Recherche des exécutions échouées..."

FAILED=$(aws stepfunctions list-executions \
  --state-machine-arn $SM_ARN \
  --status-filter FAILED \
  --query 'executions[*].executionArn' \
  --output text)

echo "Exécutions échouées trouvées: $(echo $FAILED | wc -w)"

# Optionnel: relancer les échouées
# for arn in $FAILED; do
#   INPUT=$(aws stepfunctions describe-execution --execution-arn $arn --query 'input' --output text)
#   aws stepfunctions start-execution --state-machine-arn $SM_ARN --input "$INPUT"
# done
```

---

## 🔗 LIENS

- **Step Functions** → [01-StepFunctions-Concepts-Complets.md](./01-StepFunctions-Concepts-Complets.md)
- **Lambda** → [02-Lambda-Workflows.md](./02-Lambda-Workflows.md)
- **ASL Language** → [03-ASL-States-Language.md](./03-ASL-States-Language.md)
- **Troubleshooting** → [Troubleshooting.md](./Troubleshooting.md)

---

[⬅️ Retour au README](./README.md)
