# Job 8 : ECS + Fargate - Applications conteneurisées 🐳

> Déployer des conteneurs Docker sans gérer l'infrastructure

---

## 🎯 Objectif

Déployer une application conteneurisée sans gérer l'infrastructure sous-jacente en utilisant ECS avec Fargate.

---

## 📦 Ressources AWS Utilisées

| Service | Rôle |
|---------|------|
| ECR | Registry Docker privé |
| ECS | Orchestration de conteneurs |
| Fargate | Exécution serverless |
| VPC | Réseau |
| Security Groups | Pare-feu |

---

## 💰 Coûts

| Service | Free Tier |
|---------|-----------|
| ECR | 500 MB gratuit |
| Fargate | 750h vCPU + 750h GB mémoire/mois |

✅ **Gratuit pour ce projet** (dans les limites du free tier)

---

## 🏗️ Architecture

```
ECR (Image Docker) → ECS Cluster → Fargate Task → Public IP
```

---

# Étape 1 : Créer l'application Node.js

## Fichiers du projet

### app.js

```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Page d'accueil
app.get('/', (req, res) => {
    res.json({
        message: 'Bienvenue sur mon app ECS Fargate!',
        version: '1.0.0',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development'
    });
});

// Health check
app.get('/health', (req, res) => {
    res.json({ status: 'healthy', uptime: process.uptime() });
});

// Info système
app.get('/info', (req, res) => {
    res.json({
        hostname: require('os').hostname(),
        platform: process.platform,
        nodeVersion: process.version,
        memoryUsage: process.memoryUsage()
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
});
```

### package.json

```json
{
  "name": "ecs-fargate-app",
  "version": "1.0.0",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

### Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --production

COPY . .

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["node", "app.js"]
```

### .dockerignore

```
node_modules
npm-debug.log
.git
.gitignore
README.md
```

---

# Étape 2 : Build et test local

## 💻 Local (Docker installé)

```bash
# Créer le dossier du projet
mkdir ecs-app && cd ecs-app

# Créer les fichiers (app.js, package.json, Dockerfile, .dockerignore)

# Build l'image
docker build -t mon-app-ecs .

# Tester localement
docker run -d -p 3000:3000 --name test-ecs mon-app-ecs

# Vérifier
curl http://localhost:3000
curl http://localhost:3000/health

# Nettoyer
docker stop test-ecs && docker rm test-ecs
```

---

# Étape 3 : Créer un repository ECR

## 🖥️ Dashboard

```
1. ECR → Repositories → Create repository

2. Repository name : mon-app-ecs

3. Image tag mutability : Mutable

4. Scan on push : Enabled (optionnel)

5. Create repository ✓

6. Notez l'URI :
   123456789012.dkr.ecr.eu-west-3.amazonaws.com/mon-app-ecs
```

## 💻 CLI

```bash
# Créer le repository
aws ecr create-repository \
  --repository-name mon-app-ecs \
  --image-scanning-configuration scanOnPush=true \
  --region eu-west-3

# Récupérer l'URI
ECR_URI=$(aws ecr describe-repositories \
  --repository-names mon-app-ecs \
  --query 'repositories[0].repositoryUri' \
  --output text \
  --region eu-west-3)

echo "ECR URI: $ECR_URI"
```

---

# Étape 4 : Pousser l'image vers ECR

## 💻 CLI

```bash
# 1. Login à ECR
aws ecr get-login-password --region eu-west-3 | \
  docker login --username AWS --password-stdin \
  123456789012.dkr.ecr.eu-west-3.amazonaws.com

# 2. Tag l'image
docker tag mon-app-ecs:latest \
  123456789012.dkr.ecr.eu-west-3.amazonaws.com/mon-app-ecs:latest

# 3. Push l'image
docker push 123456789012.dkr.ecr.eu-west-3.amazonaws.com/mon-app-ecs:latest

# Vérifier
aws ecr list-images \
  --repository-name mon-app-ecs \
  --region eu-west-3
```

---

# Étape 5 : Créer un cluster ECS

## 🖥️ Dashboard

```
1. ECS → Clusters → Create cluster

2. Cluster name : mon-cluster

3. Infrastructure : AWS Fargate (serverless) ✓

4. Create ✓
```

## 💻 CLI

```bash
aws ecs create-cluster \
  --cluster-name mon-cluster \
  --capacity-providers FARGATE \
  --region eu-west-3
```

---

# Étape 6 : Créer une Task Definition

## 🖥️ Dashboard

```
1. ECS → Task definitions → Create new task definition

2. Task definition family : mon-app-task

3. Launch type : AWS Fargate

4. Operating system : Linux/X86_64

5. Task size :
   - CPU : .25 vCPU
   - Memory : .5 GB

6. Task role : None (ou créer si besoin)

7. Container - 1 :
   - Name : mon-app-container
   - Image URI : 123456789012.dkr.ecr.eu-west-3.amazonaws.com/mon-app-ecs:latest
   - Port mappings : 3000 TCP

8. Create ✓
```

## 💻 CLI

```bash
# Créer la task definition
aws ecs register-task-definition \
  --family mon-app-task \
  --network-mode awsvpc \
  --requires-compatibilities FARGATE \
  --cpu 256 \
  --memory 512 \
  --execution-role-arn arn:aws:iam::ACCOUNT_ID:role/ecsTaskExecutionRole \
  --container-definitions '[
    {
      "name": "mon-app-container",
      "image": "123456789012.dkr.ecr.eu-west-3.amazonaws.com/mon-app-ecs:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "essential": true,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/mon-app",
          "awslogs-region": "eu-west-3",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]' \
  --region eu-west-3
```

---

# Étape 7 : Créer le Security Group

## 🖥️ Dashboard

```
1. EC2 → Security Groups → Create security group

2. Security group name : ecs-app-sg

3. Description : Security group for ECS app

4. VPC : default

5. Inbound rules :
   - Type : Custom TCP
   - Port : 3000
   - Source : 0.0.0.0/0

6. Create security group ✓
```

## 💻 CLI

```bash
# Récupérer le VPC ID
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query 'Vpcs[0].VpcId' \
  --output text \
  --region eu-west-3)

# Créer le Security Group
SG_ID=$(aws ec2 create-security-group \
  --group-name ecs-app-sg \
  --description "Security group for ECS app" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text \
  --region eu-west-3)

# Ajouter la règle inbound
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 3000 \
  --cidr 0.0.0.0/0 \
  --region eu-west-3
```

---

# Étape 8 : Créer un Service ECS

## 🖥️ Dashboard

```
1. ECS → Clusters → mon-cluster

2. Services → Create

3. Compute options : Launch type → FARGATE

4. Task definition :
   - Family : mon-app-task
   - Revision : LATEST

5. Service name : mon-app-service

6. Desired tasks : 1

7. Networking :
   - VPC : default
   - Subnets : Sélectionnez au moins 2
   - Security group : ecs-app-sg
   - Public IP : ENABLED ✓

8. Create ✓
```

## 💻 CLI

```bash
# Récupérer les subnets
SUBNETS=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$VPC_ID" \
  --query 'Subnets[*].SubnetId' \
  --output text \
  --region eu-west-3 | tr '\t' ',')

# Créer le service
aws ecs create-service \
  --cluster mon-cluster \
  --service-name mon-app-service \
  --task-definition mon-app-task \
  --desired-count 1 \
  --launch-type FARGATE \
  --network-configuration '{
    "awsvpcConfiguration": {
      "subnets": ["subnet-xxx", "subnet-yyy"],
      "securityGroups": ["'$SG_ID'"],
      "assignPublicIp": "ENABLED"
    }
  }' \
  --region eu-west-3
```

---

# Étape 9 : Tester l'application

## 🖥️ Dashboard

```
1. ECS → Clusters → mon-cluster → Tasks

2. Cliquez sur la task en cours

3. Onglet "Networking"

4. Copiez la "Public IP"

5. Ouvrez dans le navigateur :
   http://<PUBLIC_IP>:3000
   http://<PUBLIC_IP>:3000/health
   http://<PUBLIC_IP>:3000/info
```

## 💻 CLI

```bash
# Récupérer l'IP de la task
TASK_ARN=$(aws ecs list-tasks \
  --cluster mon-cluster \
  --service-name mon-app-service \
  --query 'taskArns[0]' \
  --output text \
  --region eu-west-3)

# Récupérer les détails de la task
aws ecs describe-tasks \
  --cluster mon-cluster \
  --tasks $TASK_ARN \
  --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' \
  --output text \
  --region eu-west-3

# Tester
curl http://<PUBLIC_IP>:3000
```

### Réponse attendue

```json
{
  "message": "Bienvenue sur mon app ECS Fargate!",
  "version": "1.0.0",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "environment": "development"
}
```

---

# Étape 10 : Voir les logs CloudWatch

## 🖥️ Dashboard

```
1. CloudWatch → Log groups

2. Cliquez sur : /ecs/mon-app

3. Sélectionnez le log stream

4. Vous verrez :
   - Server running on port 3000
   - Requêtes HTTP
```

## 💻 CLI

```bash
aws logs tail /ecs/mon-app --follow --region eu-west-3
```

---

# 🔧 Troubleshooting

## ❌ Task ne démarre pas (STOPPED)

```
1. ECS → Tasks → Cliquez sur la task STOPPED
2. Onglet "Logs" ou "Stopped reason"
3. Causes courantes :
   - Image non trouvée → Vérifiez l'URI ECR
   - Permissions → Vérifiez le rôle ecsTaskExecutionRole
   - Port déjà utilisé → Changez le port
```

## ❌ Cannot pull image

```
1. Vérifiez que l'image existe dans ECR
2. Vérifiez les permissions du rôle d'exécution
3. Vérifiez que le VPC a accès à Internet (NAT Gateway ou public subnet)
```

## ❌ Pas d'IP publique

```
1. Vérifiez "assignPublicIp": "ENABLED"
2. Vérifiez que le subnet est public
3. Vérifiez l'Internet Gateway du VPC
```

## ❌ Connection refused

```
1. Vérifiez le Security Group (port 3000 ouvert)
2. Vérifiez que l'app écoute sur 0.0.0.0 (pas 127.0.0.1)
3. Vérifiez les logs CloudWatch
```

---

# 🧹 Nettoyage

```bash
# 1. Supprimer le service (mettre desired count à 0 d'abord)
aws ecs update-service \
  --cluster mon-cluster \
  --service mon-app-service \
  --desired-count 0 \
  --region eu-west-3

aws ecs delete-service \
  --cluster mon-cluster \
  --service mon-app-service \
  --force \
  --region eu-west-3

# 2. Supprimer le cluster
aws ecs delete-cluster \
  --cluster mon-cluster \
  --region eu-west-3

# 3. Supprimer la task definition (désinscrire toutes les versions)
aws ecs deregister-task-definition \
  --task-definition mon-app-task:1 \
  --region eu-west-3

# 4. Supprimer le repository ECR
aws ecr delete-repository \
  --repository-name mon-app-ecs \
  --force \
  --region eu-west-3

# 5. Supprimer le Security Group
aws ec2 delete-security-group \
  --group-id $SG_ID \
  --region eu-west-3

# 6. Supprimer les logs CloudWatch
aws logs delete-log-group \
  --log-group-name /ecs/mon-app \
  --region eu-west-3
```

---

## ✅ Checklist Finale

- [ ] Application Node.js créée (app.js, package.json)
- [ ] Dockerfile créé
- [ ] Image Docker buildée et testée localement
- [ ] Repository ECR créé
- [ ] Image poussée vers ECR
- [ ] Cluster ECS créé
- [ ] Task Definition créée
- [ ] Security Group créé (port 3000)
- [ ] Service ECS déployé
- [ ] Application accessible via IP publique
- [ ] Logs visibles dans CloudWatch

---

[⬅️ Retour : Job7](./Job7_Athena_QuickSight.md) | [➡️ Suite : Job9_StepFunctions.md](./Job9_StepFunctions.md)
