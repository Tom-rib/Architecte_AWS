# Surveiller les Logs Lambda avec CloudWatch 📊

Guide complet pour voir les logs, déboguer, et monitorer votre API Lambda.

---

## 🎯 OBJECTIF

Voir les logs Lambda en temps réel pour déboguer problèmes et comprendre exécutions.

---

## 🔴 ÉTAPE 1 : ACCÉDER AUX LOGS

### Depuis Lambda Console

```
1. Aller à Lambda > my-api-function
2. Cliquer onglet "Monitor"
3. Cliquer "View CloudWatch Logs"
```

**OU directement :**

```
1. Aller à CloudWatch > Logs > Log groups
2. Chercher /aws/lambda/my-api-function
3. Cliquer dessus
```

---

## 🟠 ÉTAPE 2 : COMPRENDRE LES LOGS

Vous verrez des log streams comme :

```
Log group: /aws/lambda/my-api-function

📂 2024/12/26
   └─ Log streams:
      ├─ 2024/12/26/[$LATEST]abc123def456
      ├─ 2024/12/26/[$LATEST]xyz789uvw012
      └─ 2024/12/26/[$LATEST]pqr345stu678
```

Chaque stream = 1 invocation Lambda

### Cliquer sur un stream

```
Timestamp          | Log message
─────────────────────────────────────────
2024-12-26T12:00:00Z | START RequestId: abc-123...
2024-12-26T12:00:00Z | Requête reçue: GET /hello
2024-12-26T12:00:00Z | END RequestId: abc-123
2024-12-26T12:00:00Z | REPORT Duration: 23 ms, Memory Used: 45 MB
```

---

## 🟡 ÉTAPE 3 : INTERPRÉTER LES LOGS

### Lignes importantes

| Log | Signification |
|-----|--------------|
| `START RequestId: xxx` | Début exécution |
| `Requête reçue: GET /hello` | Votre console.log() |
| `END RequestId: xxx` | Fin exécution |
| `REPORT Duration: 23 ms` | Temps d'exécution |
| `Memory Used: 45 MB` | RAM utilisée |

### Exemple complet

```
START RequestId: 550e8400-e29b-41d4-a716-446655440000 Version: $LATEST

2024-12-26T12:00:00.123Z    550e8400-e29b-41d4-a716-446655440000    INFO    Requête reçue: GET /hello
2024-12-26T12:00:00.145Z    550e8400-e29b-41d4-a716-446655440000    INFO    Response: {"message": "Hello World"}

END RequestId: 550e8400-e29b-41d4-a716-446655440000

REPORT RequestId: 550e8400-e29b-41d4-a716-446655440000
Duration: 23.45 ms
Billed Duration: 24 ms
Memory Size: 128 MB
Max Memory Used: 45 MB
Init Duration: 15.67 ms
```

**Analyse :**
- ✅ Exécution = 23 ms (rapide)
- ✅ Mémoire utilisée = 45 MB (peu)
- ✅ Pas d'erreur

---

## 🟢 ÉTAPE 4 : DÉBOGUER LES ERREURS

### Exemple : Erreur de syntaxe

```
START RequestId: 550e8400-e29b-41d4-a716-446655440000 Version: $LATEST

{
  "errorMessage": "name 'logger' is not defined",
  "errorType": "NameError",
  "requestId": "550e8400-e29b-41d4-a716-446655440000",
  "stackTrace": [
    "  File \"/var/task/lambda_function.py\", line 15, in lambda_handler",
    "    logger.info(f\"Requête: {method} {path}\")"
  ]
}

END RequestId: 550e8400-e29b-41d4-a716-446655440000
```

**Analyse :**
- ❌ Erreur = `NameError: name 'logger' is not defined`
- ❌ Ligne 15 du code
- **Solution :** Ajouter `import logging` et `logger = logging.getLogger()`

---

## 🟣 ÉTAPE 5 : CHERCHER DANS LES LOGS

### Recherche simple

En haut à droite, chercher par mot-clé :

```
Chercher: "error"
├─ Montre tous les logs contenant "error"
```

### Exemples de recherches utiles

```
Chercher: "ERROR"        → Logs d'erreur
Chercher: "Exception"    → Stack traces
Chercher: "Duration"     → Performance logs
Chercher: "Memory"       → Utilisation mémoire
Chercher: "Request"      → Détails requête
```

---

## 📊 METRICS (Dashboard)

### Retour à Lambda Console

```
Lambda > my-api-function > Monitor
```

Voir graphiques automatiques :

```
┌─────────────────────────────────────┐
│ Invocations (dernières 24h)         │
│ Nombre d'appels à la fonction       │
│                                     │
│ █                                   │
│ █ █     █ █                         │
│ █ █ █   █ █ █                       │
│ ─────────────────────────────────── │
│ 0   6h  12h  18h  24h              │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Errors                              │
│ Nombre d'erreurs                    │
│                                     │
│     (normalement vide)              │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Duration (Average)                  │
│ Temps moyen d'exécution             │
│                                     │
│ 50ms                                │
│                                     │
│ 40ms  █                             │
│ 30ms  █ █                           │
│ ─────────────────────────────────── │
│ 0   6h  12h  18h  24h              │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Memory Used (Average)               │
│ Mémoire utilisée en moyenne         │
│                                     │
│ 60MB                                │
│     █                               │
│ 50MB█ █                             │
│ ─────────────────────────────────── │
│ 0   6h  12h  18h  24h              │
└─────────────────────────────────────┘
```

---

## 🎯 LOGS PYTHON (Bonnes Pratiques)

### Code correctement loggé

```python
import logging
import json

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    # Log début
    logger.info(f"Requête reçue: {event}")
    
    try:
        # Your code
        method = event['requestContext']['http']['method']
        logger.info(f"Method: {method}")
        
        result = {"message": "OK"}
        logger.info(f"Réponse: {json.dumps(result)}")
        
        return {
            'statusCode': 200,
            'body': json.dumps(result)
        }
        
    except Exception as e:
        # Log erreur
        logger.error(f"Erreur: {str(e)}", exc_info=True)
        
        return {
            'statusCode': 500,
            'body': json.dumps({"error": str(e)})
        }
```

**Logs produits :**

```
Requête reçue: {...}
Method: GET
Réponse: {"message": "OK"}
```

---

## 📈 ANALYSE DE PERFORMANCE

### Cas 1 : API RAPIDE ✅

```
Duration: 23 ms
Memory Used: 45 MB / 128 MB
```

**Interprétation :**
- ✅ Temps OK (< 100ms)
- ✅ Mémoire OK (< 50%)
- ✅ Scaling pas de problème

### Cas 2 : API LENTE ⚠️

```
Duration: 5000 ms (5 sec)
Memory Used: 120 MB / 128 MB
```

**Actions :**
- Augmenter mémoire → Lambda (Configuration)
- Vérifier opérations lentes
- Utiliser cache/CDN

### Cas 3 : API ERREUR ❌

```
ERROR: database connection timeout
Memory Used: 100 MB / 128 MB
```

**Actions :**
- Vérifier sécurity group RDS
- Vérifier credentials DB
- Augmenter timeout Lambda (Configuration → General configuration)

---

## 🔔 CRÉER ALARMES CLOUDWATCH (Bonus)

Pour être notifié si erreurs :

```
1. CloudWatch > Alarms > Create alarm
2. Select metric > Lambda > Errors
3. Condition: >= 1 error
4. Actions: Send SNS notification
5. Create alarm
```

Vous recevrez email si erreur !

---

## 🗑️ NETTOYER LES LOGS

Les logs accumulent rapidement. Pour delete :

```
1. CloudWatch > Logs > Log groups
2. Cliquer /aws/lambda/my-api-function
3. Actions ▼ > Delete log group
```

**OU configurer expiration :**

```
1. Retention > Set to 1 week
   (logs supprimés auto après 1 semaine)
```

---

## 📌 NOTES

- **Logs gratuit** : 5 GB first month (free tier)
- **Retention défaut** : Illimitée (stocké dans S3)
- **Search** : Gratuit (CloudWatch Logs Insights = payant)
- **Export** : CloudWatch > Logs > Log group > Export to S3

---

## 🎯 NEXT STEPS

1. Exécuter fonction plusieurs fois
2. Vérifier les logs
3. Observer la performance
4. Augmenter mémoire si lent
5. Ajouter logs pour déboguer

---

[⬅️ Retour](./README.md) | [➡️ Métriques](./10-Metrics.md)

