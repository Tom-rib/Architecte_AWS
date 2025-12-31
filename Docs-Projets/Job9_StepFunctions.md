# Job 9 : Step Functions - Orchestration de workflows ⚡

> Automatiser une série de tâches Lambda avec une machine d'état

---

## 🎯 Objectif

Automatiser une série de tâches de calcul sans serveur pour un flux de travail d'application en utilisant Step Functions pour orchestrer plusieurs fonctions Lambda.

---

## 📦 Ressources AWS Utilisées

| Service | Rôle |
|---------|------|
| Step Functions | Orchestration de workflows |
| Lambda | Fonctions serverless |
| CloudWatch | Monitoring et logs |
| IAM | Permissions |

---

## 💰 Coûts

| Service | Free Tier |
|---------|-----------|
| Step Functions | 4000 transitions/mois |
| Lambda | 1M requêtes/mois |
| CloudWatch | 5 GB logs gratuits |

✅ **Entièrement gratuit pour ce projet**

---

## 🏗️ Architecture

```
Step Functions (State Machine)
    │
    ├── État 1 : ValidateInput (Lambda)
    │
    ├── État 2 : ProcessData (Lambda)
    │
    ├── Choice : Succès ou Échec ?
    │   │
    │   ├── Succès → État 3 : SendNotification (Lambda)
    │   │
    │   └── Échec → État 4 : HandleError (Lambda)
    │
    └── End
```

---

# Étape 1 : Créer les fonctions Lambda

## Lambda 1 : ValidateInput

### 🖥️ Dashboard

```
1. Lambda → Create function

2. Function name : ValidateInput

3. Runtime : Python 3.11

4. Create function ✓

5. Collez le code ci-dessous → Deploy
```

### Code Python

```python
import json

def lambda_handler(event, context):
    """
    Valide les données d'entrée du workflow.
    """
    print(f"ValidateInput - Event reçu: {json.dumps(event)}")
    
    # Vérifier les champs requis
    required_fields = ['name', 'email', 'amount']
    
    for field in required_fields:
        if field not in event:
            return {
                'statusCode': 400,
                'isValid': False,
                'error': f'Champ manquant: {field}',
                'input': event
            }
    
    # Vérifier que amount est positif
    if event['amount'] <= 0:
        return {
            'statusCode': 400,
            'isValid': False,
            'error': 'Le montant doit être positif',
            'input': event
        }
    
    # Validation réussie
    return {
        'statusCode': 200,
        'isValid': True,
        'message': 'Validation réussie',
        'data': event
    }
```

## Lambda 2 : ProcessData

### 🖥️ Dashboard

```
1. Lambda → Create function

2. Function name : ProcessData

3. Runtime : Python 3.11

4. Create function ✓

5. Collez le code ci-dessous → Deploy
```

### Code Python

```python
import json
from datetime import datetime
import random

def lambda_handler(event, context):
    """
    Traite les données validées.
    """
    print(f"ProcessData - Event reçu: {json.dumps(event)}")
    
    # Récupérer les données de l'étape précédente
    data = event.get('data', event)
    
    # Simuler un traitement
    processed_data = {
        'orderId': f"ORD-{random.randint(10000, 99999)}",
        'customer': data.get('name'),
        'email': data.get('email'),
        'amount': data.get('amount'),
        'tax': round(data.get('amount', 0) * 0.20, 2),
        'total': round(data.get('amount', 0) * 1.20, 2),
        'processedAt': datetime.utcnow().isoformat(),
        'status': 'PROCESSED'
    }
    
    return {
        'statusCode': 200,
        'isProcessed': True,
        'message': 'Traitement terminé',
        'result': processed_data
    }
```

## Lambda 3 : SendNotification

### 🖥️ Dashboard

```
1. Lambda → Create function

2. Function name : SendNotification

3. Runtime : Python 3.11

4. Create function ✓

5. Collez le code ci-dessous → Deploy
```

### Code Python

```python
import json
from datetime import datetime

def lambda_handler(event, context):
    """
    Envoie une notification de succès.
    """
    print(f"SendNotification - Event reçu: {json.dumps(event)}")
    
    result = event.get('result', {})
    
    # Simuler l'envoi d'un email
    notification = {
        'type': 'EMAIL',
        'to': result.get('email', 'unknown@example.com'),
        'subject': f"Commande {result.get('orderId', 'N/A')} confirmée",
        'body': f"""
        Bonjour {result.get('customer', 'Client')},
        
        Votre commande a été traitée avec succès.
        
        Détails :
        - Numéro de commande : {result.get('orderId')}
        - Montant HT : {result.get('amount')}€
        - TVA (20%) : {result.get('tax')}€
        - Total TTC : {result.get('total')}€
        
        Merci pour votre confiance !
        """,
        'sentAt': datetime.utcnow().isoformat(),
        'status': 'SENT'
    }
    
    return {
        'statusCode': 200,
        'message': 'Notification envoyée',
        'notification': notification,
        'workflowStatus': 'COMPLETED'
    }
```

## Lambda 4 : HandleError

### 🖥️ Dashboard

```
1. Lambda → Create function

2. Function name : HandleError

3. Runtime : Python 3.11

4. Create function ✓

5. Collez le code ci-dessous → Deploy
```

### Code Python

```python
import json
from datetime import datetime

def lambda_handler(event, context):
    """
    Gère les erreurs du workflow.
    """
    print(f"HandleError - Event reçu: {json.dumps(event)}")
    
    error_info = {
        'errorType': 'VALIDATION_ERROR',
        'errorMessage': event.get('error', 'Erreur inconnue'),
        'originalInput': event.get('input', {}),
        'timestamp': datetime.utcnow().isoformat(),
        'workflowStatus': 'FAILED'
    }
    
    # Ici on pourrait envoyer une alerte SNS
    
    return {
        'statusCode': 400,
        'message': 'Workflow échoué',
        'errorDetails': error_info
    }
```

## 💻 CLI - Créer toutes les fonctions

```bash
# Créer le rôle IAM pour Lambda
aws iam create-role \
  --role-name StepFunctionsLambdaRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

aws iam attach-role-policy \
  --role-name StepFunctionsLambdaRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# Attendre la propagation
sleep 10

# Créer chaque fonction Lambda (répéter pour chaque)
# ValidateInput, ProcessData, SendNotification, HandleError
```

---

# Étape 2 : Créer le rôle IAM pour Step Functions

## 🖥️ Dashboard

```
1. IAM → Roles → Create role

2. Trusted entity : AWS service
   Use case : Step Functions

3. Next

4. Permissions : (automatiquement ajoutées)
   - AWSLambdaRole

5. Role name : StepFunctionsExecutionRole

6. Create role ✓
```

## 💻 CLI

```bash
# Créer le rôle pour Step Functions
aws iam create-role \
  --role-name StepFunctionsExecutionRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "states.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attacher la policy pour invoquer Lambda
aws iam put-role-policy \
  --role-name StepFunctionsExecutionRole \
  --policy-name InvokeLambda \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": ["lambda:InvokeFunction"],
      "Resource": "*"
    }]
  }'
```

---

# Étape 3 : Créer la State Machine

## 🖥️ Dashboard

```
1. Step Functions → State machines → Create state machine

2. Choose authoring method : Write your workflow in code

3. Type : Standard

4. Definition : (collez le JSON ci-dessous)
```

### Definition JSON (ASL - Amazon States Language)

```json
{
  "Comment": "Workflow de traitement de commande",
  "StartAt": "ValidateInput",
  "States": {
    "ValidateInput": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:eu-west-3:ACCOUNT_ID:function:ValidateInput",
      "Next": "CheckValidation",
      "Catch": [{
        "ErrorEquals": ["States.ALL"],
        "Next": "HandleError"
      }]
    },
    "CheckValidation": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.isValid",
          "BooleanEquals": true,
          "Next": "ProcessData"
        }
      ],
      "Default": "HandleError"
    },
    "ProcessData": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:eu-west-3:ACCOUNT_ID:function:ProcessData",
      "Next": "SendNotification",
      "Catch": [{
        "ErrorEquals": ["States.ALL"],
        "Next": "HandleError"
      }]
    },
    "SendNotification": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:eu-west-3:ACCOUNT_ID:function:SendNotification",
      "End": true
    },
    "HandleError": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:eu-west-3:ACCOUNT_ID:function:HandleError",
      "End": true
    }
  }
}
```

⚠️ **Remplacez `ACCOUNT_ID` par votre ID de compte AWS !**

```
5. Next

6. State machine name : OrderProcessingWorkflow

7. Permissions : Choose an existing role
   - StepFunctionsExecutionRole

8. Logging : OFF (ou ALL pour debug)

9. Create state machine ✓
```

## 💻 CLI

```bash
# Récupérer l'Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Créer le fichier de définition
cat > state-machine.json << EOF
{
  "Comment": "Workflow de traitement de commande",
  "StartAt": "ValidateInput",
  "States": {
    "ValidateInput": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:eu-west-3:${ACCOUNT_ID}:function:ValidateInput",
      "Next": "CheckValidation",
      "Catch": [{"ErrorEquals": ["States.ALL"], "Next": "HandleError"}]
    },
    "CheckValidation": {
      "Type": "Choice",
      "Choices": [
        {"Variable": "$.isValid", "BooleanEquals": true, "Next": "ProcessData"}
      ],
      "Default": "HandleError"
    },
    "ProcessData": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:eu-west-3:${ACCOUNT_ID}:function:ProcessData",
      "Next": "SendNotification",
      "Catch": [{"ErrorEquals": ["States.ALL"], "Next": "HandleError"}]
    },
    "SendNotification": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:eu-west-3:${ACCOUNT_ID}:function:SendNotification",
      "End": true
    },
    "HandleError": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:eu-west-3:${ACCOUNT_ID}:function:HandleError",
      "End": true
    }
  }
}
EOF

# Créer la state machine
aws stepfunctions create-state-machine \
  --name OrderProcessingWorkflow \
  --definition file://state-machine.json \
  --role-arn arn:aws:iam::${ACCOUNT_ID}:role/StepFunctionsExecutionRole \
  --region eu-west-3
```

---

# Étape 4 : Tester le workflow

## 🖥️ Dashboard

### Test 1 : Exécution réussie

```
1. Step Functions → State machines → OrderProcessingWorkflow

2. Start execution

3. Input :
```

```json
{
  "name": "Jean Dupont",
  "email": "jean@example.com",
  "amount": 150.00
}
```

```
4. Start execution ✓

5. Observez le Graph inspector :
   - ValidateInput → vert ✓
   - CheckValidation → vert ✓
   - ProcessData → vert ✓
   - SendNotification → vert ✓

6. Cliquez sur chaque étape pour voir les Input/Output
```

### Test 2 : Exécution avec erreur (validation)

```
1. Start execution

2. Input :
```

```json
{
  "name": "Test Error",
  "email": "test@example.com"
}
```

```
3. Start execution ✓

4. Observez :
   - ValidateInput → vert ✓
   - CheckValidation → (choice vers HandleError)
   - HandleError → vert ✓
   
5. Le workflow va dans HandleError car "amount" manque
```

### Test 3 : Montant négatif

```json
{
  "name": "Test Negative",
  "email": "neg@example.com",
  "amount": -50
}
```

## 💻 CLI

```bash
# Récupérer l'ARN de la state machine
SM_ARN=$(aws stepfunctions list-state-machines \
  --query 'stateMachines[?name==`OrderProcessingWorkflow`].stateMachineArn' \
  --output text \
  --region eu-west-3)

# Exécuter le workflow
aws stepfunctions start-execution \
  --state-machine-arn $SM_ARN \
  --input '{"name":"CLI Test","email":"cli@example.com","amount":200}' \
  --region eu-west-3

# Lister les exécutions
aws stepfunctions list-executions \
  --state-machine-arn $SM_ARN \
  --query 'executions[*].[name,status,startDate]' \
  --output table \
  --region eu-west-3
```

---

# Étape 5 : Voir les logs CloudWatch

## 🖥️ Dashboard

```
1. CloudWatch → Log groups

2. Groupes de logs Lambda :
   - /aws/lambda/ValidateInput
   - /aws/lambda/ProcessData
   - /aws/lambda/SendNotification
   - /aws/lambda/HandleError

3. Cliquez sur chaque groupe pour voir les logs détaillés
```

## 💻 CLI

```bash
# Voir les logs d'une fonction
aws logs tail /aws/lambda/ValidateInput --follow --region eu-west-3
```

---

# Étape 6 : Ajouter un Wait State (Optionnel)

Vous pouvez ajouter un délai dans le workflow :

```json
{
  "WaitForApproval": {
    "Type": "Wait",
    "Seconds": 60,
    "Next": "ProcessData"
  }
}
```

Ou attendre jusqu'à une date :

```json
{
  "WaitUntilDate": {
    "Type": "Wait",
    "Timestamp": "2024-12-31T23:59:59Z",
    "Next": "ProcessData"
  }
}
```

---

# Étape 7 : Ajouter un Parallel State (Optionnel)

Pour exécuter des tâches en parallèle :

```json
{
  "ParallelProcessing": {
    "Type": "Parallel",
    "Branches": [
      {
        "StartAt": "SendEmail",
        "States": {
          "SendEmail": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:...:SendEmail",
            "End": true
          }
        }
      },
      {
        "StartAt": "SendSMS",
        "States": {
          "SendSMS": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:...:SendSMS",
            "End": true
          }
        }
      }
    ],
    "Next": "FinalStep"
  }
}
```

---

# 🔧 Troubleshooting

## ❌ "Lambda function does not exist"

```
1. Vérifiez le nom de la fonction dans l'ARN
2. Vérifiez la région (eu-west-3)
3. Vérifiez que la fonction existe dans Lambda
```

## ❌ "Access denied when invoking Lambda"

```
1. Vérifiez que le rôle StepFunctionsExecutionRole a la permission lambda:InvokeFunction
2. Vérifiez que le rôle est attaché à la state machine
```

## ❌ "Execution failed"

```
1. Step Functions → Executions → Cliquez sur l'exécution
2. Regardez le "Graph inspector"
3. Cliquez sur l'étape rouge pour voir l'erreur
4. Consultez les logs CloudWatch
```

---

# 🧹 Nettoyage

```bash
# 1. Supprimer la state machine
aws stepfunctions delete-state-machine \
  --state-machine-arn $SM_ARN \
  --region eu-west-3

# 2. Supprimer les fonctions Lambda
for func in ValidateInput ProcessData SendNotification HandleError; do
  aws lambda delete-function --function-name $func --region eu-west-3
done

# 3. Supprimer les rôles IAM
aws iam delete-role-policy \
  --role-name StepFunctionsExecutionRole \
  --policy-name InvokeLambda

aws iam delete-role --role-name StepFunctionsExecutionRole

aws iam detach-role-policy \
  --role-name StepFunctionsLambdaRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam delete-role --role-name StepFunctionsLambdaRole

# 4. Supprimer les log groups
for func in ValidateInput ProcessData SendNotification HandleError; do
  aws logs delete-log-group \
    --log-group-name /aws/lambda/$func \
    --region eu-west-3
done
```

---

## 📊 Résumé des types d'états

| Type | Description | Exemple |
|------|-------------|---------|
| **Task** | Exécute une Lambda | Traitement de données |
| **Choice** | Branchement conditionnel | If/Else |
| **Wait** | Pause temporelle | Attendre 60s |
| **Parallel** | Exécution parallèle | Multi-notifications |
| **Map** | Itération sur une liste | Traiter N items |
| **Pass** | Passe les données | Debug, transformation |
| **Succeed** | Fin avec succès | Terminal |
| **Fail** | Fin avec erreur | Terminal |

---

## ✅ Checklist Finale

- [ ] 4 fonctions Lambda créées et déployées
- [ ] Rôle IAM pour Step Functions créé
- [ ] State Machine créée avec le workflow complet
- [ ] Test 1 : Exécution réussie (status: SUCCEEDED)
- [ ] Test 2 : Exécution avec erreur (HandleError)
- [ ] Logs visibles dans CloudWatch
- [ ] Compréhension des états (Task, Choice, etc.)

---

## 🎉 Félicitations !

Vous avez terminé les **9 Jobs AWS** ! Vous savez maintenant :

1. ✅ **EC2 + Auto Scaling + ALB** - Infrastructure scalable
2. ✅ **S3 + CloudFront** - Hébergement statique mondial
3. ✅ **RDS** - Bases de données managées
4. ✅ **Lambda + API Gateway** - APIs serverless
5. ✅ **CloudWatch + SNS** - Monitoring et alertes
6. ✅ **AWS Glue** - Pipelines ETL
7. ✅ **Athena + QuickSight** - Analyse de données
8. ✅ **ECS + Fargate** - Conteneurs sans serveur
9. ✅ **Step Functions** - Orchestration de workflows

---

[⬅️ Retour : Job8](./Job8_ECS_Fargate.md) | [🏠 Retour au README](./README.md)
