# 03 - ASL - Amazon States Language 📜

Guide complet du langage de définition des workflows Step Functions.

---

## 🎯 QU'EST-CE QUE ASL ?

**ASL** = Amazon States Language = Langage JSON pour définir les workflows.

```
ASL = "Le code de votre workflow"
```

**Caractéristiques :**
- Format JSON
- Déclaratif
- Versionné (1.0)
- Validé par Step Functions

---

## 📄 STRUCTURE DE BASE

```json
{
  "Comment": "Description du workflow",
  "StartAt": "PremierEtat",
  "States": {
    "PremierEtat": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...",
      "Next": "DeuxiemeEtat"
    },
    "DeuxiemeEtat": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...",
      "End": true
    }
  }
}
```

### Champs top-level

| Champ | Obligatoire | Description |
|-------|-------------|-------------|
| `Comment` | Non | Description lisible |
| `StartAt` | Oui | Nom du premier état |
| `States` | Oui | Objet contenant tous les états |
| `TimeoutSeconds` | Non | Timeout global de l'exécution |
| `Version` | Non | Version ASL (défaut "1.0") |

---

## 🔧 ÉTAT TASK

### Appeler une fonction Lambda

```json
{
  "ValidateInput": {
    "Type": "Task",
    "Resource": "arn:aws:lambda:eu-west-3:123456789012:function:validate-input",
    "Next": "ProcessData"
  }
}
```

### Avec timeout et retry

```json
{
  "ProcessData": {
    "Type": "Task",
    "Resource": "arn:aws:lambda:eu-west-3:123456789012:function:process-data",
    "TimeoutSeconds": 300,
    "HeartbeatSeconds": 60,
    "Retry": [
      {
        "ErrorEquals": ["Lambda.ServiceException", "Lambda.TooManyRequestsException"],
        "IntervalSeconds": 2,
        "MaxAttempts": 3,
        "BackoffRate": 2
      }
    ],
    "Next": "SendNotification"
  }
}
```

### Intégration AWS SDK (sans Lambda)

```json
{
  "WriteToDynamoDB": {
    "Type": "Task",
    "Resource": "arn:aws:states:::dynamodb:putItem",
    "Parameters": {
      "TableName": "MyTable",
      "Item": {
        "id": {"S.$": "$.orderId"},
        "status": {"S": "processed"},
        "timestamp": {"S.$": "$$.State.EnteredTime"}
      }
    },
    "Next": "NextState"
  }
}
```

### Intégrations directes supportées

| Service | Resource |
|---------|----------|
| Lambda | `arn:aws:states:::lambda:invoke` |
| DynamoDB | `arn:aws:states:::dynamodb:getItem` |
| SQS | `arn:aws:states:::sqs:sendMessage` |
| SNS | `arn:aws:states:::sns:publish` |
| ECS | `arn:aws:states:::ecs:runTask` |
| Batch | `arn:aws:states:::batch:submitJob` |
| Glue | `arn:aws:states:::glue:startJobRun` |

---

## 🔀 ÉTAT CHOICE

### Syntaxe de base

```json
{
  "CheckValidation": {
    "Type": "Choice",
    "Choices": [
      {
        "Variable": "$.valid",
        "BooleanEquals": true,
        "Next": "ProcessData"
      },
      {
        "Variable": "$.valid",
        "BooleanEquals": false,
        "Next": "HandleInvalidInput"
      }
    ],
    "Default": "HandleUnknownState"
  }
}
```

### Opérateurs de comparaison

#### String

```json
{
  "Variable": "$.status",
  "StringEquals": "SUCCESS",
  "Next": "..."
}

{
  "Variable": "$.name",
  "StringGreaterThan": "M",
  "Next": "..."
}

{
  "Variable": "$.email",
  "StringMatches": "*@example.com",
  "Next": "..."
}
```

#### Numeric

```json
{
  "Variable": "$.count",
  "NumericEquals": 100,
  "Next": "..."
}

{
  "Variable": "$.amount",
  "NumericGreaterThan": 1000,
  "Next": "..."
}

{
  "Variable": "$.price",
  "NumericLessThanEquals": 50,
  "Next": "..."
}
```

#### Boolean

```json
{
  "Variable": "$.isActive",
  "BooleanEquals": true,
  "Next": "..."
}
```

#### Timestamp

```json
{
  "Variable": "$.expiryDate",
  "TimestampLessThan": "2024-12-31T23:59:59Z",
  "Next": "..."
}
```

#### Type checking

```json
{
  "Variable": "$.data",
  "IsPresent": true,
  "Next": "..."
}

{
  "Variable": "$.value",
  "IsNull": false,
  "Next": "..."
}

{
  "Variable": "$.count",
  "IsNumeric": true,
  "Next": "..."
}

{
  "Variable": "$.name",
  "IsString": true,
  "Next": "..."
}
```

### Opérateurs logiques

#### And

```json
{
  "And": [
    {
      "Variable": "$.age",
      "NumericGreaterThanEquals": 18
    },
    {
      "Variable": "$.country",
      "StringEquals": "FR"
    }
  ],
  "Next": "AllowAccess"
}
```

#### Or

```json
{
  "Or": [
    {
      "Variable": "$.role",
      "StringEquals": "admin"
    },
    {
      "Variable": "$.role",
      "StringEquals": "superuser"
    }
  ],
  "Next": "GrantPermissions"
}
```

#### Not

```json
{
  "Not": {
    "Variable": "$.status",
    "StringEquals": "blocked"
  },
  "Next": "ProcessRequest"
}
```

---

## ⚡ ÉTAT PARALLEL

### Exécuter des branches en parallèle

```json
{
  "SendNotifications": {
    "Type": "Parallel",
    "Branches": [
      {
        "StartAt": "SendEmail",
        "States": {
          "SendEmail": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:...:function:send-email",
            "End": true
          }
        }
      },
      {
        "StartAt": "SendSMS",
        "States": {
          "SendSMS": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:...:function:send-sms",
            "End": true
          }
        }
      },
      {
        "StartAt": "SendPush",
        "States": {
          "SendPush": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:...:function:send-push",
            "End": true
          }
        }
      }
    ],
    "Next": "LogResults"
  }
}
```

### Output du Parallel

```json
// Input
{"userId": "123", "message": "Hello"}

// Output (array des résultats de chaque branche)
[
  {"emailSent": true, "messageId": "email-001"},
  {"smsSent": true, "messageId": "sms-001"},
  {"pushSent": true, "messageId": "push-001"}
]
```

---

## 🔁 ÉTAT MAP

### Itérer sur une liste

```json
{
  "ProcessAllOrders": {
    "Type": "Map",
    "ItemsPath": "$.orders",
    "MaxConcurrency": 10,
    "Iterator": {
      "StartAt": "ProcessOrder",
      "States": {
        "ProcessOrder": {
          "Type": "Task",
          "Resource": "arn:aws:lambda:...:function:process-order",
          "End": true
        }
      }
    },
    "Next": "SummarizeResults"
  }
}
```

### Avec ItemSelector (transformer l'item)

```json
{
  "ProcessItems": {
    "Type": "Map",
    "ItemsPath": "$.items",
    "ItemSelector": {
      "itemId.$": "$$.Map.Item.Value.id",
      "itemName.$": "$$.Map.Item.Value.name",
      "index.$": "$$.Map.Item.Index",
      "batchId.$": "$.batchId"
    },
    "Iterator": {
      "StartAt": "Process",
      "States": {
        "Process": {
          "Type": "Task",
          "Resource": "arn:aws:lambda:...",
          "End": true
        }
      }
    },
    "Next": "Done"
  }
}
```

### Paramètres Map

| Paramètre | Description |
|-----------|-------------|
| `ItemsPath` | Chemin vers l'array |
| `MaxConcurrency` | Parallélisme (0 = illimité) |
| `Iterator` | State machine pour chaque item |
| `ItemSelector` | Transformer chaque item |
| `ResultPath` | Où stocker les résultats |

---

## ⏱️ ÉTAT WAIT

### Attendre un temps fixe

```json
{
  "WaitFiveMinutes": {
    "Type": "Wait",
    "Seconds": 300,
    "Next": "CheckStatus"
  }
}
```

### Attendre jusqu'à une date

```json
{
  "WaitUntilMidnight": {
    "Type": "Wait",
    "Timestamp": "2024-12-31T23:59:59Z",
    "Next": "SendNewYearMessage"
  }
}
```

### Attendre selon l'input

```json
{
  "WaitForDelay": {
    "Type": "Wait",
    "SecondsPath": "$.delaySeconds",
    "Next": "Continue"
  }
}

{
  "WaitUntilScheduled": {
    "Type": "Wait",
    "TimestampPath": "$.scheduledTime",
    "Next": "Execute"
  }
}
```

---

## 🔄 ÉTAT PASS

### Injecter des données statiques

```json
{
  "SetDefaults": {
    "Type": "Pass",
    "Result": {
      "defaultTimeout": 30,
      "maxRetries": 3,
      "environment": "production"
    },
    "ResultPath": "$.config",
    "Next": "ProcessWithConfig"
  }
}
```

### Transformer l'input

```json
{
  "TransformData": {
    "Type": "Pass",
    "Parameters": {
      "orderId.$": "$.order.id",
      "customerEmail.$": "$.customer.email",
      "totalAmount.$": "$.order.total",
      "processedAt.$": "$$.State.EnteredTime"
    },
    "Next": "SendConfirmation"
  }
}
```

---

## ✅ ÉTAT SUCCEED

```json
{
  "WorkflowComplete": {
    "Type": "Succeed"
  }
}
```

---

## ❌ ÉTAT FAIL

```json
{
  "ValidationFailed": {
    "Type": "Fail",
    "Error": "ValidationError",
    "Cause": "Input data failed validation checks"
  }
}
```

---

## 📥📤 INPUT/OUTPUT PROCESSING

### Champs de traitement

| Champ | Appliqué | Description |
|-------|----------|-------------|
| `InputPath` | Avant | Filtre l'input |
| `Parameters` | Avant | Construit un nouvel input |
| `ResultSelector` | Après | Transforme le résultat |
| `ResultPath` | Après | Où stocker le résultat |
| `OutputPath` | Après | Filtre l'output final |

### Ordre d'application

```
Input → InputPath → Parameters → [Exécution] → ResultSelector → ResultPath → OutputPath → Output
```

### Exemples

#### InputPath - Extraire une partie de l'input

```json
{
  "Type": "Task",
  "InputPath": "$.order",
  "Resource": "...",
  "Next": "..."
}
```

```json
// Input original
{"order": {"id": "123", "items": [...]}, "metadata": {...}}

// Input après InputPath
{"id": "123", "items": [...]}
```

#### Parameters - Construire un input personnalisé

```json
{
  "Type": "Task",
  "Parameters": {
    "orderId.$": "$.order.id",
    "itemCount.$": "States.ArrayLength($.order.items)",
    "staticValue": "hello"
  },
  "Resource": "...",
  "Next": "..."
}
```

#### ResultPath - Ajouter le résultat à l'input

```json
{
  "Type": "Task",
  "Resource": "...",
  "ResultPath": "$.validationResult",
  "Next": "..."
}
```

```json
// Input
{"order": {"id": "123"}}

// Résultat de la tâche
{"valid": true}

// Output final
{"order": {"id": "123"}, "validationResult": {"valid": true}}
```

#### ResultPath: null - Ignorer le résultat

```json
{
  "Type": "Task",
  "Resource": "...",
  "ResultPath": null,
  "Next": "..."
}
```

#### OutputPath - Filtrer l'output

```json
{
  "Type": "Task",
  "Resource": "...",
  "OutputPath": "$.result.data",
  "Next": "..."
}
```

---

## 🔧 FONCTIONS INTRINSÈQUES

### Fonctions disponibles

| Fonction | Description |
|----------|-------------|
| `States.Format` | Formater une string |
| `States.StringToJson` | Parser JSON |
| `States.JsonToString` | JSON vers string |
| `States.Array` | Créer un array |
| `States.ArrayContains` | Vérifier si array contient |
| `States.ArrayLength` | Longueur d'un array |
| `States.ArrayRange` | Générer un range |
| `States.ArrayGetItem` | Get item par index |
| `States.Base64Encode` | Encoder en base64 |
| `States.Base64Decode` | Décoder du base64 |
| `States.Hash` | Calculer un hash |
| `States.UUID` | Générer un UUID |
| `States.MathRandom` | Nombre aléatoire |
| `States.MathAdd` | Addition |
| `States.JsonMerge` | Fusionner des objets |

### Exemples

```json
{
  "Parameters": {
    "message.$": "States.Format('Order {} is ready for user {}', $.orderId, $.userId)",
    "uuid.$": "States.UUID()",
    "itemCount.$": "States.ArrayLength($.items)",
    "total.$": "States.MathAdd($.subtotal, $.tax)"
  }
}
```

---

## 📊 CONTEXT OBJECT ($$)

### Variables disponibles

| Variable | Description |
|----------|-------------|
| `$$.Execution.Id` | ARN de l'exécution |
| `$$.Execution.Name` | Nom de l'exécution |
| `$$.Execution.Input` | Input initial |
| `$$.Execution.StartTime` | Heure de début |
| `$$.State.Name` | Nom de l'état actuel |
| `$$.State.EnteredTime` | Heure d'entrée dans l'état |
| `$$.State.RetryCount` | Nombre de retries |
| `$$.Map.Item.Index` | Index dans Map |
| `$$.Map.Item.Value` | Valeur dans Map |

### Exemple

```json
{
  "Parameters": {
    "executionId.$": "$$.Execution.Id",
    "currentState.$": "$$.State.Name",
    "startedAt.$": "$$.Execution.StartTime"
  }
}
```

---

## ✅ CHECKLIST ASL

```
□ JSON valide
□ StartAt pointe vers un état existant
□ Tous les états ont Next ou End: true
□ Choice a un Default
□ Pas de cycles infinis
□ InputPath/OutputPath valides
□ Retry et Catch configurés
□ Timeout défini si nécessaire
```

---

## 🔗 LIENS

- **Step Functions** → [01-StepFunctions-Concepts-Complets.md](./01-StepFunctions-Concepts-Complets.md)
- **Error Handling** → [06-Error-Handling.md](./06-Error-Handling.md)
- **CLI Commands** → [CLI-Commands.md](./CLI-Commands.md)

---

[⬅️ Retour au README](./README.md)
