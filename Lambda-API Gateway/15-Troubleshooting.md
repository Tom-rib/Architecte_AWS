# Troubleshooting 🐛

Guide complet pour déboguer problèmes courants avec Lambda + API Gateway.

---

## 🎯 FLUX DE DÉBOGAGE

```
Erreur ?
  ↓
Voir CloudWatch Logs
  ↓
Message d'erreur
  ↓
Corriger + Deploy
  ↓
Tester
```

---

## ❌ ERREUR "502 Bad Gateway"

**Symptôme :** API retourne HTTP 502

**Causes possibles :**
1. Lambda crash
2. Lambda timeout
3. Integration cassée
4. Permission manquante

### Solution

```
1. Aller CloudWatch > Logs
2. Chercher /aws/lambda/my-api-function
3. Voir message d'erreur exact
4. Corriger code
5. Deploy
6. Tester API
```

### Exemple log erreur

```
{
  "errorMessage": "name 'json' is not defined",
  "errorType": "NameError",
  "stackTrace": [
    "  File \"/var/task/lambda_function.py\", line 10, in lambda_handler"
  ]
}
```

**Solution :** Ajouter `import json` au début

---

## ❌ ERREUR "403 Forbidden"

**Symptôme :** API retourne HTTP 403

**Cause :** API Gateway pas autorisé d'appeler Lambda

### Solution

```bash
# Ajouter permission
aws lambda add-permission \
  --function-name my-api-function \
  --statement-id apigateway-access \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:eu-west-3:ACCOUNT:API_ID/*" \
  --region eu-west-3
```

**OU (en console) :**

```
1. Lambda > my-api-function > Configuration
2. Permissions > Resource-based policy statements
3. Vérifier API Gateway a permission
4. Si pas, ajouter manuellement
```

---

## ❌ ERREUR "504 Gateway Timeout"

**Symptôme :** API répond après 29 secondes = timeout

**Causes possibles :**
1. Fonction prend > 29 sec
2. Code infini
3. DB connection lent
4. API call lent

### Solution

```
1. Augmenter mémoire Lambda
   Lambda > Configuration > Memory Size
   Mémoire = CPU => plus rapide
   
2. Augmenter timeout Lambda
   Configuration > General configuration > Timeout
   Max 15 minutes (900 sec)
   
3. Optimiser code
   - Enlever boucles inutiles
   - Ajouter caching
   - Paralléliser requêtes
```

### Diagnostiquer durée

```bash
# Voir logs avec duration
aws logs tail /aws/lambda/my-api-function --follow

# Chercher : "Duration: XXX ms"
```

---

## ❌ ERREUR CORS ("has been blocked")

**Symptôme :** Frontend JavaScript → API error

```javascript
// Erreur dans console
Access to fetch at 'https://api.example.com/hello' 
from origin 'http://localhost:3000' 
has been blocked by CORS policy
```

**Cause :** CORS pas activé sur API

### Solution rapide (5 min)

```
1. API Gateway > Resources > /hello
2. Actions > Enable CORS
3. "Enable CORS and replace..."
4. [Confirm]
5. Actions > Deploy API
6. Tester
```

### Solution manuelle

```
1. Créer method OPTIONS sur /hello
2. Integration Response > Add headers:
   - Access-Control-Allow-Origin: *
   - Access-Control-Allow-Methods: GET,POST,OPTIONS
   - Access-Control-Allow-Headers: Content-Type
3. Deploy
```

---

## ❌ ERREUR "Lambda timeout" (3 sec)

**Symptôme :** Function stops after 3 seconds

**Cause :** Timeout default est 3 secondes

### Solution

```
1. Lambda > Configuration > General configuration
2. Timeout: 30 (ou plus)
3. Save
4. Deploy
5. Tester
```

---

## ❌ ERREUR "Cold start lent"

**Symptôme :** Première requête → ~500ms, autres → ~50ms

**Cause :** Normal pour Lambda (init environnement)

### Solutions

**Option 1 : Accepter** (recommandé)
```
Cold start = 100-500ms (normal)
```

**Option 2 : Keep Lambda warm**
```bash
# CloudWatch Events déclenche Lambda toutes les 5 min

aws events put-rule \
  --name keep-lambda-warm \
  --schedule-expression "rate(5 minutes)"

aws events put-targets \
  --rule keep-lambda-warm \
  --targets "Id"="1","Arn"="arn:aws:lambda:..."
```

**Option 3 : Augmenter mémoire**
```
Plus de mémoire = plus de CPU = cold start plus rapide
```

---

## ❌ ERREUR "Logs vides"

**Symptôme :** Pas de logs CloudWatch

**Causes :**
1. Log group pas créé
2. IAM permissions manquantes
3. Fonction pas exécutée

### Solution

```
1. Vérifier IAM role
   Lambda > Configuration > Execution role
   
2. Vérifier policy contient AWSLambdaBasicExecutionRole
   IAM > Roles > lambda-role
   
3. Créer log group manual
   aws logs create-log-group \
     --log-group-name /aws/lambda/my-api-function
   
4. Rééxecuter fonction
   Lambda > Test
   
5. Voir logs
   CloudWatch > Logs
```

---

## ❌ ERREUR "API returns empty body"

**Symptôme :** Response OK (200) mais body vide

**Cause :** Lambda retourne pas "body" field

### Solution

Code doit retourner :

```python
return {
    'statusCode': 200,
    'headers': {'Content-Type': 'application/json'},
    'body': json.dumps({'message': 'Hello'})  # ← PAS VIDE
}
```

---

## ❌ ERREUR "Module not found"

**Symptôme :** 
```
"errorMessage": "No module named 'requests'"
```

**Cause :** Package pas dans ZIP

### Solution

```bash
# 1. Créer requirements.txt
cat > requirements.txt << EOF
requests==2.28.0
boto3==1.26.0
EOF

# 2. Installer dependencies
pip install -r requirements.txt -t .

# 3. Zipper avec dependencies
zip -r lambda.zip . -x "*.git*"

# 4. Update Lambda
aws lambda update-function-code \
  --function-name my-api-function \
  --zip-file fileb://lambda.zip
```

---

## ❌ ERREUR "Insufficient Concurrency"

**Symptôme :** 
```
"errorType": "TooManyRequestsException"
```

**Cause :** Lambda concurrency limit dépassé (default 1000)

### Solution

```bash
# Augmenter limit
aws lambda put-function-concurrency \
  --function-name my-api-function \
  --reserved-concurrent-executions 5000 \
  --region eu-west-3
```

---

## 🧪 TROUBLESHOOTING CHECKLIST

```
□ ❌ API retourne 502 ?
  → CloudWatch Logs > voir erreur exacte
  → Corriger code
  → Deploy

□ ❌ API retourne 403 ?
  → Lambda > Configuration > Permissions
  → Ajouter apigateway:InvokeFunction

□ ❌ API retourne 504 (timeout) ?
  → Lambda > Configuration > Timeout (augmenter)
  → Ou Memory (augmenter pour CPU)

□ ❌ CORS error ?
  → API > /hello > Actions > Enable CORS
  → Deploy

□ ❌ Logs vides ?
  → Lambda > Configuration > Execution role
  → Vérifier AWSLambdaBasicExecutionRole
  → Test Lambda

□ ❌ Fonction lente ?
  → Augmenter Memory (= CPU)
  → Optimiser code
  → Voir CloudWatch Duration

□ ❌ Cold start lent ?
  → Normal (100-500ms) pour première invocation
  → Augmenter memory ou keep-warm

□ ❌ Module not found ?
  → pip install -r requirements.txt
  → Inclure dans ZIP
  → Update code
```

---

## 🎯 OUTILS DE DEBUG

### 1. CloudWatch Logs (vérifier erreurs)

```bash
aws logs tail /aws/lambda/my-api-function --follow
```

### 2. Lambda Test (tester code)

```
Lambda > Test > Voir response et logs
```

### 3. API Gateway Test (tester intégration)

```
API > /hello > GET > ⚡ Test
```

### 4. cURL (tester URL publique)

```bash
curl https://your-api.../prod/hello?name=Tom -v
```

### 5. CloudWatch Metrics

```
Lambda > Monitor > Voir Errors, Duration, Memory
```

---

## 📊 DEBUG WORKFLOW

```
1. Erreur utilisateur ?
   → Tester API dans navigateur
   
2. Voir CloudWatch Logs
   → CloudWatch > Logs > /aws/lambda/...
   
3. Identifier erreur
   → errorMessage, line number, etc
   
4. Corriger code
   → Modifier lambda_function.py
   
5. Deploy
   → Lambda > Deploy
   
6. Tester
   → CloudWatch > Test ou API call
   
7. Répéter jusqu'OK
```

---

## 📌 NOTES

- **Logs gratuit** : 5 GB first month
- **Metrics gratuit** : Histor 15 mois
- **CloudWatch Logs Insights** : Payant mais très puissant
- **X-Ray** : Tracing détaillé (payant)

---

[⬅️ Retour](./README.md)

