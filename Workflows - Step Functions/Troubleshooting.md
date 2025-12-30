# Troubleshooting - Step Functions + Lambda 🔧

Guide de résolution des problèmes courants.

---

## 📋 TABLE DES MATIÈRES

1. [State Machine - Création](#-state-machine---création)
2. [Lambda - Invocation](#-lambda---invocation)
3. [IAM - Permissions](#-iam---permissions)
4. [Executions - Échecs](#-executions---échecs)
5. [Input/Output - Données](#-inputoutput---données)
6. [Timeouts](#-timeouts)
7. [Logs et Monitoring](#-logs-et-monitoring)
8. [Performance](#-performance)

---

## 📝 STATE MACHINE - CRÉATION

### ❌ "Invalid State Machine Definition"

**Cause :** JSON ASL invalide

**Solutions :**
```bash
# 1. Valider le JSON
cat state-machine.json | jq .

# 2. Erreurs courantes :
# - Virgule manquante ou en trop
# - Guillemets manquants
# - StartAt pointe vers un état inexistant
# - État sans Next ni End:true
```

**Checklist JSON :**
```json
{
  "StartAt": "FirstState",    // ✅ Doit exister dans States
  "States": {
    "FirstState": {
      "Type": "Task",         // ✅ Type obligatoire
      "Resource": "arn:...",  // ✅ ARN valide
      "Next": "SecondState"   // ✅ Ou "End": true
    },
    "SecondState": {
      "Type": "Succeed"       // ✅ État terminal
    }
  }
}
```

---

### ❌ "Invalid Resource"

**Cause :** ARN Lambda incorrect

**Solutions :**
```bash
# Vérifier que la fonction existe
aws lambda get-function --function-name ma-fonction

# Format correct de l'ARN
arn:aws:lambda:eu-west-3:123456789012:function:ma-fonction

# ❌ Erreurs courantes
arn:aws:lambda:eu-west-3:123456789012:function:ma-fonction:   # Trailing colon
arn:aws:lambda:eu-west-3:123456789:function:ma-fonction       # Account ID incorrect
arn:lambda:eu-west-3:123456789012:function:ma-fonction        # Missing "aws:"
```

---

### ❌ "Circular dependency detected"

**Cause :** Boucle infinie dans les états

**Solution :**
```json
// ❌ Mauvais - boucle infinie
{
  "StateA": { "Next": "StateB" },
  "StateB": { "Next": "StateA" }  // Retour à StateA
}

// ✅ Bon - condition de sortie
{
  "StateA": { "Next": "CheckCondition" },
  "CheckCondition": {
    "Type": "Choice",
    "Choices": [
      { "Variable": "$.done", "BooleanEquals": true, "Next": "End" }
    ],
    "Default": "StateA"
  },
  "End": { "Type": "Succeed" }
}
```

---

## 🔧 LAMBDA - INVOCATION

### ❌ "Lambda.Unknown" ou "Lambda.ServiceException"

**Causes et solutions :**

| Cause | Solution |
|-------|----------|
| Fonction n'existe pas | Vérifier le nom/ARN |
| Région différente | Vérifier la région dans l'ARN |
| Lambda en erreur | Tester la Lambda directement |

```bash
# Tester Lambda directement
aws lambda invoke \
  --function-name validate-input \
  --payload '{"test": "data"}' \
  --cli-binary-format raw-in-base64-out \
  output.json

cat output.json
```

---

### ❌ "Lambda.TooManyRequestsException"

**Cause :** Throttling Lambda (trop de requêtes)

**Solutions :**
```json
// 1. Ajouter Retry avec backoff
{
  "Retry": [
    {
      "ErrorEquals": ["Lambda.TooManyRequestsException"],
      "IntervalSeconds": 1,
      "MaxAttempts": 5,
      "BackoffRate": 2
    }
  ]
}
```

```bash
# 2. Augmenter la concurrence réservée
aws lambda put-function-concurrency \
  --function-name ma-fonction \
  --reserved-concurrent-executions 100
```

---

### ❌ Lambda retourne une erreur

**Debug :**
```bash
# 1. Voir les logs Lambda
aws logs tail /aws/lambda/ma-fonction --since 10m

# 2. Voir l'historique de l'exécution
aws stepfunctions get-execution-history \
  --execution-arn arn:aws:states:... \
  --query 'events[?type==`LambdaFunctionFailed`]'
```

**Dans Lambda, lever des erreurs explicites :**
```python
# Python
class ValidationError(Exception):
    pass

def lambda_handler(event, context):
    if not event.get('data'):
        raise ValidationError("Missing data field")
```

---

## 🔐 IAM - PERMISSIONS

### ❌ "AccessDeniedException" ou "States.Permissions"

**Cause :** Step Functions n'a pas le droit d'invoquer Lambda

**Solution :**
```bash
# Vérifier le rôle de la State Machine
aws stepfunctions describe-state-machine \
  --state-machine-arn arn:aws:states:... \
  --query 'roleArn'

# Vérifier les policies du rôle
aws iam list-role-policies --role-name step-functions-role
aws iam list-attached-role-policies --role-name step-functions-role

# Ajouter la permission Lambda
aws iam put-role-policy \
  --role-name step-functions-role \
  --policy-name LambdaInvoke \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": "lambda:InvokeFunction",
      "Resource": "arn:aws:lambda:eu-west-3:*:function:*"
    }]
  }'
```

---

### ❌ Lambda ne peut pas accéder à S3/DynamoDB

**Cause :** Le rôle Lambda manque de permissions

**Solution :**
```bash
# Voir le rôle Lambda
aws lambda get-function --function-name ma-fonction \
  --query 'Configuration.Role'

# Ajouter les permissions nécessaires
aws iam put-role-policy \
  --role-name lambda-execution-role \
  --policy-name DynamoDBAccess \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": ["dynamodb:GetItem", "dynamodb:PutItem"],
      "Resource": "arn:aws:dynamodb:eu-west-3:*:table/MyTable"
    }]
  }'
```

---

## 💥 EXECUTIONS - ÉCHECS

### ❌ Exécution en status "FAILED"

**Debug :**
```bash
# 1. Voir la raison de l'échec
aws stepfunctions describe-execution \
  --execution-arn arn:aws:states:... \
  --query '[status,error,cause]'

# 2. Voir l'historique complet
aws stepfunctions get-execution-history \
  --execution-arn arn:aws:states:... \
  --query 'events[?contains(type, `Failed`)]'

# 3. Trouver l'état qui a échoué
aws stepfunctions get-execution-history \
  --execution-arn arn:aws:states:... \
  --query 'events[-5:].[type,stateEnteredEventDetails,executionFailedEventDetails]'
```

---

### ❌ "States.Runtime" error

**Cause :** Erreur dans l'ASL (JSONPath invalide, etc.)

**Causes courantes :**
```json
// ❌ JSONPath invalide
"Variable": "$.data[0"  // Crochet non fermé

// ❌ Référence à un champ inexistant
"Variable": "$.nonexistent.field"  // Si le champ n'existe pas

// ✅ Utiliser IsPresent pour vérifier
{
  "Variable": "$.optionalField",
  "IsPresent": true,
  "Next": "FieldExists"
}
```

---

### ❌ "States.NoChoiceMatched"

**Cause :** Aucune condition Choice n'est satisfaite et pas de Default

**Solution :**
```json
{
  "Type": "Choice",
  "Choices": [
    { "Variable": "$.status", "StringEquals": "OK", "Next": "Success" }
  ],
  "Default": "HandleUnknown"  // ✅ TOUJOURS avoir un Default
}
```

---

## 📥📤 INPUT/OUTPUT - DONNÉES

### ❌ "States.ResultPathMatchFailure"

**Cause :** ResultPath pointe vers un chemin invalide

**Solutions :**
```json
// ❌ Mauvais - essayer de remplacer une valeur scalaire
// Si input = {"name": "John"}
"ResultPath": "$.name.result"  // Erreur! $.name est une string

// ✅ Bon
"ResultPath": "$.processingResult"  // Nouveau champ
```

---

### ❌ Données perdues entre les états

**Cause :** OutputPath filtre trop de données

**Debug :**
```json
// Temporairement, désactiver le filtrage
{
  "Type": "Task",
  "Resource": "...",
  // "OutputPath": "$.result",  // Commenter pour debug
  "Next": "..."
}
```

**Solution :**
```json
// Utiliser ResultPath pour AJOUTER au lieu de REMPLACER
{
  "Type": "Task",
  "Resource": "...",
  "ResultPath": "$.taskResult",  // Ajoute le résultat
  "Next": "..."
}
```

---

### ❌ "The JSONPath could not be found"

**Cause :** Le chemin référencé n'existe pas dans l'input

**Solutions :**
```json
// 1. Vérifier l'input avec un état Pass
{
  "DebugInput": {
    "Type": "Pass",
    "Next": "RealTask"
  }
}

// 2. Utiliser IsPresent avant d'accéder
{
  "Type": "Choice",
  "Choices": [
    {
      "Variable": "$.optionalField",
      "IsPresent": true,
      "Next": "UseField"
    }
  ],
  "Default": "NoField"
}
```

---

### ❌ Payload > 256 KB

**Cause :** Trop de données passées entre états

**Solutions :**
1. **Réduire les données :** Ne passer que les IDs
2. **Utiliser S3 :** Stocker les gros payloads dans S3
3. **Utiliser DynamoDB :** Stocker temporairement

```python
# Lambda qui stocke dans S3
import boto3
import json

s3 = boto3.client('s3')

def lambda_handler(event, context):
    large_data = process(event)
    
    # Stocker dans S3
    key = f"workflow/{event['executionId']}/data.json"
    s3.put_object(
        Bucket='my-workflow-data',
        Key=key,
        Body=json.dumps(large_data)
    )
    
    # Retourner juste la référence
    return {
        's3_bucket': 'my-workflow-data',
        's3_key': key
    }
```

---

## ⏱️ TIMEOUTS

### ❌ "States.Timeout"

**Cause :** L'état a dépassé son timeout

**Solutions :**
```json
// 1. Augmenter le timeout de l'état
{
  "Type": "Task",
  "Resource": "...",
  "TimeoutSeconds": 300,  // 5 minutes
  "Next": "..."
}

// 2. Augmenter le timeout Lambda
aws lambda update-function-configuration \
  --function-name ma-fonction \
  --timeout 300
```

---

### ❌ Lambda timeout (15 min max)

**Cause :** Traitement trop long pour Lambda

**Solutions :**
1. **Callback pattern :** Pour les tâches > 15 min
2. **Découper en étapes :** Plusieurs Lambda + Map state
3. **Utiliser ECS/Batch :** Pour les longs traitements

```json
// Callback pattern
{
  "StartLongTask": {
    "Type": "Task",
    "Resource": "arn:aws:states:::lambda:invoke.waitForTaskToken",
    "Parameters": {
      "FunctionName": "start-long-task",
      "Payload": {
        "taskToken.$": "$$.Task.Token",
        "data.$": "$.data"
      }
    },
    "TimeoutSeconds": 3600,  // 1 heure
    "Next": "ProcessResult"
  }
}
```

---

### ❌ "States.HeartbeatTimeout"

**Cause :** Heartbeat manquant pour les tâches longues

**Solution :**
```python
import boto3

sfn = boto3.client('stepfunctions')

def lambda_handler(event, context):
    task_token = event['taskToken']
    
    for item in event['items']:
        # Envoyer heartbeat
        sfn.send_task_heartbeat(taskToken=task_token)
        
        # Traiter l'item
        process(item)
    
    # Terminer la tâche
    sfn.send_task_success(
        taskToken=task_token,
        output=json.dumps({"status": "complete"})
    )
```

---

## 📊 LOGS ET MONITORING

### ❌ Pas de logs CloudWatch

**Causes et solutions :**

```bash
# 1. Vérifier que le logging est activé
aws stepfunctions describe-state-machine \
  --state-machine-arn arn:aws:states:... \
  --query 'loggingConfiguration'

# 2. Activer le logging
aws stepfunctions update-state-machine \
  --state-machine-arn arn:aws:states:... \
  --logging-configuration '{
    "level": "ALL",
    "includeExecutionData": true,
    "destinations": [{
      "cloudWatchLogsLogGroup": {
        "logGroupArn": "arn:aws:logs:eu-west-3:123456789:log-group:/aws/stepfunctions/my-workflow:*"
      }
    }]
  }'

# 3. Créer le log group si nécessaire
aws logs create-log-group --log-group-name /aws/stepfunctions/my-workflow

# 4. Vérifier les permissions CloudWatch du rôle Step Functions
```

---

### ❌ Logs Lambda manquants

**Solutions :**
```bash
# Vérifier que le log group existe
aws logs describe-log-groups \
  --log-group-name-prefix /aws/lambda/ma-fonction

# Vérifier les permissions Lambda
aws iam list-attached-role-policies \
  --role-name lambda-execution-role
# Doit contenir AWSLambdaBasicExecutionRole
```

---

## ⚡ PERFORMANCE

### ❌ Workflow trop lent

**Diagnostics :**
```bash
# Voir la durée de chaque état
aws stepfunctions get-execution-history \
  --execution-arn arn:aws:states:... \
  --query 'events[?type==`TaskStateEntered` || type==`TaskStateExited`].[timestamp,stateEnteredEventDetails.name]'
```

**Solutions :**

| Problème | Solution |
|----------|----------|
| Lambda cold start | Provisioned Concurrency |
| Séquentiel inutile | Parallel state |
| Trop de données | Réduire payload |
| Polling | Event-driven avec callbacks |

---

### ❌ Coûts élevés

**Diagnostics :**
```bash
# Compter les transitions
aws stepfunctions get-execution-history \
  --execution-arn arn:aws:states:... \
  --query 'length(events)'
```

**Optimisations :**
- Moins d'états = moins de transitions
- Utiliser Express pour workflows courts
- Combiner des étapes quand possible
- Map avec MaxConcurrency raisonnable

---

## ✅ CHECKLIST DEBUG

```
□ JSON ASL valide (jq .)
□ ARN Lambda corrects
□ IAM Step Functions → Lambda
□ IAM Lambda → autres services
□ Input/Output paths valides
□ Timeouts appropriés
□ Retry configurés
□ Catch avec Default
□ Logs activés
□ Tests avec données réelles
```

---

## 🔗 LIENS

- **CLI Commands** → [CLI-Commands.md](./CLI-Commands.md)
- **Step Functions** → [01-StepFunctions-Concepts-Complets.md](./01-StepFunctions-Concepts-Complets.md)
- **Error Handling** → [06-Error-Handling.md](./06-Error-Handling.md)
- **ASL Language** → [03-ASL-States-Language.md](./03-ASL-States-Language.md)

---

[⬅️ Retour au README](./README.md)
