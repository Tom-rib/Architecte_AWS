# Step Functions App - Job 9 🔄

Application de workflow serverless avec Step Functions et Lambda.

## 📁 Structure

```
step-functions-app/
├── lambda/
│   ├── validate-input.py    ← Valide les données
│   ├── process-data.py      ← Traite les données
│   └── send-notification.py ← Envoie une notification
├── iam/
│   ├── lambda-trust-policy.json       ← Trust policy Lambda
│   ├── stepfunctions-trust-policy.json ← Trust policy Step Functions
│   └── lambda-invoke-policy.json      ← Policy pour invoquer Lambda
├── state-machine.json       ← Définition du workflow (⚠️ remplacer ACCOUNT_ID)
├── test-input.json          ← Données de test
└── README.md
```

## ⚠️ AVANT DE COMMENCER

Remplacer `ACCOUNT_ID` dans les fichiers :
- `state-machine.json` (3 endroits)
- `iam/lambda-invoke-policy.json` (3 endroits)

Pour trouver ton Account ID :
```bash
aws sts get-caller-identity --query Account --output text
```

## 🔄 Workflow

```
Input → ValidateInput → ProcessData → SendNotification → Output
              ↓              ↓              ↓
           [Erreur]      [Erreur]      [Erreur]
              ↓              ↓              ↓
              └──────→ HandleError ←───────┘
```

## 📊 Ressources AWS créées

- 3 Lambda Functions
- 1 State Machine Step Functions
- 2 IAM Roles (Lambda + Step Functions)

## 💰 Coûts

- **Step Functions** : 4000 transitions/mois GRATUITES
- **Lambda** : 1M requêtes/mois GRATUITES
- **CloudWatch Logs** : 5GB/mois GRATUIT
