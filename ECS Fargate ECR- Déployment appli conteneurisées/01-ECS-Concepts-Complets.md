# 01 - ECS Concepts Complets 📦

Guide complet pour comprendre Amazon Elastic Container Service (ECS).

---

## 🎯 QU'EST-CE QUE ECS ?

**ECS** = Elastic Container Service = Service d'orchestration de conteneurs AWS.

```
ECS = "Kubernetes simplifié par AWS"
```

**En simple :**
- Vous avez une image Docker
- ECS la déploie, la gère, la scale
- Vous ne gérez pas les serveurs (avec Fargate)

---

## 🧠 VOCABULAIRE ECS

| Terme | Définition | Analogie |
|-------|------------|----------|
| **Cluster** | Regroupement logique de services | Un datacenter virtuel |
| **Task Definition** | Blueprint d'un conteneur | Une recette de cuisine |
| **Task** | Instance en cours d'exécution | Le plat cuisiné |
| **Service** | Gère plusieurs tâches identiques | Le chef qui cuisine |
| **Container** | L'application packagée | L'ingrédient principal |

---

## 📊 ARCHITECTURE ECS

```
┌─────────────────────────────────────────────────────────────┐
│                        ECS CLUSTER                          │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    SERVICE A                         │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │   │
│  │  │  Task 1  │  │  Task 2  │  │  Task 3  │          │   │
│  │  └──────────┘  └──────────┘  └──────────┘          │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    SERVICE B                         │   │
│  │  ┌──────────┐  ┌──────────┐                         │   │
│  │  │  Task 1  │  │  Task 2  │                         │   │
│  │  └──────────┘  └──────────┘                         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 CYCLE DE VIE ECS

```
1. CRÉER CLUSTER
   └── Regroupement logique

2. CRÉER TASK DEFINITION
   └── Définir image, CPU, RAM, ports

3. CRÉER SERVICE (ou lancer Task)
   └── Nombre de tâches souhaitées

4. ECS LANCE LES TASKS
   └── Télécharge image depuis ECR
   └── Démarre conteneurs
   └── Surveille santé

5. SERVICE MAINTIENT LE DESIRED COUNT
   └── Si task meurt → relance automatique
   └── Si scaling → ajuste le nombre
```

---

## 🏗️ COMPOSANTS DÉTAILLÉS

### 1. CLUSTER

**C'est quoi ?**
- Regroupement logique de ressources
- Peut contenir plusieurs services
- Isolation entre environnements (dev, prod)

**Types de clusters :**
| Type | Infrastructure | Gestion |
|------|----------------|---------|
| **Fargate** | Serverless | AWS gère tout |
| **EC2** | Instances EC2 | Vous gérez les instances |
| **External** | On-premises | Vous gérez tout |

**Bonnes pratiques :**
- 1 cluster par environnement (dev, staging, prod)
- Ou 1 cluster par application
- Nommage : `{app}-{env}-cluster`

---

### 2. TASK DEFINITION

**C'est quoi ?**
- Blueprint JSON qui définit comment lancer un conteneur
- Versionné (révisions)
- Réutilisable

**Paramètres clés :**

```json
{
  "family": "ma-app",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "containerDefinitions": [
    {
      "name": "ma-app",
      "image": "123456789.dkr.ecr.eu-west-3.amazonaws.com/ma-app:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
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
  ]
}
```

**CPU et Memory (Fargate) :**

| CPU (units) | Memory Options |
|-------------|----------------|
| 256 (.25 vCPU) | 512 MB, 1 GB, 2 GB |
| 512 (.5 vCPU) | 1 GB - 4 GB |
| 1024 (1 vCPU) | 2 GB - 8 GB |
| 2048 (2 vCPU) | 4 GB - 16 GB |
| 4096 (4 vCPU) | 8 GB - 30 GB |

---

### 3. TASK

**C'est quoi ?**
- Instance en cours d'exécution d'une Task Definition
- Peut contenir 1 ou plusieurs conteneurs
- A une IP privée (et publique si configuré)

**États d'une Task :**
```
PROVISIONING → PENDING → ACTIVATING → RUNNING → DEACTIVATING → STOPPING → STOPPED
```

**Pourquoi une Task s'arrête ?**
- Application crash
- Out of memory
- Arrêt manuel
- Scaling down
- Deployment (rolling update)

---

### 4. SERVICE

**C'est quoi ?**
- Gère le cycle de vie des Tasks
- Maintient le nombre souhaité (desired count)
- Gère les déploiements

**Fonctionnalités :**
- **Desired count** : Nombre de tâches à maintenir
- **Health checks** : Vérifie que les tâches sont saines
- **Load balancing** : Distribue le trafic
- **Auto scaling** : Ajuste automatiquement le nombre
- **Rolling updates** : Mise à jour sans downtime

**Types de déploiement :**

| Type | Description | Downtime |
|------|-------------|----------|
| **Rolling** | Remplace progressivement | Non |
| **Blue/Green** | Bascule entre 2 versions | Non |
| **External** | Contrôlé par un outil externe | Dépend |

---

## 🔐 IAM ROLES

### 1. Task Execution Role

**Utilisé par** : ECS Agent (pour lancer les tâches)

**Permissions :**
- Télécharger images depuis ECR
- Écrire logs dans CloudWatch
- Récupérer secrets depuis Secrets Manager

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
```

**Rôle AWS géré** : `AmazonECSTaskExecutionRolePolicy`

---

### 2. Task Role

**Utilisé par** : Votre application (dans le conteneur)

**Permissions** : Dépend de ce que fait votre app
- Accès S3
- Accès DynamoDB
- Appels API AWS

---

## 🌐 NETWORKING

### Network Modes

| Mode | Description | Fargate |
|------|-------------|---------|
| **awsvpc** | Chaque task a sa propre ENI | ✅ Requis |
| **bridge** | Partage l'ENI de l'instance | ❌ EC2 only |
| **host** | Utilise le réseau de l'hôte | ❌ EC2 only |
| **none** | Pas de réseau | ❌ EC2 only |

### Configuration réseau (Fargate)

```
VPC
├── Public Subnet (si IP publique nécessaire)
│   └── Task avec assignPublicIp: ENABLED
│
└── Private Subnet (recommandé pour prod)
    └── Task + NAT Gateway pour accès internet
```

**Security Groups :**
- Inbound : Port de votre app (ex: 3000)
- Outbound : All traffic (pour télécharger images, logs, etc.)

---

## 📊 MONITORING

### Métriques CloudWatch ECS

| Métrique | Description | Alarme si |
|----------|-------------|-----------|
| **CPUUtilization** | % CPU utilisé | > 80% |
| **MemoryUtilization** | % RAM utilisée | > 80% |
| **RunningTaskCount** | Nombre de tasks actives | < desired |
| **PendingTaskCount** | Tasks en attente | > 0 longtemps |

### Logs

**Configuration recommandée :**
```json
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

## 💰 COÛTS

### ECS lui-même = GRATUIT

Le "control plane" ECS est gratuit. Vous payez uniquement :

| Composant | Coût |
|-----------|------|
| **Fargate** | CPU + RAM par seconde |
| **EC2** | Instances EC2 |
| **ECR** | Stockage images |
| **ALB** | Load Balancer |
| **Data Transfer** | Sortie vers internet |

### Free Tier Fargate

- **750 heures** par mois (12 premiers mois)
- Équivalent à 1 task 24/7 pendant 1 mois

---

## ✅ CHECKLIST ECS

```
□ Comprendre Cluster vs Service vs Task vs Task Definition
□ Choisir Fargate ou EC2
□ Configurer IAM roles (Execution + Task)
□ Configurer VPC et Security Groups
□ Configurer logging CloudWatch
□ Planifier stratégie de déploiement
□ Configurer health checks
□ Planifier auto scaling (si nécessaire)
```

---

## 🔗 LIENS

- **Fargate** → [02-Fargate-Concepts-Complets.md](./02-Fargate-Concepts-Complets.md)
- **ECR** → [03-ECR-Concepts-Complets.md](./03-ECR-Concepts-Complets.md)
- **CLI Commands** → [CLI-Commands.md](./CLI-Commands.md)

---

[⬅️ Retour au README](./README.md)
