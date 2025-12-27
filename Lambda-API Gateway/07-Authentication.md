# Authentification API 🔐

Sécuriser votre API REST pour que seuls les clients autorisés puissent l'appeler.

---

## 🎯 OPTIONS

| Type | Comment | Sécurité | Cas d'usage |
|------|---------|----------|-----------|
| **Aucune** | Public | ❌ Faible | Demo, API publique |
| **API Key** | Header x-api-key | ⚠️ Moyen | Backend-to-backend |
| **IAM** | AWS Signature | ✅ Fort | AWS services |
| **Cognito** | User login | ✅ Fort | Apps mobiles, SPA |
| **JWT** | Bearer token | ✅ Fort | Microservices |
| **Lambda Authorizer** | Custom logic | ✅ Fort | Contrôle précis |

---

## 🔑 OPTION 1 : API KEY (Simple)

Idéal pour : backend-to-backend, partenaires fiables

### Créer API Key

```
1. API Gateway > API Keys
2. Create API key
3. Name: mobile-app-key
4. Create API key
5. Copier la clé
```

### Protéger ressource

```
1. API Gateway > Resources > /hello
2. GET method > Method Request
3. API Key Required: ✓ true
4. Save
5. Actions > Deploy API
```

### Client utilise API Key

```bash
# cURL
curl -X GET \
  https://your-api.../prod/hello \
  -H "x-api-key: sk-1234567890"
```

```javascript
// JavaScript
fetch('https://your-api.../prod/hello', {
  headers: {
    'x-api-key': 'sk-1234567890'
  }
})
```

```python
# Python
import requests

response = requests.get(
  'https://your-api.../prod/hello',
  headers={'x-api-key': 'sk-1234567890'}
)
```

---

## 🔐 OPTION 2 : COGNITO (User Login)

Idéal pour : apps mobiles, SPA avec utilisateurs

### Créer Cognito User Pool

```
1. AWS Console > Cognito > Create user pool
2. User sign-up options
3. Configure sign-up experience
4. Required attributes: email
5. Create user pool
6. Récupérer Pool ID
```

### Intégrer dans API Gateway

```
1. API Gateway > Authorizers > Create authorizer
2. Name: cognito-auth
3. Type: Cognito User Pool
4. User Pool: Sélectionner pool créée
5. Token source: Authorization
6. Create
```

### Protéger ressource

```
1. API > /hello > GET > Method Request
2. Authorization: cognito-auth
3. Save et Deploy
```

### Client s'authentifie

```bash
# 1. Créer utilisateur
aws cognito-idp sign-up \
  --client-id YOUR_CLIENT_ID \
  --username tom@example.com \
  --password MyPass123!

# 2. Confirmer email
aws cognito-idp confirm-sign-up \
  --client-id YOUR_CLIENT_ID \
  --username tom@example.com \
  --confirmation-code CODE_FROM_EMAIL

# 3. Se connecter
aws cognito-idp initiate-auth \
  --client-id YOUR_CLIENT_ID \
  --auth-flow USER_PASSWORD_AUTH \
  --auth-parameters USERNAME=tom@example.com,PASSWORD=MyPass123!

# Récupérer IdToken du response
```

### Appeler API avec token

```bash
curl -X GET \
  https://your-api.../prod/hello \
  -H "Authorization: Bearer ID_TOKEN_HERE"
```

---

## 🛡️ OPTION 3 : LAMBDA AUTHORIZER (Custom)

Idéal pour : logique complexe, validations spéciales

### Créer fonction authorizer

```python
def lambda_handler(event, context):
    # Parser token
    token = event['authorizationToken']
    
    # Valider token
    if token == 'sk-valid-token-123':
        # Autorisé ✅
        return generate_policy('user', 'Allow', event['methodArn'])
    else:
        # Refusé ❌
        return generate_policy('user', 'Deny', event['methodArn'])

def generate_policy(principal_id, effect, resource):
    return {
        'principalId': principal_id,
        'policyDocument': {
            'Version': '2012-10-17',
            'Statement': [
                {
                    'Action': 'execute-api:Invoke',
                    'Effect': effect,
                    'Resource': resource
                }
            ]
        }
    }
```

### Créer Authorizer dans API Gateway

```
1. API Gateway > Authorizers > Create authorizer
2. Name: custom-auth
3. Type: Lambda
4. Function ARN: Sélectionner fonction
5. Identity Sources: method.request.header.Authorization
6. Create
```

### Protéger ressource

```
1. API > /hello > GET > Method Request
2. Authorization: custom-auth
3. Deploy
```

---

## 🔒 COMPARAISON

| Aspect | API Key | Cognito | Lambda Auth |
|--------|---------|---------|-------------|
| **Setup** | 5 min | 30 min | 15 min |
| **Sécurité** | Moyenne | Haute | Haute |
| **Cost** | Gratuit | $0.50-4/user | Gratuit |
| **Scaling** | Automatique | Automatique | Automatique |
| **Users** | Non | Oui | Custom |
| **Refresh tokens** | Non | Oui | Custom |

---

## ⚠️ BONNES PRATIQUES

✅ **À FAIRE :**
```
- Stocker clés en Secrets Manager
- Utiliser HTTPS toujours
- Rotation des clés régulièrement
- Logs des accès pour audit
- Rate limiting par API key
```

❌ **À ÉVITER :**
```
- Clés hardcodées dans code
- Partager API key publiquement
- Clés sans expiration
- Pas de monitoring
- Même clé pour tous les clients
```

---

## 📊 QUICK SETUP

### Minimal (API Key)

```
1. API Gateway > API Keys > Create
2. Resources > /hello > GET > API Key Required: true
3. Deploy
4. Client ajoute header: x-api-key
```

**Temps total : 5 min**

### Production (Cognito)

```
1. Cognito > Create User Pool
2. API Gateway > Authorizers > Cognito
3. Resources > /hello > GET > Authorization: cognito
4. Deploy
5. Client s'authentifie avec username/password
```

**Temps total : 30 min**

---

## 📌 NOTES

- **Free tier** : 50,000 API calls gratuit (Cognito)
- **Secrets Manager** : $0.40/secret/mois
- **Rate limiting** : Via API Gateway usage plans
- **Audit logging** : CloudTrail enregistre tous les appels

---

[⬅️ Retour](./README.md) | [➡️ CORS](./06-CORS.md)

