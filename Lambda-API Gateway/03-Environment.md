# Environment Variables 🔒

Gérer configuration et secrets sans hardcoder dans le code.

---

## 🎯 CONCEPT

Variables d'environnement = configuration externe accessible par Lambda.

```python
# Au lieu de hardcoder:
db_password = "myPassword123"  # ❌ DANGEREUX

# Utiliser variable:
db_password = os.environ.get('DB_PASSWORD')  # ✅ SÉCURISÉ
```

---

## 📝 AJOUTER VARIABLES (Console)

### Étapes

```
1. AWS Lambda > my-api-function
2. Configuration ▼
3. Environment variables > Edit
4. Add environment variable
```

### Écran "Edit environment variables"

```
┌─────────────────────────────────────────┐
│ Key                    Value             │
├─────────────────────────────────────────┤
│ DATABASE_URL      │ postgres://user:pwd │
│ API_KEY           │ sk-1234567890      │
│ LOG_LEVEL         │ INFO               │
│ ENVIRONMENT       │ production         │
│                                         │
│          [Add environment variable]     │
│                                         │
│              [Save]                     │
└─────────────────────────────────────────┘
```

**CLIQUER : Save**

---

## 🐍 UTILISER DANS PYTHON

### Code complet

```python
import os
import json

def lambda_handler(event, context):
    # Lire les variables
    db_url = os.environ.get('DATABASE_URL', 'localhost')
    api_key = os.environ.get('API_KEY', '')
    log_level = os.environ.get('LOG_LEVEL', 'INFO')
    
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps({
            'database': db_url,
            'api_key': api_key[:5] + '...' if api_key else 'NOT SET',
            'log_level': log_level
        })
    }
```

### Appeler l'API

```
GET https://your-api.../prod/hello
```

**Réponse :**

```json
{
  "database": "postgres://user:pwd",
  "api_key": "sk-12...",
  "log_level": "INFO"
}
```

---

## 💻 VIA CLI

### Ajouter variables

```bash
aws lambda update-function-configuration \
  --function-name my-api-function \
  --environment Variables="{
    DATABASE_URL=postgres://user:pwd,
    API_KEY=sk-1234567890,
    LOG_LEVEL=INFO
  }" \
  --region eu-west-3
```

### Voir variables

```bash
aws lambda get-function-configuration \
  --function-name my-api-function \
  --region eu-west-3 \
  --query 'Environment.Variables'
```

### Supprimer variable

```bash
aws lambda update-function-configuration \
  --function-name my-api-function \
  --environment Variables="{DATABASE_URL=postgres://user:pwd}" \
  --region eu-west-3
```

---

## 🔐 SÉCURITÉ : NE PAS STOCKER SECRETS

❌ **DANGEREUX :**
```
API_KEY = sk-1234567890    (visible dans logs)
DB_PASSWORD = admin123      (clair en texte)
```

✅ **SÉCURISÉ :**

### Option 1: AWS Secrets Manager

```python
import boto3
import json

secrets = boto3.client('secretsmanager')

def lambda_handler(event, context):
    # Récupérer secret depuis Secrets Manager
    secret = secrets.get_secret_value(
        SecretId='my-db-password'
    )
    
    # Parser JSON
    creds = json.loads(secret['SecretString'])
    password = creds['password']
    
    # Utiliser password (JAMAIS logged)
    return {
        'statusCode': 200,
        'body': json.dumps({'status': 'connected'})
    }
```

### Créer secret

```bash
aws secretsmanager create-secret \
  --name my-db-password \
  --secret-string '{"username":"admin","password":"MySecurePass123"}' \
  --region eu-west-3
```

### Ajouter permission IAM

Lambda doit pouvoir lire Secrets Manager :

```bash
# Politique JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "secretsmanager:GetSecretValue",
      "Resource": "arn:aws:secretsmanager:eu-west-3:ACCOUNT:secret:my-db-password*"
    }
  ]
}
```

**Ajouter à Lambda Execution Role (console IAM)**

---

## 📊 CAS D'USAGE

| Type | Stockage | Sécurité |
|------|----------|----------|
| **Config publique** | Environment Variables | ✅ OK |
| **Config privée** | Secrets Manager | ✅✅ Meilleur |
| **Clés API** | Secrets Manager | ✅✅ Meilleur |
| **DB passwords** | Secrets Manager | ✅✅ Meilleur |
| **Connexion strings** | Secrets Manager | ✅✅ Meilleur |
| **Feature flags** | Environment Variables | ✅ OK |

---

## 📌 NOTES

- **Variables limitées** : Clé max 256 chars, valeur max 4 KB
- **Chiffrement** : Secrets Manager chiffre automatiquement
- **Cost Secrets Manager** : $0.40 secret/mois + $0.05 par appel API
- **Free tier** : Environment Variables gratuit illimité

---

[⬅️ Retour](./README.md) | [➡️ Authentification](./07-Authentication.md)

