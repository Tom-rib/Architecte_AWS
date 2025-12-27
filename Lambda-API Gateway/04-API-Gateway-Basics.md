# API Gateway Basics 🌐

API Gateway = point d'entrée pour créer des API REST qui déclenchent Lambda.

---

## 🎯 À quoi ça sert ?

- **Point d'entrée HTTP** pour vos Lambdas
- Transformer **requêtes HTTP** → événements Lambda
- Gérer **versioning** (stages : dev, prod)
- **Throttling** et rate limiting
- **Logs et monitoring** automatiques

---

## 📊 Composants

```
API Gateway
├── REST API (point d'entrée)
├── Resources (paths : /hello, /users, etc)
├── Methods (GET, POST, PUT, DELETE)
├── Integrations (lier à Lambda, HTTP, etc)
├── Stages (dev, prod, test)
├── Models (validation JSON)
└── Authorizers (authentification)
```

---

## 🔄 FLUX HTTP

```
CLIENT
  ↓
HTTP Request (GET /hello?name=Tom)
  ↓
API Gateway
  ├─ Route matching (/hello)
  ├─ Method matching (GET)
  ├─ Auth check
  ├─ Body validation
  └─ Transform to Lambda event
    ↓
Lambda Function (your code)
  ├─ Execute
  ├─ Return statusCode + body
  └─ Transform to HTTP response
    ↓
API Gateway
  ├─ Status code
  ├─ Headers
  └─ Body
    ↓
HTTP Response
  ↓
CLIENT
```

---

## 📥 FORMAT EVENT (API Gateway → Lambda)

```python
{
  'requestContext': {
    'http': {
      'method': 'GET',
      'path': '/hello',
      'protocol': 'HTTP/1.1',
      'sourceIp': '1.2.3.4',
      'userAgent': 'Mozilla/5.0...'
    },
    'accountId': '123456789012',
    'apiId': 'abc123',
    'domainName': 'abc123.execute-api.eu-west-3.amazonaws.com',
    'requestId': 'xyz789',
    'stage': 'prod',
    'time': '26/Dec/2024:12:00:00 +0000',
    'timeEpoch': 1703594400000
  },
  'headers': {
    'accept': '*/*',
    'content-type': 'application/json',
    'host': 'abc123.execute-api.eu-west-3.amazonaws.com',
    'user-agent': 'curl/7.68.0'
  },
  'queryStringParameters': {
    'name': 'Tom'
  },
  'body': None,
  'isBase64Encoded': False
}
```

---

## 📤 FORMAT RESPONSE (Lambda → API Gateway)

```python
{
  'statusCode': 200,
  'headers': {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*'
  },
  'body': '{"message": "Hello Tom"}',
  'isBase64Encoded': False
}
```

---

## 🎯 CONCEPTS

| Concept | Def | Exemple |
|---------|-----|---------|
| **Resource** | Path URL | /hello, /users, /products |
| **Method** | HTTP verb | GET, POST, PUT, DELETE |
| **Integration** | Destination | Lambda, HTTP, Mock |
| **Stage** | Environnement | dev, prod, test |
| **Invoke URL** | URL publique | https://api.example.com/prod/hello |
| **Model** | JSON schema | Validation request body |
| **Authorizer** | Authentification | API Key, JWT, IAM |

---

## ⚠️ LIMITATIONS

- **Payload max** : 10 MB (async), 6 MB (sync)
- **Timeout** : 29 secondes (Lambda max 15 min)
- **Rate limit** : 10,000 req/sec par défaut

---

## 💰 PRICING

```
1 million API calls = GRATUIT/mois (free tier)
Au-delà = $3.50 per million API calls
```

---

[⬅️ Retour](./README.md) | [➡️ Créer API](./05-Create-API.md)
