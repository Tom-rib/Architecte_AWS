# 06 - Gestion des Erreurs Step Functions 🛡️

Guide complet pour gérer les erreurs dans les workflows Step Functions.

---

## 🎯 POURQUOI GÉRER LES ERREURS ?

Dans un workflow distribué :
- Les services peuvent échouer
- Les timeouts peuvent survenir
- Les données peuvent être invalides
- Le réseau peut avoir des problèmes

**Step Functions offre :**
- `Retry` : Réessayer automatiquement
- `Catch` : Capturer et rediriger les erreurs
- États de fallback personnalisés

---

## 🔄 RETRY - RÉESSAYER

### Syntaxe de base

```json
{
  "ProcessOrder": {
    "Type": "Task",
    "Resource": "arn:aws:lambda:...:function:process-order",
    "Retry": [
      {
        "ErrorEquals": ["States.TaskFailed"],
        "IntervalSeconds": 3,
        "MaxAttempts": 2,
        "BackoffRate": 2
      }
    ],
    "Next": "SendConfirmation"
  }
}
```

### Paramètres Retry

| Paramètre | Description | Défaut |
|-----------|-------------|--------|
| `ErrorEquals` | Liste des erreurs à retrier | Obligatoire |
| `IntervalSeconds` | Délai avant 1er retry | 1 |
| `MaxAttempts` | Nombre max de tentatives | 3 |
| `BackoffRate` | Multiplicateur du délai | 2.0 |
| `MaxDelaySeconds` | Délai max entre retries | - |
| `JitterStrategy` | Ajouter du jitter | NONE |

### Backoff exponentiel

```
Tentative 1 : échec
    Attente : 3 secondes (IntervalSeconds)
Tentative 2 : échec
    Attente : 6 secondes (3 × BackoffRate)
Tentative 3 : échec
    Attente : 12 secondes (6 × BackoffRate)
Tentative 4 : succès ou erreur finale
```

### Exemple complet avec plusieurs types d'erreurs

```json
{
  "CallExternalAPI": {
    "Type": "Task",
    "Resource": "arn:aws:lambda:...:function:call-api",
    "Retry": [
      {
        "ErrorEquals": ["Lambda.TooManyRequestsException"],
        "IntervalSeconds": 1,
        "MaxAttempts": 6,
        "BackoffRate": 2,
        "JitterStrategy": "FULL"
      },
      {
        "ErrorEquals": ["States.Timeout", "Lambda.ServiceException"],
        "IntervalSeconds": 5,
        "MaxAttempts": 3,
        "BackoffRate": 2
      },
      {
        "ErrorEquals": ["States.ALL"],
        "IntervalSeconds": 10,
        "MaxAttempts": 2,
        "BackoffRate": 1
      }
    ],
    "Next": "ProcessResponse"
  }
}
```

### Erreurs retryables recommandées

```json
{
  "Retry": [
    {
      "ErrorEquals": [
        "Lambda.ServiceException",
        "Lambda.AWSLambdaException",
        "Lambda.SdkClientException",
        "Lambda.TooManyRequestsException",
        "States.Timeout"
      ],
      "IntervalSeconds": 2,
      "MaxAttempts": 3,
      "BackoffRate": 2
    }
  ]
}
```

---

## 🎣 CATCH - CAPTURER LES ERREURS

### Syntaxe de base

```json
{
  "ProcessOrder": {
    "Type": "Task",
    "Resource": "arn:aws:lambda:...:function:process-order",
    "Catch": [
      {
        "ErrorEquals": ["ValidationError"],
        "ResultPath": "$.error",
        "Next": "HandleValidationError"
      },
      {
        "ErrorEquals": ["States.ALL"],
        "ResultPath": "$.error",
        "Next": "HandleGenericError"
      }
    ],
    "Next": "SendConfirmation"
  }
}
```

### Paramètres Catch

| Paramètre | Description |
|-----------|-------------|
| `ErrorEquals` | Liste des erreurs à capturer |
| `Next` | État vers lequel rediriger |
| `ResultPath` | Où stocker l'info d'erreur |

### Objet d'erreur capturé

```json
// Ce qui est stocké dans $.error
{
  "Error": "ValidationError",
  "Cause": "Invalid email format"
}
```

### Exemple avec état de fallback

```json
{
  "States": {
    "ProcessPayment": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:process-payment",
      "Catch": [
        {
          "ErrorEquals": ["PaymentDeclined"],
          "ResultPath": "$.paymentError",
          "Next": "NotifyPaymentFailed"
        },
        {
          "ErrorEquals": ["States.ALL"],
          "ResultPath": "$.error",
          "Next": "HandleUnexpectedError"
        }
      ],
      "Next": "SendReceipt"
    },
    "NotifyPaymentFailed": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:send-failure-notification",
      "Next": "MarkOrderFailed"
    },
    "MarkOrderFailed": {
      "Type": "Fail",
      "Error": "PaymentFailed",
      "Cause": "Payment was declined by the provider"
    },
    "HandleUnexpectedError": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:log-error",
      "Next": "RetryOrFail"
    }
  }
}
```

---

## 🏷️ TYPES D'ERREURS

### Erreurs Step Functions (prédéfinies)

| Erreur | Description |
|--------|-------------|
| `States.ALL` | Toutes les erreurs |
| `States.Timeout` | Timeout de l'état |
| `States.TaskFailed` | Échec de la tâche |
| `States.Permissions` | Erreur de permission IAM |
| `States.ResultPathMatchFailure` | ResultPath invalide |
| `States.ParameterPathFailure` | Path invalide dans Parameters |
| `States.BranchFailed` | Échec d'une branche Parallel |
| `States.NoChoiceMatched` | Aucune règle Choice matchée |
| `States.IntrinsicFailure` | Erreur dans fonction intrinsèque |
| `States.HeartbeatTimeout` | Heartbeat manquant |
| `States.Runtime` | Erreur runtime ASL |

### Erreurs Lambda

| Erreur | Description |
|--------|-------------|
| `Lambda.ServiceException` | Erreur service Lambda |
| `Lambda.AWSLambdaException` | Erreur AWS Lambda |
| `Lambda.SdkClientException` | Erreur SDK client |
| `Lambda.TooManyRequestsException` | Throttling |
| `Lambda.Unknown` | Erreur non identifiée |

### Erreurs personnalisées

Définies dans votre code Lambda :

```python
# Python
raise ValueError("CustomValidationError: Invalid input")

# Sera capturé comme "ValueError" dans Step Functions
```

```javascript
// Node.js
throw new Error("CustomValidationError: Invalid input");

// Sera capturé comme "Error" dans Step Functions
```

---

## 🔄 COMBINER RETRY ET CATCH

### Ordre d'exécution

```
1. Task s'exécute
2. Si erreur :
   a. Vérifie Retry → si match, réessaie
   b. Si max retries atteint → vérifie Catch
   c. Si Catch match → redirige
   d. Sinon → workflow échoue
```

### Exemple complet

```json
{
  "CallAPI": {
    "Type": "Task",
    "Resource": "arn:aws:lambda:...:function:call-external-api",
    "TimeoutSeconds": 30,
    "Retry": [
      {
        "ErrorEquals": [
          "Lambda.ServiceException",
          "Lambda.TooManyRequestsException",
          "States.Timeout"
        ],
        "IntervalSeconds": 2,
        "MaxAttempts": 3,
        "BackoffRate": 2
      }
    ],
    "Catch": [
      {
        "ErrorEquals": ["RateLimitExceeded"],
        "ResultPath": "$.error",
        "Next": "WaitAndRetry"
      },
      {
        "ErrorEquals": ["AuthenticationError"],
        "ResultPath": "$.error",
        "Next": "RefreshCredentials"
      },
      {
        "ErrorEquals": ["States.ALL"],
        "ResultPath": "$.error",
        "Next": "LogErrorAndNotify"
      }
    ],
    "Next": "ProcessResponse"
  }
}
```

---

## 🔁 PATTERN : RETRY MANUEL

Pour un contrôle plus fin sur les retries :

```json
{
  "States": {
    "Initialize": {
      "Type": "Pass",
      "Result": {
        "retryCount": 0,
        "maxRetries": 3
      },
      "ResultPath": "$.retryState",
      "Next": "TryOperation"
    },
    "TryOperation": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...",
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "ResultPath": "$.error",
          "Next": "CheckRetry"
        }
      ],
      "Next": "Success"
    },
    "CheckRetry": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.retryState.retryCount",
          "NumericLessThan": 3,
          "Next": "IncrementRetry"
        }
      ],
      "Default": "MaxRetriesExceeded"
    },
    "IncrementRetry": {
      "Type": "Pass",
      "Parameters": {
        "retryCount.$": "States.MathAdd($.retryState.retryCount, 1)",
        "maxRetries.$": "$.retryState.maxRetries"
      },
      "ResultPath": "$.retryState",
      "Next": "WaitBeforeRetry"
    },
    "WaitBeforeRetry": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "TryOperation"
    },
    "MaxRetriesExceeded": {
      "Type": "Fail",
      "Error": "MaxRetriesExceeded",
      "Cause": "Operation failed after maximum retries"
    },
    "Success": {
      "Type": "Succeed"
    }
  }
}
```

---

## 🎭 PATTERN : SAGA (COMPENSATION)

Pour annuler les étapes précédentes en cas d'échec :

```json
{
  "Comment": "Saga Pattern - Order Processing",
  "StartAt": "ReserveInventory",
  "States": {
    "ReserveInventory": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:reserve-inventory",
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "ResultPath": "$.error",
          "Next": "InventoryReservationFailed"
        }
      ],
      "Next": "ProcessPayment"
    },
    "ProcessPayment": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:process-payment",
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "ResultPath": "$.error",
          "Next": "ReleaseInventory"
        }
      ],
      "Next": "ShipOrder"
    },
    "ShipOrder": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:ship-order",
      "Catch": [
        {
          "ErrorEquals": ["States.ALL"],
          "ResultPath": "$.error",
          "Next": "RefundPayment"
        }
      ],
      "Next": "OrderComplete"
    },
    "ReleaseInventory": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:release-inventory",
      "Next": "PaymentFailed"
    },
    "RefundPayment": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:refund-payment",
      "Next": "ReleaseInventoryAfterRefund"
    },
    "ReleaseInventoryAfterRefund": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:function:release-inventory",
      "Next": "ShippingFailed"
    },
    "InventoryReservationFailed": {
      "Type": "Fail",
      "Error": "InventoryError",
      "Cause": "Could not reserve inventory"
    },
    "PaymentFailed": {
      "Type": "Fail",
      "Error": "PaymentError",
      "Cause": "Payment processing failed"
    },
    "ShippingFailed": {
      "Type": "Fail",
      "Error": "ShippingError",
      "Cause": "Shipping failed, order refunded"
    },
    "OrderComplete": {
      "Type": "Succeed"
    }
  }
}
```

---

## 📧 PATTERN : NOTIFICATION D'ERREUR

```json
{
  "ProcessData": {
    "Type": "Task",
    "Resource": "arn:aws:lambda:...:function:process-data",
    "Catch": [
      {
        "ErrorEquals": ["States.ALL"],
        "ResultPath": "$.error",
        "Next": "NotifyAndFail"
      }
    ],
    "Next": "Success"
  },
  "NotifyAndFail": {
    "Type": "Parallel",
    "Branches": [
      {
        "StartAt": "SendErrorEmail",
        "States": {
          "SendErrorEmail": {
            "Type": "Task",
            "Resource": "arn:aws:states:::sns:publish",
            "Parameters": {
              "TopicArn": "arn:aws:sns:eu-west-3:123456789:error-alerts",
              "Message.$": "States.Format('Workflow failed: {}', $.error.Cause)"
            },
            "End": true
          }
        }
      },
      {
        "StartAt": "LogError",
        "States": {
          "LogError": {
            "Type": "Task",
            "Resource": "arn:aws:lambda:...:function:log-error",
            "End": true
          }
        }
      }
    ],
    "Next": "FailWorkflow"
  },
  "FailWorkflow": {
    "Type": "Fail",
    "Error": "WorkflowFailed",
    "Cause.$": "$.error.Cause"
  }
}
```

---

## ✅ BONNES PRATIQUES

### DO ✅

- Toujours avoir un `Catch` avec `States.ALL` en dernier
- Utiliser des erreurs personnalisées explicites
- Logger les erreurs pour le debugging
- Configurer des retries pour les erreurs transitoires
- Notifier en cas d'erreur critique

### DON'T ❌

- Ne pas ignorer les erreurs silencieusement
- Ne pas retry sur des erreurs non-retryables (validation, auth)
- Ne pas créer de boucles infinies de retry
- Ne pas hardcoder des timeouts trop courts

---

## ✅ CHECKLIST ERROR HANDLING

```
□ Retry configuré pour erreurs transitoires
□ Catch pour chaque type d'erreur attendu
□ Catch States.ALL en fallback
□ États de compensation (Saga) si nécessaire
□ Notifications d'erreur configurées
□ Logs pour debugging
□ Timeouts appropriés
□ Tests des scénarios d'erreur
```

---

## 🔗 LIENS

- **Step Functions** → [01-StepFunctions-Concepts-Complets.md](./01-StepFunctions-Concepts-Complets.md)
- **ASL Language** → [03-ASL-States-Language.md](./03-ASL-States-Language.md)
- **CloudWatch** → [08-CloudWatch-Integration.md](./08-CloudWatch-Integration.md)
- **Troubleshooting** → [Troubleshooting.md](./Troubleshooting.md)

---

[⬅️ Retour au README](./README.md)
