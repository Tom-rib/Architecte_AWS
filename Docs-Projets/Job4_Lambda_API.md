# Job 4 : Lambda + API Gateway 🔌

> Créer une API RESTful sans serveur (Serverless)

---

## 🎯 Objectif

Créer une API RESTful sans serveur qui répond à des requêtes HTTP en utilisant Lambda et API Gateway, avec journalisation dans CloudWatch.

---

## 📦 Ressources AWS Utilisées

| Service | Rôle |
|---------|------|
| Lambda | Fonction serverless |
| API Gateway | Point d'entrée HTTP |
| CloudWatch Logs | Journalisation |
| IAM | Permissions |

---

## 💰 Coûts

| Service | Free Tier |
|---------|-----------|
| Lambda | 1M requêtes/mois gratuites |
| API Gateway | 1M appels/mois gratuits |
| CloudWatch | 5 GB logs gratuits |

✅ **Entièrement gratuit pour ce projet**

---

## 🏗️ Architecture

```
Client → API Gateway → Lambda → CloudWatch Logs
                ↓
           Response JSON
```

---

# Étape 1 : Créer la fonction Lambda

## 🖥️ Dashboard

```
1. Lambda → Functions → Create function

2. Author from scratch

3. Function name : hello-api

4. Runtime : Python 3.11

5. Architecture : x86_64

6. Permissions :
   - ☑ Create a new role with basic Lambda permissions

7. Create function ✓
```

## 💻 CLI

```bash
# Créer le rôle IAM pour Lambda
aws iam create-role \
  --role-name lambda-basic-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attacher la policy de base
aws iam attach-role-policy \
  --role-name lambda-basic-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# Attendre que le rôle soit propagé
sleep 10

# Créer la fonction (avec code inline pour le test)
aws lambda create-function \
  --function-name hello-api \
  --runtime python3.11 \
  --role arn:aws:iam::ACCOUNT_ID:role/lambda-basic-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip \
  --region eu-west-3
```

---

# Étape 2 : Écrire le code Lambda

## 🖥️ Dashboard

```
1. Lambda → Functions → hello-api

2. Onglet "Code"

3. Remplacez le code par :
```

### Code Python (lambda_function.py)

```python
import json
import logging
from datetime import datetime

# Configuration du logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Handler principal de la fonction Lambda.
    Traite les requêtes HTTP via API Gateway.
    """
    try:
        # Log de la requête entrante
        logger.info(f"Event reçu: {json.dumps(event)}")
        
        # Récupérer les informations de la requête
        http_method = event.get('httpMethod', 'UNKNOWN')
        path = event.get('path', '/')
        query_params = event.get('queryStringParameters') or {}
        
        # Récupérer le paramètre 'name' (optionnel)
        name = query_params.get('name', 'World')
        
        # Log des détails
        logger.info(f"Méthode: {http_method}, Path: {path}, Name: {name}")
        
        # Construire la réponse
        response_body = {
            "message": f"Hello, {name}!",
            "timestamp": datetime.utcnow().isoformat(),
            "method": http_method,
            "path": path,
            "query_params": query_params
        }
        
        # Retourner la réponse (format API Gateway)
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(response_body, indent=2)
        }
        
    except Exception as e:
        logger.error(f"Erreur: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': str(e)})
        }
```

```
4. Cliquez "Deploy" ✓
```

## 💻 CLI

```bash
# Créer le fichier Python
cat > lambda_function.py << 'EOF'
import json
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        logger.info(f"Event reçu: {json.dumps(event)}")
        
        http_method = event.get('httpMethod', 'UNKNOWN')
        path = event.get('path', '/')
        query_params = event.get('queryStringParameters') or {}
        name = query_params.get('name', 'World')
        
        logger.info(f"Méthode: {http_method}, Path: {path}, Name: {name}")
        
        response_body = {
            "message": f"Hello, {name}!",
            "timestamp": datetime.utcnow().isoformat(),
            "method": http_method,
            "path": path,
            "query_params": query_params
        }
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps(response_body, indent=2)
        }
        
    except Exception as e:
        logger.error(f"Erreur: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps({'error': str(e)})
        }
EOF

# Zipper le code
zip function.zip lambda_function.py

# Mettre à jour la fonction
aws lambda update-function-code \
  --function-name hello-api \
  --zip-file fileb://function.zip \
  --region eu-west-3
```

---

# Étape 3 : Tester la fonction Lambda

## 🖥️ Dashboard

```
1. Lambda → Functions → hello-api

2. Onglet "Test"

3. Create new test event :
   - Event name : test-api-gateway
   - Template : API Gateway AWS Proxy
   
4. Modifier le JSON :
```

```json
{
  "httpMethod": "GET",
  "path": "/hello",
  "queryStringParameters": {
    "name": "Tom"
  }
}
```

```
5. Save

6. Test ✓

7. Vérifiez le résultat :
   - Status: 200
   - Body: {"message": "Hello, Tom!", ...}
```

## 💻 CLI

```bash
# Invoquer la fonction
aws lambda invoke \
  --function-name hello-api \
  --payload '{"httpMethod":"GET","path":"/hello","queryStringParameters":{"name":"Tom"}}' \
  --cli-binary-format raw-in-base64-out \
  response.json \
  --region eu-west-3

# Voir la réponse
cat response.json | jq
```

---

# Étape 4 : Créer l'API Gateway

## 🖥️ Dashboard

```
1. API Gateway → APIs → Create API

2. REST API → Build

3. Create new API :
   - API name : hello-api
   - API endpoint type : Regional

4. Create API ✓
```

## 💻 CLI

```bash
# Créer l'API REST
API_ID=$(aws apigateway create-rest-api \
  --name hello-api \
  --endpoint-configuration types=REGIONAL \
  --query 'id' \
  --output text \
  --region eu-west-3)

echo "API ID: $API_ID"

# Récupérer l'ID de la ressource racine
ROOT_ID=$(aws apigateway get-resources \
  --rest-api-id $API_ID \
  --query 'items[0].id' \
  --output text \
  --region eu-west-3)
```

---

# Étape 5 : Créer la ressource /hello

## 🖥️ Dashboard

```
1. API Gateway → hello-api

2. Resources → / (racine)

3. Actions → Create Resource

4. Resource Name : hello
   Resource Path : /hello

5. Create Resource ✓
```

## 💻 CLI

```bash
# Créer la ressource /hello
RESOURCE_ID=$(aws apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_ID \
  --path-part hello \
  --query 'id' \
  --output text \
  --region eu-west-3)
```

---

# Étape 6 : Créer la méthode GET

## 🖥️ Dashboard

```
1. API Gateway → hello-api → /hello

2. Actions → Create Method

3. Sélectionnez : GET

4. ✓ Cliquez sur la coche

5. Integration type : Lambda Function

6. ☑ Use Lambda Proxy integration

7. Lambda Function : hello-api

8. Save ✓

9. OK (autoriser API Gateway à invoquer Lambda)
```

## 💻 CLI

```bash
# Créer la méthode GET
aws apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method GET \
  --authorization-type NONE \
  --region eu-west-3

# Récupérer l'ARN de la fonction Lambda
LAMBDA_ARN=$(aws lambda get-function \
  --function-name hello-api \
  --query 'Configuration.FunctionArn' \
  --output text \
  --region eu-west-3)

# Configurer l'intégration Lambda Proxy
aws apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method GET \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri "arn:aws:apigateway:eu-west-3:lambda:path/2015-03-31/functions/$LAMBDA_ARN/invocations" \
  --region eu-west-3

# Autoriser API Gateway à invoquer Lambda
aws lambda add-permission \
  --function-name hello-api \
  --statement-id apigateway-invoke \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:eu-west-3:ACCOUNT_ID:$API_ID/*/GET/hello" \
  --region eu-west-3
```

---

# Étape 7 : Déployer l'API

## 🖥️ Dashboard

```
1. API Gateway → hello-api

2. Actions → Deploy API

3. Deployment stage : [New Stage]

4. Stage name : prod

5. Deploy ✓

6. Copiez l'URL d'invocation :
   https://xxxxxxxxxx.execute-api.eu-west-3.amazonaws.com/prod
```

## 💻 CLI

```bash
# Créer le déploiement
aws apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name prod \
  --region eu-west-3

# L'URL sera :
echo "https://$API_ID.execute-api.eu-west-3.amazonaws.com/prod/hello"
```

---

# Étape 8 : Tester l'API

## 🖥️ Navigateur

```
https://xxxxxxxxxx.execute-api.eu-west-3.amazonaws.com/prod/hello

https://xxxxxxxxxx.execute-api.eu-west-3.amazonaws.com/prod/hello?name=Tom
```

## 💻 CLI / PowerShell

```bash
# Linux/Mac
curl "https://xxxxxxxxxx.execute-api.eu-west-3.amazonaws.com/prod/hello"

curl "https://xxxxxxxxxx.execute-api.eu-west-3.amazonaws.com/prod/hello?name=Tom"
```

```powershell
# Windows PowerShell
Invoke-WebRequest -Uri "https://xxxxxxxxxx.execute-api.eu-west-3.amazonaws.com/prod/hello" -Method GET

Invoke-RestMethod -Uri "https://xxxxxxxxxx.execute-api.eu-west-3.amazonaws.com/prod/hello?name=Tom" -Method GET
```

### Réponse attendue

```json
{
  "message": "Hello, Tom!",
  "timestamp": "2024-01-15T10:30:00.000000",
  "method": "GET",
  "path": "/hello",
  "query_params": {
    "name": "Tom"
  }
}
```

---

# Étape 9 : Voir les logs CloudWatch

## 🖥️ Dashboard

```
1. CloudWatch → Log groups

2. Cliquez sur : /aws/lambda/hello-api

3. Sélectionnez un log stream récent

4. Vous verrez :
   - START RequestId: xxx
   - Event reçu: {...}
   - Méthode: GET, Path: /hello
   - END RequestId: xxx
   - REPORT RequestId: xxx Duration: xx ms
```

## 💻 CLI

```bash
# Voir les logs en temps réel
aws logs tail /aws/lambda/hello-api --follow --region eu-west-3

# Voir les derniers logs
aws logs get-log-events \
  --log-group-name /aws/lambda/hello-api \
  --log-stream-name '2024/01/15/[$LATEST]xxxxx' \
  --limit 50 \
  --region eu-west-3
```

---

# 🔧 Troubleshooting

## ❌ 502 Bad Gateway

```
- Vérifiez le format de retour de Lambda (statusCode, body, headers)
- Vérifiez les logs CloudWatch pour voir l'erreur
- Assurez-vous que "Lambda Proxy integration" est activé
```

## ❌ 403 Forbidden

```
- Vérifiez que l'API est déployée
- Vérifiez les permissions Lambda (add-permission)
- Vérifiez l'URL (stage name correct ?)
```

## ❌ 500 Internal Server Error

```
- Vérifiez les logs CloudWatch
- Testez la fonction Lambda directement
- Vérifiez le code Python (syntaxe, imports)
```

---

# 🧹 Nettoyage

```bash
# 1. Supprimer l'API Gateway
aws apigateway delete-rest-api \
  --rest-api-id $API_ID \
  --region eu-west-3

# 2. Supprimer la fonction Lambda
aws lambda delete-function \
  --function-name hello-api \
  --region eu-west-3

# 3. Supprimer le rôle IAM
aws iam detach-role-policy \
  --role-name lambda-basic-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws iam delete-role \
  --role-name lambda-basic-role

# 4. Supprimer les logs (optionnel)
aws logs delete-log-group \
  --log-group-name /aws/lambda/hello-api \
  --region eu-west-3
```

---

## ✅ Checklist Finale

- [ ] Fonction Lambda créée
- [ ] Code déployé et testé
- [ ] API Gateway créée
- [ ] Ressource /hello créée
- [ ] Méthode GET configurée (Lambda Proxy)
- [ ] API déployée (stage: prod)
- [ ] Test API OK (curl ou navigateur)
- [ ] Logs visibles dans CloudWatch

---

[⬅️ Retour : Job3](./Job3_RDS.md) | [➡️ Suite : Job5_CloudWatch_SNS.md](./Job5_CloudWatch_SNS.md)
