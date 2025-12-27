# Créer et Déployer une Fonction Lambda 📝

Guide COMPLET step-by-step pour créer votre première fonction Lambda avec code prêt à copier.

---

## 🎯 ÉTAPES RAPIDES

1. Ouvrir AWS Console → Lambda
2. Copier code Python ou Node.js
3. Tester dans console
4. Récupérer ARN fonction

---

## 🔴 ÉTAPE 1 : ACCÉDER À LAMBDA

### Dans AWS Console

```
1. Aller à https://eu-west-3.console.aws.amazon.com/
2. Chercher "Lambda"
3. Cliquer sur "Lambda"
4. Cliquer sur "Create function"
```

### Écran "Create function"

Vous devez voir 3 options :
- Author from scratch ← CLIQUER ICI
- Use a blueprint
- Use a container image

---

## 🟠 ÉTAPE 2 : CONFIGURER LA FONCTION

Remplir les champs suivants :

```
┌─────────────────────────────────────────┐
│ Function name*                          │
│ ┌─────────────────────────────────────┐ │
│ │ my-api-function                     │ │  (ex: hello-api)
│ └─────────────────────────────────────┘ │
│                                         │
│ Runtime*                                │
│ ┌─────────────────────────────────────┐ │
│ │ Python 3.11                    ▼   │ │  (sélectionner)
│ └─────────────────────────────────────┘ │
│                                         │
│ ☑ Change default execution role         │
│                                         │
│ Execution role*                         │
│ ┌─ Create a new role with basic...─┐   │
│ │ λ-basic-execution ▼            │ │   │
│ └────────────────────────────────┘ │
│                                         │
│ ☐ Enable function URL                   │
│ ☐ Enable X-Ray write access             │
│ ☐ Enable CloudWatch Lambda Insights     │
│                                         │
│                    [Create function]   │
└─────────────────────────────────────────┘
```

**VALEURS À ENTRER :**
- Function name : `my-api-function` (ou autre)
- Runtime : `Python 3.11`
- Execution role : `Create a new role...` (défaut)

**CLIQUER : Create function**

---

## 🟡 ÉTAPE 3 : COPIER LE CODE PYTHON

Une fois créée, vous arrivez dans l'éditeur. Voir la section "Code" :

```
┌─ Code ──────────────────────────┐
│ lambda_function.py              │
│ ┌──────────────────────────────┐│
│ │ def lambda_handler(event, co ││
│ │     return {                 ││
│ │         'statusCode': 200,   ││
│ │         'body': json.dumps...││
│ └──────────────────────────────┘│
│ Runtime settings ▼               │
│ Handler: lambda_function.lambda_ │
│ handler                          │
└─────────────────────────────────┘
```

### ✅ Remplacer par ce code (COPIER ENTIÈREMENT)

```python
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Fonction Lambda simple pour API RESTful
    Retourne JSON avec les détails de la requête
    """
    
    try:
        # EXTRAIRE INFOS REQUÊTE
        method = event['requestContext']['http']['method']
        path = event['requestContext']['http']['path']
        
        # PARSER QUERY PARAMETERS
        query_params = event.get('queryStringParameters', {}) or {}
        name = query_params.get('name', 'World')
        
        # CRÉER MESSAGE
        message = f"Hello {name}! Method: {method}, Path: {path}"
        
        # LOG pour CloudWatch
        logger.info(f"Requête reçue: {method} {path}")
        
        # CRÉER RÉPONSE
        response = {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'message': message,
                'method': method,
                'path': path,
                'name': name
            }, indent=2)
        }
        
        return response
        
    except Exception as e:
        logger.error(f"Erreur: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': str(e)
            })
        }
```

**ÉTAPES POUR COPIER :**

1. Sélectionner tout le code actuel (Ctrl+A ou Cmd+A)
2. Supprimer (Delete)
3. Coller le code ci-dessus (Ctrl+V ou Cmd+V)
4. **Cliquer "Deploy"** (bouton orange en haut à droite)

---

## 🟢 ÉTAPE 4 : TESTER LA FONCTION

### Méthode 1 : Test dans la Console (facile)

Après "Deploy", voir section "Test" :

```
┌─ Test ──────────────────────────┐
│ Test event                      │
│ ┌──────────────────────────────┐│
│ │ {                            ││
│ │   "requestContext": {        ││
│ │     "http": {               ││
│ │       "method": "GET",      ││
│ │       "path": "/hello",     ││
│ │       "sourceIp": "1.2.3.4" ││
│ │     }                        ││
│ │   }                          ││
│ │ }                            ││
│ └──────────────────────────────┘│
│                                  │
│              [Test]              │
└──────────────────────────────────┘
```

**FAIRE :**
1. Remplacer le JSON de test par :

```json
{
  "requestContext": {
    "http": {
      "method": "GET",
      "path": "/hello"
    }
  },
  "queryStringParameters": {
    "name": "Tom"
  }
}
```

2. **CLIQUER "Test"**

**RÉSULTAT ATTENDU :**

```
Execution result: Succeeded(logs)

{
  "statusCode": 200,
  "headers": {
    "Content-Type": "application/json"
  },
  "body": "{\"message\": \"Hello Tom! Method: GET, Path: /hello\", \"method\": \"GET\", \"path\": \"hello\", \"name\": \"Tom\"}"
}
```

---

## 🟣 ÉTAPE 5 : ACTIVER FUNCTION URL (BONUS - Optional)

Pour tester l'API directement sans API Gateway :

```
1. Aller en bas de la page Lambda
2. "Function URL" ► "Create function URL"
3. Auth type: NONE (public)
4. CORS: Enable (si frontend)
5. Copier l'URL générée
```

**Exemple URL :**
```
https://abc123def456.lambda-url.eu-west-3.on.aws/
```

**Tester dans le navigateur :**
```
https://abc123def456.lambda-url.eu-west-3.on.aws/?name=Tom
```

Vous devriez voir :
```json
{
  "message": "Hello Tom! Method: GET, Path: /",
  "method": "GET",
  "path": "/",
  "name": "Tom"
}
```

---

## 📝 ALTERNATIVE : CODE NODE.JS

Si vous préférez Node.js au lieu de Python :

```javascript
const aws = require('aws-sdk');

async function handler(event, context) {
    try {
        // EXTRAIRE INFOS
        const method = event.requestContext.http.method;
        const path = event.requestContext.http.path;
        
        // PARSER QUERY
        const queryParams = event.queryStringParameters || {};
        const name = queryParams.name || 'World';
        
        // MESSAGE
        const message = `Hello ${name}! Method: ${method}, Path: ${path}`;
        
        // LOG
        console.log(`Requête: ${method} ${path}`);
        
        // RÉPONSE
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                message: message,
                method: method,
                path: path,
                name: name
            }, null, 2)
        };
        
    } catch (error) {
        console.error('Erreur:', error);
        return {
            statusCode: 500,
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                error: error.message
            })
        };
    }
}

exports.handler = handler;
```

**Pour Node.js :**
1. Créer fonction avec runtime `Node.js 20.x`
2. Remplacer code identiquement
3. Handler reste `index.handler` (ou index.js)

---

## 📊 NEXT STEPS (après avoir une fonction qui marche)

### Option 1 : Connecter à API Gateway (RECOMMANDÉ)
→ [05-Create-API.md](./05-Create-API.md)

### Option 2 : Ajouter Variables d'Environnement
→ [03-Environment.md](./03-Environment.md)

### Option 3 : Monitorer avec CloudWatch
→ [09-Lambda-Logs.md](./09-Lambda-Logs.md)

---

## 🐛 TROUBLESHOOTING

### ❌ Erreur "Handler error"

**Cause probable :** Typo dans le code

**Solution :**
- Vérifier pas d'erreur syntax
- Vérifier indentation Python
- Cliquer "Deploy" avant de tester

### ❌ Erreur "Endpoint does not exist"

**Cause probable :** Function URL pas activée

**Solution :**
- Aller "Function URL" ► "Create function URL"
- Copier URL générée

### ❌ "statusCode is missing"

**Cause probable :** Response pas conforme

**Solution :**
- Vérifier code retourne dict avec `statusCode`
- Pas oublier `json.dumps()` pour le body

---

## 💡 NOTES IMPORTANTES

- **Timeout défaut** : 3 secondes (peut augmenter)
- **Mémoire défaut** : 128 MB (peut augmenter)
- **Logs** : Automatiquement dans CloudWatch
- **Erreurs** : Voir "CloudWatch Logs" pour détails
- **Cold start** : ~100ms première invocation

---

[⬅️ Retour](./README.md) | [➡️ API Gateway](./05-Create-API.md)

