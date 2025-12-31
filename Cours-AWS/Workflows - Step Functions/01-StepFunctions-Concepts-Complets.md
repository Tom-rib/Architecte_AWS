# 01 - Step Functions Concepts Complets 🔄

Guide complet pour comprendre AWS Step Functions.

---

## 🎯 QU'EST-CE QUE STEP FUNCTIONS ?

**Step Functions** = Service d'orchestration de workflows serverless.

```
Step Functions = "Chef d'orchestre pour vos services AWS"
```

**En simple :**
- Vous définissez des étapes (states)
- Step Functions les exécute dans l'ordre
- Gère les erreurs, retries, parallélisme
- Visualisation graphique du workflow

---

## 🧠 VOCABULAIRE STEP FUNCTIONS

| Terme | Définition | Analogie |
|-------|------------|----------|
| **State Machine** | Définition du workflow | La recette de cuisine |
| **Execution** | Instance en cours du workflow | Le plat en préparation |
| **State** | Une étape du workflow | Une instruction de la recette |
| **Transition** | Passage d'un état à l'autre | Passer à l'étape suivante |
| **ASL** | Amazon States Language | Le langage de la recette |
| **Input/Output** | Données entrantes/sortantes | Les ingrédients |

---

## 📊 ARCHITECTURE STEP FUNCTIONS

```
┌─────────────────────────────────────────────────────────────┐
│                    STATE MACHINE                             │
│                  "MonWorkflow"                               │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                   EXECUTION 1                        │    │
│  │  Input: {"orderId": "123"}                          │    │
│  │  Status: RUNNING                                    │    │
│  │  Started: 2024-01-15 10:00:00                       │    │
│  │                                                      │    │
│  │  [State1] ✅ → [State2] 🔄 → [State3] ⏳           │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                   EXECUTION 2                        │    │
│  │  Input: {"orderId": "124"}                          │    │
│  │  Status: SUCCEEDED                                  │    │
│  │  Started: 2024-01-15 09:30:00                       │    │
│  │                                                      │    │
│  │  [State1] ✅ → [State2] ✅ → [State3] ✅           │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 CYCLE DE VIE D'UNE EXÉCUTION

```
                    ┌─────────────┐
                    │   START     │
                    │ (Input JSON)│
                    └──────┬──────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────┐
│                      RUNNING                          │
│                                                       │
│  State 1 → State 2 → State 3 → ... → Final State    │
│                                                       │
└──────────────────────────────────────────────────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │ SUCCEEDED│ │  FAILED  │ │ TIMED_OUT│
        └──────────┘ └──────────┘ └──────────┘
                           │
                           ▼
                    ┌──────────┐
                    │ ABORTED  │ (arrêt manuel)
                    └──────────┘
```

### Statuts d'exécution

| Statut | Description |
|--------|-------------|
| **RUNNING** | En cours d'exécution |
| **SUCCEEDED** | Terminé avec succès |
| **FAILED** | Terminé en erreur |
| **TIMED_OUT** | Timeout atteint |
| **ABORTED** | Arrêté manuellement |

---

## 🏗️ COMPOSANTS D'UNE STATE MACHINE

### Structure JSON (ASL)

```json
{
  "Comment": "Description du workflow",
  "StartAt": "FirstState",
  "States": {
    "FirstState": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...",
      "Next": "SecondState"
    },
    "SecondState": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...",
      "End": true
    }
  }
}
```

### Éléments clés

| Élément | Obligatoire | Description |
|---------|-------------|-------------|
| `Comment` | Non | Description du workflow |
| `StartAt` | Oui | Nom du premier état |
| `States` | Oui | Définition de tous les états |
| `TimeoutSeconds` | Non | Timeout global |
| `Version` | Non | Version ASL (défaut: "1.0") |

---

## 📝 TYPES D'ÉTATS

### 1. Task - Exécuter une action

```json
{
  "Type": "Task",
  "Resource": "arn:aws:lambda:eu-west-3:123456789:function:MyFunction",
  "Next": "NextState"
}
```

**Ressources supportées :**
- Lambda functions
- AWS SDK integrations (DynamoDB, SQS, SNS, etc.)
- Activity tasks
- API Gateway
- ECS/Fargate tasks

---

### 2. Choice - Branchement conditionnel

```json
{
  "Type": "Choice",
  "Choices": [
    {
      "Variable": "$.status",
      "StringEquals": "SUCCESS",
      "Next": "SuccessState"
    },
    {
      "Variable": "$.count",
      "NumericGreaterThan": 100,
      "Next": "HighVolumeState"
    }
  ],
  "Default": "DefaultState"
}
```

**Opérateurs de comparaison :**

| Opérateur | Types supportés |
|-----------|-----------------|
| `StringEquals` | String |
| `StringGreaterThan` | String |
| `NumericEquals` | Number |
| `NumericGreaterThan` | Number |
| `BooleanEquals` | Boolean |
| `TimestampEquals` | Timestamp |
| `IsPresent` | Any |
| `IsNull` | Any |
| `IsString` | Any |
| `IsNumeric` | Any |

---

### 3. Parallel - Exécution en parallèle

```json
{
  "Type": "Parallel",
  "Branches": [
    {
      "StartAt": "Branch1Task",
      "States": {
        "Branch1Task": {
          "Type": "Task",
          "Resource": "arn:aws:lambda:...:function:SendEmail",
          "End": true
        }
      }
    },
    {
      "StartAt": "Branch2Task",
      "States": {
        "Branch2Task": {
          "Type": "Task",
          "Resource": "arn:aws:lambda:...:function:SendSMS",
          "End": true
        }
      }
    }
  ],
  "Next": "FinalState"
}
```

**Output :** Array des résultats de chaque branche.

---

### 4. Map - Itérer sur une liste

```json
{
  "Type": "Map",
  "ItemsPath": "$.orders",
  "Iterator": {
    "StartAt": "ProcessOrder",
    "States": {
      "ProcessOrder": {
        "Type": "Task",
        "Resource": "arn:aws:lambda:...:function:ProcessOrder",
        "End": true
      }
    }
  },
  "Next": "AllOrdersProcessed"
}
```

**Paramètres Map :**
| Paramètre | Description |
|-----------|-------------|
| `ItemsPath` | Chemin vers l'array à itérer |
| `MaxConcurrency` | Parallélisme (0 = illimité) |
| `Iterator` | State machine pour chaque item |

---

### 5. Wait - Attendre

```json
// Attendre un temps fixe
{
  "Type": "Wait",
  "Seconds": 300,
  "Next": "NextState"
}

// Attendre jusqu'à une date
{
  "Type": "Wait",
  "Timestamp": "2024-12-31T23:59:59Z",
  "Next": "NextState"
}

// Attendre selon l'input
{
  "Type": "Wait",
  "SecondsPath": "$.waitTime",
  "Next": "NextState"
}
```

---

### 6. Pass - Transformer les données

```json
{
  "Type": "Pass",
  "Result": {
    "status": "processed",
    "timestamp": "2024-01-15"
  },
  "ResultPath": "$.processingInfo",
  "Next": "NextState"
}
```

**Utilité :**
- Injecter des données statiques
- Transformer l'input
- Debug (voir les données)

---

### 7. Succeed et Fail - Terminer

```json
// Succès
{
  "Type": "Succeed"
}

// Échec
{
  "Type": "Fail",
  "Error": "ValidationError",
  "Cause": "Input data is invalid"
}
```

---

## 🔐 IAM POUR STEP FUNCTIONS

### Trust Policy (qui peut assumer le rôle)

```json
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
```

### Permissions pour invoquer Lambda

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": [
        "arn:aws:lambda:eu-west-3:123456789:function:validate-input",
        "arn:aws:lambda:eu-west-3:123456789:function:process-data",
        "arn:aws:lambda:eu-west-3:123456789:function:send-notification"
      ]
    }
  ]
}
```

### Permissions pour CloudWatch Logs

```json
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
```

---

## 💰 COÛTS

### Step Functions Standard

| Composant | Prix |
|-----------|------|
| **Free tier** | 4000 transitions/mois (permanent) |
| **Après free tier** | $0.025 par 1000 transitions |

### Step Functions Express

| Composant | Prix |
|-----------|------|
| **Exécutions** | $1.00 par million |
| **Durée** | $0.00001667 par GB-seconde |

### Exemple de calcul (Standard)

**Workflow avec 5 états, 10 000 exécutions/mois :**
```
Transitions = 10000 × 5 = 50000
Free tier = 4000
Payantes = 50000 - 4000 = 46000
Coût = (46000 / 1000) × $0.025 = $1.15/mois
```

---

## 📊 LIMITES

| Limite | Standard | Express |
|--------|----------|---------|
| **Durée max exécution** | 1 an | 5 minutes |
| **Historique** | 90 jours | CloudWatch Logs |
| **Taille input/output** | 256 KB | 256 KB |
| **Exécutions simultanées** | 1 000 000 | 100 000 |
| **Transitions/seconde** | 2 000 | 100 000 |
| **State machines/compte** | 10 000 | 10 000 |

---

## 🆚 QUAND UTILISER STEP FUNCTIONS ?

### ✅ Utiliser Step Functions si :

- Workflow multi-étapes
- Besoin de visualisation
- Gestion d'erreurs complexe
- Exécution longue (heures/jours)
- Coordination de services
- Besoin d'audit/historique

### ❌ Ne pas utiliser si :

- Simple appel Lambda → Lambda
- Latence critique (< 100ms)
- Très haut débit (> 100K/sec Standard)
- Budget très serré

### Alternatives

| Besoin | Alternative |
|--------|-------------|
| Simple orchestration | Lambda → Lambda direct |
| Event-driven | EventBridge |
| Message queue | SQS |
| Pub/Sub | SNS |

---

## ✅ CHECKLIST STEP FUNCTIONS

```
□ Workflow dessiné/planifié
□ States identifiés et typés
□ Lambda functions créées
□ IAM role configuré
□ Gestion erreurs (Retry/Catch)
□ Logging CloudWatch activé
□ Tests avec données réelles
□ Alarmes configurées
```

---

## 🔗 LIENS

- **Lambda Workflows** → [02-Lambda-Workflows.md](./02-Lambda-Workflows.md)
- **ASL Language** → [03-ASL-States-Language.md](./03-ASL-States-Language.md)
- **Error Handling** → [06-Error-Handling.md](./06-Error-Handling.md)
- **CLI Commands** → [CLI-Commands.md](./CLI-Commands.md)

---

[⬅️ Retour au README](./README.md)
