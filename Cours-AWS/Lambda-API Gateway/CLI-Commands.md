# CLI Commands - Référence Complète 💻

Toutes les commandes AWS CLI pour Lambda et API Gateway.

---

## 📌 Configuration AWS CLI

```bash
# Configurer AWS
aws configure

# Entrer:
# AWS Access Key ID: YOUR_KEY
# AWS Secret Access Key: YOUR_SECRET
# Default region: eu-west-3
# Default output format: json
```

---

## 🟢 LAMBDA - FONCTIONS

### Lister toutes les fonctions

```bash
aws lambda list-functions --region eu-west-3
```

### Voir détails fonction

```bash
aws lambda get-function \
  --function-name my-api-function \
  --region eu-west-3
```

### Récupérer ARN fonction

```bash
aws lambda get-function \
  --function-name my-api-function \
  --region eu-west-3 \
  --query 'Configuration.FunctionArn' \
  --output text
```

### Créer fonction (via ZIP)

```bash
# 1. Créer dossier
mkdir my-lambda
cd my-lambda

# 2. Créer code Python
cat > lambda_function.py << 'EOF'
def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda!'
    }
EOF

# 3. Créer ZIP
zip lambda_function.zip lambda_function.py

# 4. Créer fonction
aws lambda create-function \
  --function-name my-api-function \
  --runtime python3.11 \
  --role arn:aws:iam::YOUR_ACCOUNT_ID:role/lambda-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://lambda_function.zip \
  --region eu-west-3
```

### Mettre à jour code

```bash
# Modifier lambda_function.py
nano lambda_function.py

# Re-zip
zip lambda_function.zip lambda_function.py

# Update fonction
aws lambda update-function-code \
  --function-name my-api-function \
  --zip-file fileb://lambda_function.zip \
  --region eu-west-3
```

### Mettre à jour configuration

```bash
aws lambda update-function-configuration \
  --function-name my-api-function \
  --timeout 30 \
  --memory-size 256 \
  --region eu-west-3
```

### Tester fonction (invoke)

```bash
# Payload JSON
cat > test-event.json << 'EOF'
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
EOF

# Invoquer
aws lambda invoke \
  --function-name my-api-function \
  --payload file://test-event.json \
  response.json \
  --region eu-west-3

# Voir response
cat response.json
```

### Supprimer fonction

```bash
aws lambda delete-function \
  --function-name my-api-function \
  --region eu-west-3
```

---

## 🟠 LAMBDA - LOGS

### Voir logs (dernière invocation)

```bash
aws logs tail /aws/lambda/my-api-function \
  --follow \
  --region eu-west-3
```

### Voir logs (depuis 1 heure)

```bash
aws logs tail /aws/lambda/my-api-function \
  --since 1h \
  --region eu-west-3
```

### Exporter logs vers fichier

```bash
aws logs tail /aws/lambda/my-api-function \
  --region eu-west-3 > logs.txt
```

### Supprimer log group

```bash
aws logs delete-log-group \
  --log-group-name /aws/lambda/my-api-function \
  --region eu-west-3
```

---

## 🟡 API GATEWAY - CRÉER API

### Créer API REST

```bash
aws apigateway create-rest-api \
  --name my-api \
  --description "My REST API" \
  --region eu-west-3
```

### Lister APIs

```bash
aws apigateway get-rest-apis --region eu-west-3
```

### Récupérer ID API

```bash
aws apigateway get-rest-apis \
  --region eu-west-3 \
  --query 'items[0].id' \
  --output text
```

---

## 🔵 API GATEWAY - RESSOURCES

### Lister ressources

```bash
API_ID=abc123  # Remplacer par votre API ID

aws apigateway get-resources \
  --rest-api-id $API_ID \
  --region eu-west-3
```

### Créer ressource

```bash
API_ID=abc123
ROOT_ID=xyz789  # ID de "/" (voir get-resources)

aws apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_ID \
  --path-part hello \
  --region eu-west-3
```

### Récupérer ID ressource /hello

```bash
API_ID=abc123

RESOURCE_ID=$(aws apigateway get-resources \
  --rest-api-id $API_ID \
  --region eu-west-3 \
  --query 'items[?path==`/hello`].id' \
  --output text)

echo $RESOURCE_ID
```

---

## 🟣 API GATEWAY - MÉTHODES

### Créer méthode GET

```bash
API_ID=abc123
RESOURCE_ID=pqr789

aws apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method GET \
  --authorization-type NONE \
  --region eu-west-3
```

### Intégrer Lambda à méthode

```bash
API_ID=abc123
RESOURCE_ID=pqr789
LAMBDA_ARN=arn:aws:lambda:eu-west-3:ACCOUNT:function:my-api-function

aws apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method GET \
  --type AWS \
  --integration-http-method POST \
  --uri "arn:aws:apigateway:eu-west-3:lambda:path/2015-03-31/functions/${LAMBDA_ARN}/invocations" \
  --region eu-west-3
```

### Créer integration response

```bash
API_ID=abc123
RESOURCE_ID=pqr789

aws apigateway put-integration-response \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method GET \
  --status-code 200 \
  --region eu-west-3
```

### Créer method response

```bash
API_ID=abc123
RESOURCE_ID=pqr789

aws apigateway put-method-response \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method GET \
  --status-code 200 \
  --region eu-west-3
```

---

## 🟢 API GATEWAY - DÉPLOIEMENT

### Créer deployment

```bash
API_ID=abc123

DEPLOYMENT=$(aws apigateway create-deployment \
  --rest-api-id $API_ID \
  --region eu-west-3 \
  --output text)

echo $DEPLOYMENT
```

### Créer stage prod

```bash
API_ID=abc123
DEPLOYMENT_ID=xyz123

aws apigateway create-stage \
  --rest-api-id $API_ID \
  --stage-name prod \
  --deployment-id $DEPLOYMENT_ID \
  --description "Production environment" \
  --region eu-west-3
```

### Récupérer Invoke URL

```bash
API_ID=abc123

aws apigateway get-stage \
  --rest-api-id $API_ID \
  --stage-name prod \
  --region eu-west-3 \
  --query 'invokeUrl' \
  --output text
```

---

## 🔴 API GATEWAY - PERMISSIONS

### Donner permission à API Gateway

```bash
FUNCTION_NAME=my-api-function
API_ID=abc123

aws lambda add-permission \
  --function-name $FUNCTION_NAME \
  --statement-id apigateway-access \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn "arn:aws:execute-api:eu-west-3:YOUR_ACCOUNT_ID:${API_ID}/*/*" \
  --region eu-west-3
```

---

## 📊 CLOUDWATCH LOGS

### Créer log group

```bash
aws logs create-log-group \
  --log-group-name /aws/lambda/my-api-function \
  --region eu-west-3
```

### Lister log groups

```bash
aws logs describe-log-groups --region eu-west-3
```

### Voir logs temps réel

```bash
aws logs tail /aws/lambda/my-api-function \
  --follow \
  --region eu-west-3
```

### Créer alarm (erreurs)

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name lambda-errors \
  --alarm-description "Alert on Lambda errors" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --region eu-west-3
```

---

## 🎯 SCRIPTS COMPLETS

### Script 1 : Créer tout (Lambda + API)

```bash
#!/bin/bash

# Variables
FUNCTION_NAME="my-api-function"
API_NAME="my-api"
REGION="eu-west-3"

# 1. Créer fonction Lambda
aws lambda create-function \
  --function-name $FUNCTION_NAME \
  --runtime python3.11 \
  --role arn:aws:iam::YOUR_ACCOUNT_ID:role/lambda-role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://lambda_function.zip \
  --region $REGION

echo "Lambda créée ✓"

# 2. Créer API
API_ID=$(aws apigateway create-rest-api \
  --name $API_NAME \
  --region $REGION \
  --query 'id' \
  --output text)

echo "API créée: $API_ID"

# 3. Déployer
DEPLOYMENT=$(aws apigateway create-deployment \
  --rest-api-id $API_ID \
  --region $REGION \
  --query 'id' \
  --output text)

echo "Déploiement: $DEPLOYMENT"

# 4. Récupérer Invoke URL
INVOKE_URL=$(aws apigateway get-stage \
  --rest-api-id $API_ID \
  --stage-name prod \
  --region $REGION \
  --query 'invokeUrl' \
  --output text)

echo "URL API: $INVOKE_URL/hello"
```

### Script 2 : Mettre à jour et redéployer

```bash
#!/bin/bash

FUNCTION_NAME="my-api-function"
REGION="eu-west-3"

# Zipper code
zip lambda_function.zip lambda_function.py

# Update Lambda
aws lambda update-function-code \
  --function-name $FUNCTION_NAME \
  --zip-file fileb://lambda_function.zip \
  --region $REGION

echo "Lambda mise à jour ✓"
```

---

## 📌 NOTES

- **Account ID** : Voir AWS Console > Account > Account ID
- **Region** : eu-west-3 pour ce projet
- **Permissions** : IAM Role créée auto par console
- **IAM Policy** : `AWSLambdaBasicExecutionRole` = logs CloudWatch

---

[⬅️ Retour](./README.md)

