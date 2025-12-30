# CLI Commands - ECS / Fargate / ECR 💻

Toutes les commandes AWS CLI et Docker pour ECS, Fargate et ECR.

---

## 📋 TABLE DES MATIÈRES

1. [Configuration AWS CLI](#-configuration-aws-cli)
2. [ECR - Registry](#-ecr---registry)
3. [ECS - Clusters](#-ecs---clusters)
4. [ECS - Task Definitions](#-ecs---task-definitions)
5. [ECS - Services](#-ecs---services)
6. [ECS - Tasks](#-ecs---tasks)
7. [Docker](#-docker)
8. [IAM](#-iam)
9. [CloudWatch Logs](#-cloudwatch-logs)
10. [Networking](#-networking)

---

## ⚙️ CONFIGURATION AWS CLI

### Vérifier configuration

```bash
# Vérifier identité
aws sts get-caller-identity

# Vérifier région par défaut
aws configure get region

# Lister profils configurés
aws configure list-profiles
```

### Variables d'environnement utiles

```bash
# Définir la région
export AWS_DEFAULT_REGION=eu-west-3

# Définir le profil
export AWS_PROFILE=mon-profil

# Account ID (utile pour ECR)
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

---

## 📦 ECR - REGISTRY

### Authentification

```bash
# Login Docker vers ECR
aws ecr get-login-password --region eu-west-3 | \
  docker login --username AWS --password-stdin \
  ${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-3.amazonaws.com
```

### Repositories

```bash
# Lister tous les repositories
aws ecr describe-repositories

# Créer un repository
aws ecr create-repository \
  --repository-name ma-app \
  --image-scanning-configuration scanOnPush=true \
  --image-tag-mutability MUTABLE

# Créer avec tag immutability (prod)
aws ecr create-repository \
  --repository-name ma-app-prod \
  --image-scanning-configuration scanOnPush=true \
  --image-tag-mutability IMMUTABLE

# Obtenir URI d'un repository
aws ecr describe-repositories \
  --repository-names ma-app \
  --query 'repositories[0].repositoryUri' \
  --output text

# Supprimer un repository (ATTENTION!)
aws ecr delete-repository \
  --repository-name ma-app \
  --force
```

### Images

```bash
# Lister images dans un repository
aws ecr list-images --repository-name ma-app

# Détails d'une image
aws ecr describe-images \
  --repository-name ma-app \
  --image-ids imageTag=latest

# Supprimer une image
aws ecr batch-delete-image \
  --repository-name ma-app \
  --image-ids imageTag=v1.0.0

# Supprimer images non-taguées
aws ecr list-images \
  --repository-name ma-app \
  --filter tagStatus=UNTAGGED \
  --query 'imageIds[*]' \
  --output json | \
  xargs -I {} aws ecr batch-delete-image \
    --repository-name ma-app \
    --image-ids '{}'
```

### Scan de vulnérabilités

```bash
# Lancer un scan manuel
aws ecr start-image-scan \
  --repository-name ma-app \
  --image-id imageTag=latest

# Voir résultats du scan
aws ecr describe-image-scan-findings \
  --repository-name ma-app \
  --image-id imageTag=latest

# Résumé des vulnérabilités
aws ecr describe-image-scan-findings \
  --repository-name ma-app \
  --image-id imageTag=latest \
  --query 'imageScanFindings.findingSeverityCounts'
```

### Lifecycle Policies

```bash
# Voir la policy actuelle
aws ecr get-lifecycle-policy \
  --repository-name ma-app

# Appliquer une lifecycle policy
aws ecr put-lifecycle-policy \
  --repository-name ma-app \
  --lifecycle-policy-text file://lifecycle-policy.json

# Supprimer la lifecycle policy
aws ecr delete-lifecycle-policy \
  --repository-name ma-app

# Prévisualiser ce que la policy va supprimer
aws ecr get-lifecycle-policy-preview \
  --repository-name ma-app \
  --lifecycle-policy-text file://lifecycle-policy.json
```

---

## 🏗️ ECS - CLUSTERS

### Gestion clusters

```bash
# Lister tous les clusters
aws ecs list-clusters

# Créer un cluster (Fargate)
aws ecs create-cluster \
  --cluster-name my-cluster \
  --capacity-providers FARGATE FARGATE_SPOT \
  --default-capacity-provider-strategy \
    capacityProvider=FARGATE,weight=1

# Créer cluster simple
aws ecs create-cluster --cluster-name my-cluster

# Détails d'un cluster
aws ecs describe-clusters \
  --clusters my-cluster

# Détails avec statistiques
aws ecs describe-clusters \
  --clusters my-cluster \
  --include STATISTICS

# Supprimer un cluster (doit être vide)
aws ecs delete-cluster --cluster my-cluster
```

### Capacity Providers

```bash
# Lister capacity providers d'un cluster
aws ecs describe-clusters \
  --clusters my-cluster \
  --include ATTACHMENTS

# Mettre à jour capacity providers
aws ecs put-cluster-capacity-providers \
  --cluster my-cluster \
  --capacity-providers FARGATE FARGATE_SPOT \
  --default-capacity-provider-strategy \
    capacityProvider=FARGATE,weight=1,base=1 \
    capacityProvider=FARGATE_SPOT,weight=4
```

---

## 📝 ECS - TASK DEFINITIONS

### Gestion Task Definitions

```bash
# Lister toutes les task definitions
aws ecs list-task-definitions

# Lister les familles de task definitions
aws ecs list-task-definition-families

# Lister versions d'une famille
aws ecs list-task-definitions \
  --family-prefix ma-app

# Détails d'une task definition
aws ecs describe-task-definition \
  --task-definition ma-app:1

# Dernière version d'une famille
aws ecs describe-task-definition \
  --task-definition ma-app

# Enregistrer une nouvelle task definition
aws ecs register-task-definition \
  --cli-input-json file://task-definition.json

# Désenregistrer une task definition
aws ecs deregister-task-definition \
  --task-definition ma-app:1
```

### Créer Task Definition (inline)

```bash
# Task Definition basique Fargate
aws ecs register-task-definition \
  --family ma-app \
  --network-mode awsvpc \
  --requires-compatibilities FARGATE \
  --cpu 256 \
  --memory 512 \
  --execution-role-arn arn:aws:iam::${AWS_ACCOUNT_ID}:role/ecsTaskExecutionRole \
  --container-definitions '[
    {
      "name": "ma-app",
      "image": "'${AWS_ACCOUNT_ID}'.dkr.ecr.eu-west-3.amazonaws.com/ma-app:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/ma-app",
          "awslogs-region": "eu-west-3",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]'
```

---

## 🔄 ECS - SERVICES

### Gestion Services

```bash
# Lister services d'un cluster
aws ecs list-services --cluster my-cluster

# Créer un service (Fargate)
aws ecs create-service \
  --cluster my-cluster \
  --service-name ma-app-service \
  --task-definition ma-app:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={
    subnets=[subnet-xxx,subnet-yyy],
    securityGroups=[sg-xxx],
    assignPublicIp=ENABLED
  }"

# Créer service avec Load Balancer
aws ecs create-service \
  --cluster my-cluster \
  --service-name ma-app-service \
  --task-definition ma-app:1 \
  --desired-count 2 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={
    subnets=[subnet-xxx,subnet-yyy],
    securityGroups=[sg-xxx],
    assignPublicIp=DISABLED
  }" \
  --load-balancers "targetGroupArn=arn:aws:elasticloadbalancing:...,containerName=ma-app,containerPort=3000"

# Détails d'un service
aws ecs describe-services \
  --cluster my-cluster \
  --services ma-app-service

# Mettre à jour un service (nouvelle version)
aws ecs update-service \
  --cluster my-cluster \
  --service ma-app-service \
  --task-definition ma-app:2

# Scaler un service
aws ecs update-service \
  --cluster my-cluster \
  --service ma-app-service \
  --desired-count 5

# Forcer nouveau déploiement (même task definition)
aws ecs update-service \
  --cluster my-cluster \
  --service ma-app-service \
  --force-new-deployment

# Supprimer un service (mettre desired à 0 d'abord)
aws ecs update-service \
  --cluster my-cluster \
  --service ma-app-service \
  --desired-count 0

aws ecs delete-service \
  --cluster my-cluster \
  --service ma-app-service
```

### Déploiements

```bash
# Voir les déploiements en cours
aws ecs describe-services \
  --cluster my-cluster \
  --services ma-app-service \
  --query 'services[0].deployments'

# Événements récents du service
aws ecs describe-services \
  --cluster my-cluster \
  --services ma-app-service \
  --query 'services[0].events[:10]'
```

---

## 🏃 ECS - TASKS

### Gestion Tasks

```bash
# Lister tasks d'un cluster
aws ecs list-tasks --cluster my-cluster

# Lister tasks d'un service
aws ecs list-tasks \
  --cluster my-cluster \
  --service-name ma-app-service

# Détails des tasks
aws ecs describe-tasks \
  --cluster my-cluster \
  --tasks task-id-xxx

# Lancer une task standalone
aws ecs run-task \
  --cluster my-cluster \
  --task-definition ma-app:1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={
    subnets=[subnet-xxx],
    securityGroups=[sg-xxx],
    assignPublicIp=ENABLED
  }"

# Arrêter une task
aws ecs stop-task \
  --cluster my-cluster \
  --task task-id-xxx \
  --reason "Arrêt manuel"
```

### Exécuter commande dans une task

```bash
# Activer ECS Exec sur le service
aws ecs update-service \
  --cluster my-cluster \
  --service ma-app-service \
  --enable-execute-command

# Exécuter commande (nécessite Session Manager plugin)
aws ecs execute-command \
  --cluster my-cluster \
  --task task-id-xxx \
  --container ma-app \
  --interactive \
  --command "/bin/sh"
```

---

## 🐳 DOCKER

### Build et Tag

```bash
# Build
docker build -t ma-app .
docker build -t ma-app:v1.0.0 .
docker build --no-cache -t ma-app .

# Tag pour ECR
docker tag ma-app:latest ${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-3.amazonaws.com/ma-app:latest
docker tag ma-app:latest ${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-3.amazonaws.com/ma-app:v1.0.0
```

### Push vers ECR

```bash
# Login (valide 12h)
aws ecr get-login-password --region eu-west-3 | \
  docker login --username AWS --password-stdin \
  ${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-3.amazonaws.com

# Push
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-3.amazonaws.com/ma-app:latest
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-3.amazonaws.com/ma-app:v1.0.0

# Push tous les tags
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.eu-west-3.amazonaws.com/ma-app --all-tags
```

### Test local

```bash
# Run
docker run -p 3000:3000 ma-app
docker run -d -p 3000:3000 --name ma-app-container ma-app
docker run -e NODE_ENV=production -p 3000:3000 ma-app

# Gestion
docker ps
docker logs ma-app-container
docker logs -f ma-app-container
docker stop ma-app-container
docker rm ma-app-container

# Debug
docker exec -it ma-app-container /bin/sh
```

### Nettoyage

```bash
# Supprimer containers arrêtés
docker container prune

# Supprimer images non utilisées
docker image prune

# Supprimer tout (attention!)
docker system prune -a
```

---

## 🔐 IAM

### Task Execution Role

```bash
# Créer le rôle
aws iam create-role \
  --role-name ecsTaskExecutionRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }'

# Attacher la policy AWS gérée
aws iam attach-role-policy \
  --role-name ecsTaskExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

### Vérifier rôles

```bash
# Lister les rôles ECS
aws iam list-roles \
  --query 'Roles[?contains(RoleName, `ecs`)]'

# Voir policies attachées
aws iam list-attached-role-policies \
  --role-name ecsTaskExecutionRole
```

---

## 📊 CLOUDWATCH LOGS

### Groupes de logs

```bash
# Créer un log group
aws logs create-log-group \
  --log-group-name /ecs/ma-app

# Définir la rétention (jours)
aws logs put-retention-policy \
  --log-group-name /ecs/ma-app \
  --retention-in-days 30

# Lister log groups ECS
aws logs describe-log-groups \
  --log-group-name-prefix /ecs/

# Supprimer log group
aws logs delete-log-group \
  --log-group-name /ecs/ma-app
```

### Logs streams

```bash
# Lister log streams
aws logs describe-log-streams \
  --log-group-name /ecs/ma-app \
  --order-by LastEventTime \
  --descending

# Voir les derniers logs
aws logs get-log-events \
  --log-group-name /ecs/ma-app \
  --log-stream-name ecs/ma-app/task-id-xxx

# Tail des logs (follow)
aws logs tail /ecs/ma-app --follow

# Logs des dernières 5 minutes
aws logs tail /ecs/ma-app --since 5m
```

### Requêtes Logs Insights

```bash
# Requête basique
aws logs start-query \
  --log-group-name /ecs/ma-app \
  --start-time $(date -d '1 hour ago' +%s) \
  --end-time $(date +%s) \
  --query-string 'fields @timestamp, @message | sort @timestamp desc | limit 20'

# Récupérer résultats
aws logs get-query-results \
  --query-id "query-id-xxx"
```

---

## 🌐 NETWORKING

### VPC et Subnets

```bash
# Lister VPCs
aws ec2 describe-vpcs \
  --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0]]'

# Lister subnets
aws ec2 describe-subnets \
  --query 'Subnets[*].[SubnetId,VpcId,AvailabilityZone,Tags[?Key==`Name`].Value|[0]]'

# Subnets publics (avec route vers IGW)
aws ec2 describe-subnets \
  --filters "Name=map-public-ip-on-launch,Values=true" \
  --query 'Subnets[*].SubnetId'
```

### Security Groups

```bash
# Lister security groups
aws ec2 describe-security-groups \
  --query 'SecurityGroups[*].[GroupId,GroupName]'

# Créer security group pour ECS
aws ec2 create-security-group \
  --group-name ecs-sg \
  --description "Security group for ECS tasks" \
  --vpc-id vpc-xxx

# Autoriser port 3000 depuis partout
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxx \
  --protocol tcp \
  --port 3000 \
  --cidr 0.0.0.0/0

# Autoriser depuis un ALB security group
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxx \
  --protocol tcp \
  --port 3000 \
  --source-group sg-alb-xxx
```

---

## 📋 SCRIPTS UTILES

### Déploiement complet

```bash
#!/bin/bash
set -e

# Variables
APP_NAME="ma-app"
AWS_REGION="eu-west-3"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}"
VERSION=$(git rev-parse --short HEAD)

# Build
docker build -t ${APP_NAME}:${VERSION} .

# Tag
docker tag ${APP_NAME}:${VERSION} ${ECR_URI}:${VERSION}
docker tag ${APP_NAME}:${VERSION} ${ECR_URI}:latest

# Login ECR
aws ecr get-login-password --region ${AWS_REGION} | \
  docker login --username AWS --password-stdin \
  ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# Push
docker push ${ECR_URI}:${VERSION}
docker push ${ECR_URI}:latest

# Update ECS Service
aws ecs update-service \
  --cluster my-cluster \
  --service ${APP_NAME}-service \
  --force-new-deployment

echo "Deployed ${APP_NAME}:${VERSION}"
```

### Voir l'état du déploiement

```bash
#!/bin/bash

CLUSTER="my-cluster"
SERVICE="ma-app-service"

echo "=== Deployments ==="
aws ecs describe-services \
  --cluster ${CLUSTER} \
  --services ${SERVICE} \
  --query 'services[0].deployments[*].{Status:status,Running:runningCount,Desired:desiredCount,TaskDef:taskDefinition}' \
  --output table

echo ""
echo "=== Recent Events ==="
aws ecs describe-services \
  --cluster ${CLUSTER} \
  --services ${SERVICE} \
  --query 'services[0].events[:5].message' \
  --output text
```

---

## 🔗 LIENS

- **ECS Concepts** → [01-ECS-Concepts-Complets.md](./01-ECS-Concepts-Complets.md)
- **Fargate Concepts** → [02-Fargate-Concepts-Complets.md](./02-Fargate-Concepts-Complets.md)
- **ECR Concepts** → [03-ECR-Concepts-Complets.md](./03-ECR-Concepts-Complets.md)
- **Troubleshooting** → [Troubleshooting.md](./Troubleshooting.md)

---

[⬅️ Retour au README](./README.md)
