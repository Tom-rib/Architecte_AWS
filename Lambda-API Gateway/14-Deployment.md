# Deployment - Infrastructure as Code 🚀

Infrastructure as Code (IaC) = définir Lambda + API Gateway en code YAML/JSON au lieu de clics.

---

## 🎯 CONCEPT

Au lieu de :
1. Console AWS > Créer Lambda
2. Console AWS > Créer API Gateway
3. Console AWS > Intégrer
4. Console AWS > Déployer

Faire :
1. Écrire template YAML
2. Déployer avec CLI
3. Reproduire en 1 commande

---

## 📋 OPTIONS

| Tool | Language | Courbe apprentissage | Popularité |
|------|----------|----------------------|------------|
| **SAM** | YAML | Facile | ⭐⭐⭐⭐ |
| **CloudFormation** | JSON/YAML | Moyen | ⭐⭐⭐ |
| **CDK** | Python/TypeScript | Difficile | ⭐⭐⭐⭐⭐ |
| **Terraform** | HCL | Moyen | ⭐⭐⭐⭐ |

**Recommandé : SAM (plus facile pour Lambda)**

---

## 🚀 SAM - STARTER TEMPLATE

Créer fichier `template.yaml` :

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Description: My REST API with Lambda and API Gateway

Globals:
  Function:
    Timeout: 30
    MemorySize: 256
    Runtime: python3.11
    Environment:
      Variables:
        LOG_LEVEL: INFO

Parameters:
  StageName:
    Type: String
    Default: prod
    Description: API stage name

Resources:
  # Lambda Function
  MyApiFunction:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: my-api-function
      CodeUri: src/
      Handler: app.lambda_handler
      Events:
        HelloApi:
          Type: Api
          Properties:
            RestApiId: !Ref MyRestApi
            Path: /hello
            Method: GET

  # API Gateway
  MyRestApi:
    Type: AWS::Serverless::Api
    Properties:
      StageName: !Ref StageName
      Cors:
        AllowMethods: "'GET,POST,PUT,DELETE,OPTIONS'"
        AllowHeaders: "'Content-Type,Authorization'"
        AllowOrigin: "'*'"

Outputs:
  ApiUrl:
    Description: API Gateway endpoint URL
    Value: !Sub "https://${MyRestApi}.execute-api.${AWS::Region}.amazonaws.com/${StageName}/"
  
  FunctionArn:
    Description: Lambda function ARN
    Value: !GetAtt MyApiFunction.Arn
```

---

## 📂 STRUCTURE PROJET

```
my-lambda-project/
├── template.yaml          ← Template SAM
├── samconfig.toml         ← Config SAM
├── src/
│   └── app.py            ← Code Lambda
├── tests/
│   └── test_app.py       ← Unit tests
└── events/
    └── event.json        ← Test event
```

---

## 💻 DÉPLOYER AVEC SAM

### 1. Installer SAM CLI

```bash
# macOS
brew install aws-sam-cli

# Windows
choco install aws-sam-cli

# Linux
pip install aws-sam-cli
```

### 2. Créer fichier app.py

```python
def lambda_handler(event, context):
    """Lambda handler for API Gateway"""
    
    path = event['requestContext']['http']['path']
    method = event['requestContext']['http']['method']
    
    return {
        'statusCode': 200,
        'headers': {'Content-Type': 'application/json'},
        'body': f'Hello from {method} {path}'
    }
```

### 3. Build

```bash
sam build
```

**Output :**
```
Building resources
Running PythonPipBuilder:python3.11
Building layer 'HelloWorldLayerWithPython'
Built artifacts  to the '.aws-sam/build' directory
Built template   to '.aws-sam/build/template.yaml'
```

### 4. Deploy

```bash
sam deploy --guided

# Répondre aux questions :
# Stack Name: my-api
# Region: eu-west-3
# Confirm changes before deploy: Y
# Allow SAM CLI IAM role creation: Y
# Save parameters to samconfig.toml: Y
```

**Output :**
```
CloudFormation events from creation/update operations (...)

Successfully created/updated stack - my-api in eu-west-3
SAM CLI now collects telemetry...

Stack ARN : arn:aws:cloudformation:eu-west-3:ACCOUNT:stack/my-api/...

Outputs:
Key    ApiUrl
Value  https://abc123.execute-api.eu-west-3.amazonaws.com/prod/

Key    FunctionArn
Value  arn:aws:lambda:eu-west-3:ACCOUNT:function:my-api-function
```

---

## 🔄 METTRE À JOUR

### Modifier code

```bash
# 1. Modifier src/app.py
nano src/app.py

# 2. Build
sam build

# 3. Deploy
sam deploy
```

---

## 🧪 TESTER LOCALEMENT

### Lancer Lambda local

```bash
sam local start-api
```

**Output :**
```
Mounting MyApiFunction at http://127.0.0.1:3000/hello
```

### Tester

```bash
curl http://localhost:3000/hello?name=Tom
```

---

## 🗑️ SUPPRIMER STACK

```bash
aws cloudformation delete-stack \
  --stack-name my-api \
  --region eu-west-3
```

---

## 📊 SAM vs CONSOLE

| Aspect | Console | SAM |
|--------|---------|-----|
| **Setup** | 30 min | 10 min |
| **Reproduction** | ❌ Difficile | ✅ Facile |
| **Versioning** | ❌ Pas géré | ✅ Git-friendly |
| **Testing** | ❌ Manual | ✅ Automatisé |
| **Scaling** | ❌ Multi-region difficile | ✅ Facile |

---

## 🎯 COMMANDES SAM

```bash
sam init                # Créer projet
sam build              # Build
sam local start-api    # Tester local
sam deploy             # Déployer
sam delete             # Supprimer
sam logs -n Function   # Voir logs
sam validate           # Vérifier template
```

---

## 📌 NOTES

- **Free tier** : Template gratuit
- **Best practice** : Utiliser IaC pour production
- **Git** : Template YAML dans Git = Infrastructure versionné
- **CI/CD** : Déployer automatiquement avec GitHub Actions

---

[⬅️ Retour](./README.md) | [➡️ Troubleshooting](./15-Troubleshooting.md)

