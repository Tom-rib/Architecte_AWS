# Troubleshooting - ECS / Fargate / ECR 🔧

Guide de résolution des problèmes courants.

---

## 📋 TABLE DES MATIÈRES

1. [ECR - Push/Pull](#-ecr---pushpull)
2. [Task Definition](#-task-definition)
3. [Tasks - Ne démarre pas](#-tasks---ne-démarre-pas)
4. [Tasks - Crash/Restart](#-tasks---crashrestart)
5. [Services - Unhealthy](#-services---unhealthy)
6. [Networking](#-networking)
7. [Load Balancer](#-load-balancer)
8. [Logs](#-logs)
9. [Performance](#-performance)
10. [Coûts](#-coûts)

---

## 📦 ECR - PUSH/PULL

### ❌ "no basic auth credentials"

**Cause :** Token Docker expiré ou pas de login

**Solution :**
```bash
# Re-login (token valide 12h)
aws ecr get-login-password --region eu-west-3 | \
  docker login --username AWS --password-stdin \
  123456789012.dkr.ecr.eu-west-3.amazonaws.com
```

---

### ❌ "denied: User is not authorized"

**Cause :** Permissions IAM insuffisantes

**Solution :**
```bash
# Vérifier votre identité
aws sts get-caller-identity

# Ajouter les permissions ECR
# Policy minimale pour push :
{
  "Effect": "Allow",
  "Action": [
    "ecr:GetAuthorizationToken",
    "ecr:BatchCheckLayerAvailability",
    "ecr:GetDownloadUrlForLayer",
    "ecr:BatchGetImage",
    "ecr:PutImage",
    "ecr:InitiateLayerUpload",
    "ecr:UploadLayerPart",
    "ecr:CompleteLayerUpload"
  ],
  "Resource": "*"
}
```

---

### ❌ "repository does not exist"

**Cause :** Le repository n'existe pas

**Solution :**
```bash
# Créer le repository
aws ecr create-repository \
  --repository-name ma-app \
  --region eu-west-3
```

---

### ❌ "tag already exists" (immutable)

**Cause :** Tag immutability activé, tag déjà utilisé

**Solution :**
```bash
# Option 1: Utiliser un nouveau tag
docker tag ma-app:latest ECR_URI:v1.0.1

# Option 2: Désactiver immutability (pas recommandé prod)
aws ecr put-image-tag-mutability \
  --repository-name ma-app \
  --image-tag-mutability MUTABLE
```

---

### ❌ Push très lent

**Causes possibles :**
- Image trop grosse
- Connexion lente
- Pas de VPC Endpoint

**Solutions :**
```bash
# Vérifier taille de l'image
docker images ma-app

# Utiliser images légères
FROM node:18-alpine  # au lieu de node:18

# Créer VPC Endpoint ECR (évite passage internet)
aws ec2 create-vpc-endpoint \
  --vpc-id vpc-xxx \
  --service-name com.amazonaws.eu-west-3.ecr.dkr \
  --vpc-endpoint-type Interface
```

---

## 📝 TASK DEFINITION

### ❌ "Invalid CPU or memory value"

**Cause :** Combinaison CPU/Memory invalide pour Fargate

**Solution :**
Utiliser des combinaisons valides :

| CPU | Memory valides |
|-----|----------------|
| 256 | 512, 1024, 2048 |
| 512 | 1024, 2048, 3072, 4096 |
| 1024 | 2048-8192 (par 1024) |
| 2048 | 4096-16384 (par 1024) |
| 4096 | 8192-30720 (par 1024) |

---

### ❌ "ExecutionRoleArn is required"

**Cause :** Rôle d'exécution manquant

**Solution :**
```bash
# Créer le rôle si inexistant
aws iam create-role \
  --role-name ecsTaskExecutionRole \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "ecs-tasks.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

aws iam attach-role-policy \
  --role-name ecsTaskExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

---

### ❌ "Network mode must be awsvpc"

**Cause :** Fargate requiert awsvpc

**Solution :**
```json
{
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"]
}
```

---

## 🏃 TASKS - NE DÉMARRE PAS

### ❌ Task reste en PENDING

**Causes possibles :**

| Cause | Diagnostic | Solution |
|-------|------------|----------|
| Pas d'IP disponible | Subnet plein | Utiliser subnet plus grand |
| Quota Fargate atteint | Service Quotas | Demander augmentation |
| Image introuvable | Events du service | Vérifier URI ECR |

**Debug :**
```bash
# Voir les events du service
aws ecs describe-services \
  --cluster my-cluster \
  --services ma-app-service \
  --query 'services[0].events[:10]'

# Vérifier les quotas Fargate
aws service-quotas get-service-quota \
  --service-code fargate \
  --quota-code L-3032A538
```

---

### ❌ "CannotPullContainerError"

**Causes et solutions :**

| Message | Cause | Solution |
|---------|-------|----------|
| "pull access denied" | Permissions ECR | Vérifier Task Execution Role |
| "repository not found" | URI incorrecte | Vérifier l'URI de l'image |
| "network timeout" | Pas d'accès internet | NAT Gateway ou IP publique |

**Vérifier Task Execution Role :**
```bash
aws iam list-attached-role-policies \
  --role-name ecsTaskExecutionRole

# Doit contenir AmazonECSTaskExecutionRolePolicy
```

**Pour private subnet :**
```bash
# Option 1: NAT Gateway (coûteux)
# Option 2: VPC Endpoints (recommandé)
aws ec2 create-vpc-endpoint \
  --vpc-id vpc-xxx \
  --service-name com.amazonaws.eu-west-3.ecr.dkr \
  --vpc-endpoint-type Interface

aws ec2 create-vpc-endpoint \
  --vpc-id vpc-xxx \
  --service-name com.amazonaws.eu-west-3.ecr.api \
  --vpc-endpoint-type Interface
```

---

### ❌ "ResourceInitializationError"

**Cause :** Problème lors de l'initialisation (ENI, secrets, etc.)

**Solutions :**
```bash
# Vérifier Security Group permet outbound
aws ec2 describe-security-groups \
  --group-ids sg-xxx \
  --query 'SecurityGroups[0].IpPermissionsEgress'

# Doit avoir outbound 0.0.0.0/0 pour ECR, CloudWatch, etc.

# Ajouter si manquant
aws ec2 authorize-security-group-egress \
  --group-id sg-xxx \
  --protocol -1 \
  --cidr 0.0.0.0/0
```

---

## 💥 TASKS - CRASH/RESTART

### ❌ Task en boucle de restart

**Diagnostic :**
```bash
# Voir les stopped tasks
aws ecs list-tasks \
  --cluster my-cluster \
  --desired-status STOPPED

# Voir pourquoi elle s'est arrêtée
aws ecs describe-tasks \
  --cluster my-cluster \
  --tasks task-id-xxx \
  --query 'tasks[0].{StopCode:stopCode,StopReason:stoppedReason,Container:containers[0].reason}'
```

---

### ❌ "Essential container exited"

**Cause :** Votre application a crashé

**Solutions :**
```bash
# 1. Voir les logs CloudWatch
aws logs tail /ecs/ma-app --since 10m

# 2. Vérifier le exit code
aws ecs describe-tasks \
  --cluster my-cluster \
  --tasks task-id-xxx \
  --query 'tasks[0].containers[0].exitCode'

# Exit codes communs :
# 0   = Normal exit
# 1   = Application error
# 137 = OOM killed (Out of Memory)
# 139 = Segmentation fault
# 143 = SIGTERM (graceful shutdown)
```

---

### ❌ Exit code 137 (OOM Killed)

**Cause :** Application utilise plus de RAM que allouée

**Solutions :**
```bash
# Option 1: Augmenter la mémoire dans Task Definition
"memory": "1024"  # au lieu de 512

# Option 2: Optimiser l'application
# - Réduire la consommation mémoire
# - Utiliser streaming au lieu de charger tout en mémoire
```

---

### ❌ HEALTHCHECK failed

**Cause :** Health check échoue

**Vérifications :**
```bash
# 1. Tester localement
docker run -p 3000:3000 ma-app
curl http://localhost:3000/health

# 2. Vérifier la config dans Task Definition
"healthCheck": {
  "command": ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"],
  "interval": 30,
  "timeout": 5,
  "retries": 3,
  "startPeriod": 60  # Augmenter si app lente à démarrer
}
```

---

## 🩺 SERVICES - UNHEALTHY

### ❌ Service stuck at 0 running tasks

**Debug :**
```bash
# Voir les events
aws ecs describe-services \
  --cluster my-cluster \
  --services ma-app-service \
  --query 'services[0].events[:10].message'
```

**Causes courantes :**

| Event message | Solution |
|---------------|----------|
| "unable to place a task" | Vérifier subnets, SG |
| "unable to pull image" | Vérifier ECR permissions |
| "task failed ELB health check" | Vérifier health check path |

---

### ❌ "service ma-app-service is unable to consistently start tasks"

**Cause :** Tasks crash en boucle

**Solution :**
```bash
# 1. Arrêter le service
aws ecs update-service \
  --cluster my-cluster \
  --service ma-app-service \
  --desired-count 0

# 2. Lancer une task standalone pour debug
aws ecs run-task \
  --cluster my-cluster \
  --task-definition ma-app:1 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=ENABLED}"

# 3. Voir les logs
aws logs tail /ecs/ma-app --follow
```

---

## 🌐 NETWORKING

### ❌ Task n'a pas accès à internet

**Pour public subnet :**
```json
{
  "networkConfiguration": {
    "awsvpcConfiguration": {
      "subnets": ["subnet-public-xxx"],
      "assignPublicIp": "ENABLED"
    }
  }
}
```

**Pour private subnet :**
- Besoin d'un NAT Gateway
- Ou VPC Endpoints pour ECR/CloudWatch/S3

---

### ❌ Task ne peut pas atteindre RDS/autre service

**Vérifications :**
```bash
# 1. Tasks et RDS dans le même VPC ?

# 2. Security Group RDS autorise le SG des tasks ?
aws ec2 authorize-security-group-ingress \
  --group-id sg-rds-xxx \
  --protocol tcp \
  --port 5432 \
  --source-group sg-ecs-xxx
```

---

### ❌ Connection refused entre services

**Solutions :**
```bash
# 1. Utiliser Service Discovery (Cloud Map)
# 2. Ou passer par ALB interne
# 3. Vérifier Security Groups bidirectionnels
```

---

## ⚖️ LOAD BALANCER

### ❌ Targets unhealthy

**Debug :**
```bash
# Voir état des targets
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:...

# Causes courantes :
# - Health check path incorrect
# - Port mismatch
# - Security Group bloque ALB → Task
```

**Vérifications :**
```bash
# 1. Health check path existe ?
curl http://task-ip:3000/health

# 2. Security Group task autorise ALB ?
aws ec2 authorize-security-group-ingress \
  --group-id sg-task-xxx \
  --protocol tcp \
  --port 3000 \
  --source-group sg-alb-xxx
```

---

### ❌ 502 Bad Gateway

**Causes et solutions :**

| Cause | Solution |
|-------|----------|
| Task pas prête | Augmenter deregistration delay |
| Task crash | Voir logs, exit code |
| Timeout | Augmenter idle timeout ALB |
| Mauvais port | Vérifier containerPort |

---

## 📊 LOGS

### ❌ Pas de logs dans CloudWatch

**Vérifications :**

```bash
# 1. Log group existe ?
aws logs describe-log-groups \
  --log-group-name-prefix /ecs/ma-app

# Créer si manquant
aws logs create-log-group --log-group-name /ecs/ma-app

# 2. Task Execution Role a les permissions logs ?
# Policy doit contenir :
{
  "Effect": "Allow",
  "Action": [
    "logs:CreateLogStream",
    "logs:PutLogEvents"
  ],
  "Resource": "*"
}

# 3. Task Definition a la config logs ?
"logConfiguration": {
  "logDriver": "awslogs",
  "options": {
    "awslogs-group": "/ecs/ma-app",
    "awslogs-region": "eu-west-3",
    "awslogs-stream-prefix": "ecs"
  }
}
```

---

### ❌ "ResourceNotFoundException" pour logs

**Cause :** Log group n'existe pas et création auto désactivée

**Solution :**
```bash
# Créer le log group manuellement
aws logs create-log-group --log-group-name /ecs/ma-app

# Ou activer auto-création dans Task Definition
"logConfiguration": {
  "logDriver": "awslogs",
  "options": {
    "awslogs-create-group": "true",
    ...
  }
}
```

---

## ⚡ PERFORMANCE

### ❌ Application lente

**Diagnostics :**
```bash
# Métriques CPU/Memory du service
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ClusterName,Value=my-cluster Name=ServiceName,Value=ma-app-service \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average
```

**Solutions par symptôme :**

| Symptôme | Solution |
|----------|----------|
| CPU > 80% | Augmenter CPU ou scaler |
| Memory > 80% | Augmenter memory |
| Latence élevée | Plus de tasks, vérifier DB |

---

### ❌ Scaling trop lent

**Solutions :**
```bash
# Réduire le cooldown
aws application-autoscaling register-scalable-target \
  --service-namespace ecs \
  --resource-id service/my-cluster/ma-app-service \
  --scalable-dimension ecs:service:DesiredCount \
  --min-capacity 2 \
  --max-capacity 10

aws application-autoscaling put-scaling-policy \
  --service-namespace ecs \
  --resource-id service/my-cluster/ma-app-service \
  --scalable-dimension ecs:service:DesiredCount \
  --policy-name cpu-scaling \
  --policy-type TargetTrackingScaling \
  --target-tracking-scaling-policy-configuration '{
    "TargetValue": 70,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ECSServiceAverageCPUUtilization"
    },
    "ScaleOutCooldown": 60,
    "ScaleInCooldown": 300
  }'
```

---

## 💰 COÛTS

### ❌ Facture Fargate élevée

**Analyser :**
```bash
# Voir les tasks en cours
aws ecs list-tasks --cluster my-cluster

# Détails (CPU/Memory)
aws ecs describe-tasks \
  --cluster my-cluster \
  --tasks $(aws ecs list-tasks --cluster my-cluster --query 'taskArns' --output text)
```

**Optimisations :**

| Action | Économie |
|--------|----------|
| Réduire CPU/Memory si sous-utilisé | Jusqu'à 50% |
| Utiliser FARGATE_SPOT | 70% |
| Auto Scaling agressif | Variable |
| Arrêter env non-prod la nuit | 60% |

---

## 🔗 LIENS

- **CLI Commands** → [CLI-Commands.md](./CLI-Commands.md)
- **ECS Concepts** → [01-ECS-Concepts-Complets.md](./01-ECS-Concepts-Complets.md)
- **Fargate Concepts** → [02-Fargate-Concepts-Complets.md](./02-Fargate-Concepts-Complets.md)
- **ECR Concepts** → [03-ECR-Concepts-Complets.md](./03-ECR-Concepts-Complets.md)

---

[⬅️ Retour au README](./README.md)
