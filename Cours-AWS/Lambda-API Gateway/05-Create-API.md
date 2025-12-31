# Créer une API RESTful avec API Gateway 🌐

Guide COMPLET step-by-step pour créer une API REST qui déclenche votre fonction Lambda.

---

## 🎯 OBJECTIF

Créer une API publique comme :
```
https://your-api.execute-api.eu-west-3.amazonaws.com/prod/hello?name=Tom
```

Qui appelle votre fonction Lambda et retourne :
```json
{
  "message": "Hello Tom!",
  "method": "GET",
  "path": "/hello"
}
```

---

## 🔴 ÉTAPE 1 : CRÉER L'API

### Dans AWS Console

```
1. Aller à https://eu-west-3.console.aws.amazon.com/
2. Chercher "API Gateway"
3. Cliquer sur "API Gateway"
4. Cliquer "Create API"
```

### Écran "Choose an API type"

Voir 3 options :
- **REST API** ← CLIQUER ICI
- HTTP API
- WebSocket API

**CLIQUER : "Build" (sous REST API)**

---

## 🟠 ÉTAPE 2 : CONFIGURER L'API

### Écran "Create REST API"

```
┌──────────────────────────────────────┐
│ Protocol                             │
│ ○ REST                           ✓   │
│ ○ HTTP                               │
│                                      │
│ Create new API                       │
│ ◉ New API                            │
│ ○ Clone from existing API            │
│                                      │
│ API name                             │
│ ┌──────────────────────────────────┐ │
│ │ my-api                           │ │
│ └──────────────────────────────────┘ │
│                                      │
│ Description (Optional)               │
│ ┌──────────────────────────────────┐ │
│ │ My first REST API with Lambda    │ │
│ └──────────────────────────────────┘ │
│                                      │
│ Endpoint Type*                       │
│ ○ Regional                       ✓   │
│ ○ Edge optimized                     │
│ ○ Private                            │
│                                      │
│              [Create API]            │
└──────────────────────────────────────┘
```

**VALEURS À ENTRER :**
- API name : `my-api` (ou autre nom)
- Description : `My first Lambda API`
- Endpoint Type : `Regional`

**CLIQUER : Create API**

---

## 🟡 ÉTAPE 3 : CRÉER RESSOURCE

Après création, vous arrivez dans l'éditeur API. Voir la structure arborescente :

```
Resources
├─ / (root)
   ├─ GET
   ├─ POST
   └─ ...
```

Pour créer une ressource `/hello` :

### Option A : Via Console (facile)

```
1. Cliquer sur "/" (root)
2. Actions ▼ (bouton orange)
3. "Create Resource"
```

### Écran "New Child Resource"

```
┌──────────────────────────────────────┐
│ Resource Name                        │
│ ┌──────────────────────────────────┐ │
│ │ hello                            │ │
│ └──────────────────────────────────┘ │
│                                      │
│ Resource Path                        │
│ ┌──────────────────────────────────┐ │
│ │ /hello                           │ │
│ └──────────────────────────────────┘ │
│                                      │
│ ☐ Enable API Key Required            │
│ ☑ CORS (Cross Origin Resource...     │
│                                      │
│      [Create Resource]               │
└──────────────────────────────────────┘
```

**VALEURS :**
- Resource Name : `hello`
- Resource Path : `/hello` (auto)
- CORS : ☑ (si frontend)

**CLIQUER : Create Resource**

---

## 🟢 ÉTAPE 4 : CRÉER MÉTHODE GET

Vous devez maintenant voir `/hello` sélectionné.

```
Resources
├─ /
   └─ /hello  ← SÉLECTIONNÉ
```

Pour ajouter une méthode GET :

```
1. Cliquer sur "/hello"
2. Actions ▼
3. "Create Method" → "GET"
```

Vous allez voir :

```
┌─ /hello ─ GET ──────────────────┐
│ Integration type:                │
│                                  │
│ ○ HTTP                           │
│ ○ AWS Service                    │
│ ◉ Lambda Function                │
│ ○ Mock                           │
│ ○ VPC Link                       │
│                                  │
│ Lambda Function                  │
│ ┌──────────────────────────────┐ │
│ │ my-api-function        ▼    │ │
│ └──────────────────────────────┘ │
│                                  │
│ ☐ Lambda Proxy Integration       │
│ (laissez non-coché)              │
│                                  │
│         [Save]                   │
└──────────────────────────────────┘
```

**IMPORTANTS :**
- Integration type : `Lambda Function` ← déjà sélectionné
- Lambda Function : Sélectionner `my-api-function`
- Lambda Proxy Integration : **LAISSER DÉCOCHÉ** ❌

**CLIQUER : Save**

### Confirmation

Une popup : "Add Permission to Lambda Function"

```
┌────────────────────────────────┐
│ You are about to give API      │
│ Gateway permission to invoke   │
│ my-api-function                │
│                                │
│        [Cancel]    [OK]        │
└────────────────────────────────┘
```

**CLIQUER : OK**

---

## 🟣 ÉTAPE 5 : TESTER L'API (avant déploiement)

Vous devez voir :

```
/hello - GET
├─ Method Request
├─ Integration Request
├─ Integration Response
└─ Method Response
```

Pour tester :

```
1. Cliquer "Method Request" 
   (voir les settings)
2. Revenir à "GET"
3. Cliquer le petit ⚡ "Test"
```

### Écran Test

```
┌─ Test /hello GET ─────────────────┐
│                                   │
│ Method : GET                      │
│ Path: /hello                      │
│                                   │
│ Query Strings                     │
│ ┌──────────────────────────────┐  │
│ │ name=Tom                     │  │
│ └──────────────────────────────┘  │
│                                   │
│              [Test]               │
│                                   │
│ Response Headers:                 │
│ {"Content-Type":"application/...} │
│                                   │
│ Response Body:                    │
│ {                                 │
│   "message": "Hello Tom!",        │
│   "method": "GET",                │
│   "path": "/hello",               │
│   "name": "Tom"                   │
│ }                                 │
│                                   │
│ Logs:                             │
│ Mon Dec 26 12:00:00 UTC 2024     │
│ Endpoint request URI: ...         │
│ Execution completed successfully  │
└───────────────────────────────────┘
```

✅ **SI VERT "Execution completed successfully"** = OK!

❌ **SI ROUGE** → Voir Troubleshooting ci-bas

---

## 🔵 ÉTAPE 6 : DÉPLOYER L'API

Maintenant déployer pour avoir une URL publique :

```
1. Cliquer "Actions" (orange)
2. "Deploy API"
```

### Écran Deploy

```
┌──────────────────────────────────────┐
│ Deployment stage                     │
│ ┌──────────────────────────────────┐ │
│ │ [Create new stage]          ▼   │ │
│ │ Nouvelle stage: prod             │ │
│ └──────────────────────────────────┘ │
│                                      │
│ Stage name                           │
│ ┌──────────────────────────────────┐ │
│ │ prod                             │ │
│ └──────────────────────────────────┘ │
│                                      │
│ Stage description (Optional)         │
│ ┌──────────────────────────────────┐ │
│ │ Production environment           │ │
│ └──────────────────────────────────┘ │
│                                      │
│              [Deploy]                │
└──────────────────────────────────────┘
```

**VALEURS :**
- Deployment stage : `[Create new stage]`
- Stage name : `prod`

**CLIQUER : Deploy**

---

## 🟢 ÉTAPE 7 : RÉCUPÉRER L'URL

Après déploiement, vous voyez :

```
Deployment successful

Invoke URL:
https://abc123def.execute-api.eu-west-3.amazonaws.com/prod
```

**COPIER CETTE URL**

Pour tester votre API :

```
https://abc123def.execute-api.eu-west-3.amazonaws.com/prod/hello?name=Tom
```

### Tester dans le navigateur

Ouvrir dans un nouvel onglet :
```
https://your-invoke-url/prod/hello?name=Tom
```

Vous devriez voir :
```json
{
  "message": "Hello Tom! Method: GET, Path: /hello",
  "method": "GET",
  "path": "/hello",
  "name": "Tom"
}
```

✅ **API FONCTIONNE !**

---

## 📊 STRUCTURE COMPLÈTE

Après tout cela, vous avez :

```
API Gateway (my-api)
│
└─ Stage: prod
   │
   └─ Resource: /hello
      │
      └─ Method: GET
         │
         └─ Lambda Integration → my-api-function
            │
            └─ Response JSON
```

---

## 🔐 OPTIONNEL : AJOUTER PLUS DE ROUTES

Pour créer `/users` ou `/products` :

Répéter Étapes 3-4 :
1. Créer Resource `/users`
2. Créer Méthode GET (ou POST, PUT, DELETE)
3. Intégrer à une autre Lambda
4. Re-déployer

---

## 🎁 EXEMPLE : API COMPLÈTE

```
GET  /hello?name=Tom          → hello-api-function
GET  /users                   → list-users-function
GET  /users/{id}              → get-user-function
POST /users                   → create-user-function
PUT  /users/{id}              → update-user-function
DELETE /users/{id}            → delete-user-function
```

Chaque route = 1 Resource + 1 Method + 1 Lambda (ou plus)

---

## 🐛 TROUBLESHOOTING

### ❌ "Execution failed with status code: 502"

**Cause :** Lambda Proxy Integration mal configurée

**Solution :**
- Aller Integration Request
- Vérifier "Use Lambda Proxy Integration" = OFF ❌
- Sauvegarder

### ❌ "Execution failed with status code: 500"

**Cause :** Erreur dans le code Lambda

**Solution :**
- Aller CloudWatch Logs
- Chercher la fonction Lambda
- Voir le message d'erreur exact

### ❌ "The specified action cannot be performed on the resource"

**Cause :** Lambda pas trouvée

**Solution :**
- Vérifier fonction Lambda existe
- Vérifier région = eu-west-3
- Retaper le nom

### ❌ "Execution completed but invalid output"

**Cause :** Response Lambda invalide

**Solution :**
- Vérifier statusCode existe
- Vérifier body est string JSON
- Vérifier pas d'erreur dans Lambda logs

---

## 💡 NOTES IMPORTANTES

- **Invoke URL** : Point d'accès public
- **Stage** : prod, dev, test, etc
- **Déployer** : Après chaque changement
- **Logs** : CloudWatch Logs > /aws/apigateway/...
- **Rate Limiting** : 10,000 requêtes/sec par défaut

---

## 📊 NEXT STEPS

### 1. Ajouter CORS (si frontend)
→ [06-CORS.md](./06-CORS.md)

### 2. Monitorer les logs
→ [09-Lambda-Logs.md](./09-Lambda-Logs.md)

### 3. Créer plus de ressources
→ Répéter étapes 3-4

### 4. Ajouter authentification
→ [07-Authentication.md](./07-Authentication.md)

---

[⬅️ Retour](./README.md) | [➡️ CloudWatch Logs](./09-Lambda-Logs.md)

