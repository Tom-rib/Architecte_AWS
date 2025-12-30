# 02 - Lambda pour Workflows Step Functions 🔧

Guide pour créer des fonctions Lambda optimisées pour Step Functions.

---

## 🎯 LAMBDA DANS STEP FUNCTIONS

**Rôle de Lambda :** Exécuter la logique métier de chaque étape.

```
Step Functions = Orchestrateur (quoi faire, dans quel ordre)
Lambda = Exécuteur (comment le faire)
```

---

## 📥 INPUT / OUTPUT

### Ce que Lambda reçoit

```python
def lambda_handler(event, context):
    # event = output de l'état précédent (ou input initial)
    print(event)
    # {"orderId": "123", "amount": 99.99}
```

### Ce que Lambda retourne

```python
def lambda_handler(event, context):
    # Le return devient l'input de l'état suivant
    return {
        "orderId": event["orderId"],
        "status": "validated",
        "processedAt": "2024-01-15T10:00:00Z"
    }
```

### Flux de données

```
Input initial
    │
    ▼
┌──────────────┐
│   Lambda 1   │  event = Input initial
│  (validate)  │  return = {"status": "valid", ...}
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Lambda 2   │  event = {"status": "valid", ...}
│  (process)   │  return = {"result": "processed", ...}
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Lambda 3   │  event = {"result": "processed", ...}
│  (notify)    │  return = {"notified": true}
└──────────────┘
       │
       ▼
Output final = {"notified": true}
```

---

## 🐍 EXEMPLES PYTHON

### 1. validate-input

```python
import json

def lambda_handler(event, context):
    """
    Valide les données d'entrée du workflow.
    Input: {"data": {...}, "userId": "..."}
    Output: {"valid": true/false, "data": {...}, "errors": [...]}
    """
    
    errors = []
    
    # Vérifier que 'data' existe
    if 'data' not in event:
        errors.append("Missing 'data' field")
    
    # Vérifier que 'userId' existe
    if 'userId' not in event:
        errors.append("Missing 'userId' field")
    
    # Vérifier le format de l'email si présent
    if 'email' in event.get('data', {}):
        email = event['data']['email']
        if '@' not in email:
            errors.append("Invalid email format")
    
    # Retourner le résultat
    if errors:
        return {
            'valid': False,
            'errors': errors,
            'data': event.get('data', {})
        }
    
    return {
        'valid': True,
        'errors': [],
        'data': event['data'],
        'userId': event['userId']
    }
```

---

### 2. process-data

```python
import json
import uuid
from datetime import datetime

def lambda_handler(event, context):
    """
    Traite les données validées.
    Input: {"valid": true, "data": {...}, "userId": "..."}
    Output: {"processed": true, "result": {...}}
    """
    
    # Vérifier que les données sont valides
    if not event.get('valid', False):
        raise ValueError("Cannot process invalid data")
    
    data = event['data']
    user_id = event['userId']
    
    # Simuler un traitement
    result = {
        'transactionId': str(uuid.uuid4()),
        'userId': user_id,
        'processedAt': datetime.utcnow().isoformat() + 'Z',
        'items': data.get('items', []),
        'total': calculate_total(data.get('items', []))
    }
    
    return {
        'processed': True,
        'result': result
    }

def calculate_total(items):
    return sum(item.get('price', 0) * item.get('quantity', 1) for item in items)
```

---

### 3. send-notification

```python
import json
import boto3

def lambda_handler(event, context):
    """
    Envoie une notification de fin de traitement.
    Input: {"processed": true, "result": {...}}
    Output: {"notified": true, "messageId": "..."}
    """
    
    if not event.get('processed', False):
        return {
            'notified': False,
            'error': 'Data was not processed'
        }
    
    result = event['result']
    
    # Envoyer notification SNS (optionnel)
    # sns = boto3.client('sns')
    # response = sns.publish(
    #     TopicArn='arn:aws:sns:eu-west-3:123456789:notifications',
    #     Message=json.dumps({
    #         'type': 'ORDER_PROCESSED',
    #         'transactionId': result['transactionId'],
    #         'userId': result['userId']
    #     }),
    #     Subject='Order Processed'
    # )
    
    # Pour le test, simuler l'envoi
    print(f"Notification sent for transaction: {result['transactionId']}")
    
    return {
        'notified': True,
        'transactionId': result['transactionId'],
        'timestamp': result['processedAt']
    }
```

---

## 🟨 EXEMPLES NODE.JS

### 1. validate-input

```javascript
exports.handler = async (event) => {
    /**
     * Valide les données d'entrée du workflow.
     */
    
    const errors = [];
    
    // Vérifier que 'data' existe
    if (!event.data) {
        errors.push("Missing 'data' field");
    }
    
    // Vérifier que 'userId' existe
    if (!event.userId) {
        errors.push("Missing 'userId' field");
    }
    
    // Vérifier l'email si présent
    if (event.data?.email && !event.data.email.includes('@')) {
        errors.push("Invalid email format");
    }
    
    if (errors.length > 0) {
        return {
            valid: false,
            errors: errors,
            data: event.data || {}
        };
    }
    
    return {
        valid: true,
        errors: [],
        data: event.data,
        userId: event.userId
    };
};
```

---

### 2. process-data

```javascript
const { v4: uuidv4 } = require('uuid');

exports.handler = async (event) => {
    /**
     * Traite les données validées.
     */
    
    if (!event.valid) {
        throw new Error("Cannot process invalid data");
    }
    
    const { data, userId } = event;
    
    const result = {
        transactionId: uuidv4(),
        userId: userId,
        processedAt: new Date().toISOString(),
        items: data.items || [],
        total: calculateTotal(data.items || [])
    };
    
    return {
        processed: true,
        result: result
    };
};

function calculateTotal(items) {
    return items.reduce((sum, item) => {
        return sum + (item.price || 0) * (item.quantity || 1);
    }, 0);
}
```

---

### 3. send-notification

```javascript
exports.handler = async (event) => {
    /**
     * Envoie une notification de fin de traitement.
     */
    
    if (!event.processed) {
        return {
            notified: false,
            error: 'Data was not processed'
        };
    }
    
    const { result } = event;
    
    console.log(`Notification sent for transaction: ${result.transactionId}`);
    
    return {
        notified: true,
        transactionId: result.transactionId,
        timestamp: result.processedAt
    };
};
```

---

## ⚠️ GESTION DES ERREURS

### Lever une exception

```python
def lambda_handler(event, context):
    if 'data' not in event:
        # Cette erreur sera catchée par Step Functions
        raise ValueError("Missing data field")
    
    # Traitement...
    return {"success": True}
```

### Erreurs personnalisées

```python
class ValidationError(Exception):
    pass

class ProcessingError(Exception):
    pass

def lambda_handler(event, context):
    if not event.get('valid'):
        raise ValidationError("Input validation failed")
    
    try:
        result = process(event['data'])
    except Exception as e:
        raise ProcessingError(f"Processing failed: {str(e)}")
    
    return result
```

### Catch dans Step Functions

```json
{
  "Type": "Task",
  "Resource": "arn:aws:lambda:...:function:process-data",
  "Catch": [
    {
      "ErrorEquals": ["ValidationError"],
      "Next": "HandleValidationError"
    },
    {
      "ErrorEquals": ["ProcessingError"],
      "Next": "HandleProcessingError"
    },
    {
      "ErrorEquals": ["States.ALL"],
      "Next": "HandleGenericError"
    }
  ],
  "Next": "SendNotification"
}
```

---

## ⏱️ TIMEOUT ET HEARTBEAT

### Timeout Lambda

```python
# Lambda a un timeout max de 15 minutes
# Step Functions attend jusqu'au timeout
```

### Pour les tâches longues : Callback Pattern

```python
import boto3

def lambda_handler(event, context):
    """
    Pour les tâches qui prennent plus de 15 min,
    utiliser le callback pattern.
    """
    
    sfn = boto3.client('stepfunctions')
    
    task_token = event['taskToken']  # Fourni par Step Functions
    
    # Lancer un processus long (ex: Batch, ECS)
    # ...
    
    # Quand c'est fini, appeler send_task_success
    # sfn.send_task_success(
    #     taskToken=task_token,
    #     output=json.dumps({"result": "done"})
    # )
    
    return {"started": True}
```

---

## 📦 CONFIGURATION LAMBDA RECOMMANDÉE

### Pour Step Functions

| Paramètre | Recommandation |
|-----------|----------------|
| **Runtime** | Python 3.12 ou Node.js 20.x |
| **Memory** | 256 MB minimum |
| **Timeout** | 30 sec (ajuster selon besoin) |
| **Handler** | `index.lambda_handler` (Python) ou `index.handler` (Node) |

### Variables d'environnement utiles

```bash
STAGE=production
LOG_LEVEL=INFO
```

---

## 🔐 IAM POUR LAMBDA

### Policy Lambda basique

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
```

### Si Lambda doit accéder à d'autres services

```json
{
  "Effect": "Allow",
  "Action": [
    "dynamodb:GetItem",
    "dynamodb:PutItem"
  ],
  "Resource": "arn:aws:dynamodb:eu-west-3:123456789:table/MyTable"
}
```

---

## 🧪 TESTER LOCALEMENT

### Test unitaire Python

```python
# test_validate_input.py
import json
from validate_input import lambda_handler

def test_valid_input():
    event = {
        "data": {"email": "test@example.com"},
        "userId": "user123"
    }
    result = lambda_handler(event, None)
    assert result['valid'] == True
    assert len(result['errors']) == 0

def test_missing_data():
    event = {"userId": "user123"}
    result = lambda_handler(event, None)
    assert result['valid'] == False
    assert "Missing 'data' field" in result['errors']

def test_invalid_email():
    event = {
        "data": {"email": "invalid-email"},
        "userId": "user123"
    }
    result = lambda_handler(event, None)
    assert result['valid'] == False
    assert "Invalid email format" in result['errors']
```

### Exécuter les tests

```bash
# Python
pip install pytest
pytest test_validate_input.py -v

# Node.js
npm install jest
npx jest
```

---

## 📋 BONNES PRATIQUES

### DO ✅

- Retourner JSON valide
- Gérer les cas d'erreur explicitement
- Logger les informations importantes
- Garder les fonctions petites et focalisées
- Utiliser des variables d'environnement
- Valider l'input au début

### DON'T ❌

- Ne pas hardcoder les ARN
- Ne pas stocker de secrets dans le code
- Ne pas ignorer les erreurs silencieusement
- Ne pas créer de Lambda trop gros (max 50MB)
- Ne pas utiliser `print()` pour les logs importants (utiliser `logging`)

---

## ✅ CHECKLIST LAMBDA POUR STEP FUNCTIONS

```
□ Input/Output JSON bien définis
□ Gestion des erreurs avec exceptions nommées
□ Logging configuré
□ Tests unitaires écrits
□ IAM role avec minimum de permissions
□ Timeout approprié
□ Variables d'environnement pour config
□ Code déployé et testé
```

---

## 🔗 LIENS

- **Step Functions** → [01-StepFunctions-Concepts-Complets.md](./01-StepFunctions-Concepts-Complets.md)
- **ASL Language** → [03-ASL-States-Language.md](./03-ASL-States-Language.md)
- **Error Handling** → [06-Error-Handling.md](./06-Error-Handling.md)
- **CLI Commands** → [CLI-Commands.md](./CLI-Commands.md)

---

[⬅️ Retour au README](./README.md)
