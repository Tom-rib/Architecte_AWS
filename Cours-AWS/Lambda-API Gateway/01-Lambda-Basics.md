# Lambda Basics 🚀

AWS Lambda = plateforme de calcul sans serveur pour exécuter du code à la demande.

---

## 🎯 À quoi ça sert ?

- Exécuter code Python, Node.js, Java, etc
- **Sans gérer serveur** (EC2)
- Déclenché par événements (API, S3, DynamoDB, etc)
- Payer uniquement ce que vous utilisez
- Scaling automatique instantané

---

## 📊 Comparaison : EC2 vs Lambda

| | EC2 | Lambda |
|---|---|---|
| **Setup** | 1h + configuration | 5 min |
| **Serveur** | Vous gérez | AWS gère |
| **Coût idle** | 24€/mois minimum | 0€ (pas utilisé) |
| **Scaling** | Manuel / ASG | Auto instantané |
| **Démarrage** | 2-5 minutes | 100ms (cold start) |
| **Durée max** | Illimitée | 15 minutes |
| **Idéal pour** | Apps longues 24/7 | APIs courtes événementielles |

---

## 🔧 RUNTIMES (environnements)

Lambda supporte plusieurs langages :

| Runtime | Version | Gratuit | Cas d'usage |
|---------|---------|---------|-----------|
| **Python** | 3.11, 3.12 | ✓ | Data, scripting, web |
| **Node.js** | 18.x, 20.x | ✓ | APIs, JS, npm packages |
| **Java** | 11, 17, 21 | ✓ | Entreprise, performance |
| **Go** | 1.x | ✓ | Haute performance |
| **C#** | .NET 6, 8 | ✓ | Microsoft stack |
| **Ruby** | 3.2 | ✓ | Rails, scripts |
| **Custom** | Docker | ✓ | N'importe quoi |

**Pour ce job : Python 3.11 (le plus facile)**

---

## 📦 COMPOSANTS LAMBDA

```
Lambda Function
├── Code (Python/Node.js)
├── Handler (fonction entrypoint)
├── Runtime (environnement)
├── Memory (128 MB - 10 GB)
├── Timeout (1 sec - 900 sec)
├── Environment Variables (config)
├── Layers (shared code)
├── VPC (optionnel)
└── IAM Role (permissions)
```

---

## 🔄 CYCLE D'EXÉCUTION

```
1. INVOCATION
   └─ API Gateway envoie requête HTTP
   
2. COLD START (première fois)
   └─ AWS init conteneur
   └─ ~100-500ms (peut varier)
   
3. WARM START (appels suivants)
   └─ Conteneur réutilisé
   └─ ~1-5ms
   
4. HANDLER
   └─ Votre fonction s'exécute
   └─ Reçoit event + context
   
5. RESPONSE
   └─ Retourne résultat JSON
   
6. LOGS
   └─ CloudWatch enregistre
```

---

## 📥 STRUCTURE EVENT (API Gateway)

Quand API Gateway déclenche Lambda, voici ce qu'elle reçoit :

```python
event = {
    'requestContext': {
        'http': {
            'method': 'GET',      # HTTP method
            'path': '/hello',     # URL path
            'sourceIp': '1.2.3.4'
        }
    },
    'queryStringParameters': {
        'name': 'Tom'  # ?name=Tom
    },
    'body': None,  # POST data
    'headers': {
        'content-type': 'application/json'
    }
}
```

---

## 📤 STRUCTURE RESPONSE (API Gateway)

La fonction Lambda doit retourner :

```python
response = {
    'statusCode': 200,  # HTTP status
    'body': '{"message": "Hello"}',  # JSON string
    'headers': {
        'Content-Type': 'application/json'
    }
}
```

---

## 💾 CONTEXT (métadonnées)

Le paramètre `context` contient des infos sur l'exécution :

```python
context.aws_request_id          # ID unique requête
context.invoked_function_arn    # ARN fonction
context.function_name           # Nom fonction
context.memory_limit_in_mb      # Mémoire allouée
context.get_remaining_time_in_millis()  # Temps restant
context.log_group_name          # CloudWatch log group
context.log_stream_name         # CloudWatch log stream
```

---

## ⚙️ CONFIGURATION DE BASE

| Paramètre | Défaut | Min | Max | Impact |
|-----------|--------|-----|-----|--------|
| **Memory** | 128 MB | 128 MB | 10,240 MB | Coût + CPU |
| **Timeout** | 3 sec | 1 sec | 900 sec | Coût |
| **Ephemeral Storage** | 512 MB | 512 MB | 10,240 MB | Coût |
| **Concurrency** | 1000 | 0 | Custom | Throttling |

**Recommandations :**
- **API simple** → 128-256 MB + 3-5 sec timeout
- **API data heavy** → 512-1024 MB + 10-30 sec timeout
- **Data processing** → 1024-3008 MB + 60-300 sec timeout

---

## 📊 TARIFICATION

```
Calcul :
- Prix = (Durée en ms × Mémoire en GB) × $0.0000166667
- Exemple : 1000ms × 0.128GB × $0.0000166667 = $0.000002

Free Tier :
- 1 million requêtes gratuites/mois ✓
- 400,000 GB-secondes gratuites/mois ✓

Coût réel (hors free tier) :
- $0.20 par million requêtes
- $0.0000166667 par GB-seconde
```

---

## 🎁 AVANTAGES LAMBDA

✓ **Pas de serveur à gérer**
✓ **Payer par usage** (au ms)
✓ **Scaling automatique**
✓ **Cold start rapide** (~100ms)
✓ **Intégration AWS seamless**
✓ **Multi-language support**
✓ **Monitoring intégré** (CloudWatch)

---

## ⚠️ LIMITATIONS LAMBDA

✗ **Durée max 15 minutes**
✗ **Cold start latency** (~100ms)
✗ **Payload max 6 MB** (synchrone)
✗ **Éphémère** (pas de persistent storage)
✗ **VPC cold start lent** (~1-2 sec)
✗ **Log output max 4 KB** (standard)

---

## 🖼️ DASHBOARD AWS

### Accéder à Lambda

```
1. AWS Console > Lambda
2. "Create function"
3. Remplir nom/runtime
4. Créer et tester
```

---

## 🔐 IAM Role (permissions)

Lambda a besoin d'une IAM Role pour :

```yaml
CloudWatch Logs:
  - logs:CreateLogGroup
  - logs:CreateLogStream
  - logs:PutLogEvents

(Optionnel selon triggers)
S3:
  - s3:GetObject
  - s3:PutObject

DynamoDB:
  - dynamodb:GetItem
  - dynamodb:PutItem
```

AWS crée une role basique par défaut ✓

---

[⬅️ Retour](./README.md) | [➡️ Créer Fonction Lambda](./02-Create-Lambda.md)

