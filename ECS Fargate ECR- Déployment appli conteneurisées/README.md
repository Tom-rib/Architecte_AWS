# Job 8 : ECS + Fargate + ECR 🐳

Mémo rapide pour déployer des applications conteneurisées sans gérer l'infrastructure sous-jacente.

**Format :** Dashboard AWS (clics) + CLI (commandes)

---

## 📚 TABLE DES MATIÈRES

### Concepts de base
- **[ECS Basics](./01-ECS-Concepts-Complets.md)** - Qu'est-ce que ECS ?
- **[Fargate Basics](./02-Fargate-Concepts-Complets.md)** - Qu'est-ce que Fargate ?
- **[ECR Basics](./03-ECR-Concepts-Complets.md)** - Qu'est-ce que ECR ?
- **[Docker vs ECS vs Fargate](./01-ECS-Concepts-Complets.md#comparaison)** - Différences clés

### Docker & Images
- **[Docker Basics](./04-Docker-Basics.md)** - Dockerfile, build, run
- **[Dockerfile Avancé](./05-Dockerfile-Avance.md)** - Multi-stage, optimisation
- **[Push vers ECR](./06-Push-ECR.md)** - Authentification, tag, push

### ECS Configuration
- **[Clusters](./07-ECS-Clusters.md)** - Créer et gérer clusters
- **[Task Definitions](./08-Task-Definitions.md)** - Définir les tâches
- **[Services](./09-ECS-Services.md)** - Déployer et scaler
- **[Load Balancer + ECS](./10-ALB-Integration.md)** - Application Load Balancer

### Avancé
- **[Auto Scaling](./11-Auto-Scaling.md)** - Scaling automatique des tâches
- **[Rolling Updates](./12-Rolling-Updates.md)** - Déploiement sans interruption
- **[Networking](./13-Networking.md)** - VPC, Security Groups, subnets

### Référence
- **[CLI Commands](./CLI-Commands.md)** - Toutes les commandes AWS + Docker
- **[Troubleshooting](./Troubleshooting.md)** - Problèmes courants

---

## 🎯 FLUX RAPIDE

```
BASES :
1. Créer Dockerfile (04-Docker-Basics.md)
2. Build image locale (04-Docker-Basics.md)
3. Créer repo ECR (03-ECR-Concepts-Complets.md)
4. Push image vers ECR (06-Push-ECR.md)

DÉPLOIEMENT :
5. Créer cluster ECS (07-ECS-Clusters.md)
6. Créer Task Definition (08-Task-Definitions.md)
7. Créer Service (09-ECS-Services.md)

OPTIONNEL :
8. Ajouter Load Balancer (10-ALB-Integration.md)
9. Configurer Auto Scaling (11-Auto-Scaling.md)
10. Rolling Updates (12-Rolling-Updates.md)
```

---

## 💡 CONCEPTS CLÉS

| Concept | Utilité | Coût |
|---------|---------|------|
| **Docker** | Conteneuriser applications | GRATUIT (local) |
| **ECR** | Registry privé AWS pour images | 500 MB GRATUIT |
| **ECS** | Orchestrateur de conteneurs AWS | GRATUIT (control plane) |
| **Fargate** | Exécution serverless de conteneurs | 750h/mois GRATUIT |
| **Task Definition** | Blueprint du conteneur (CPU, RAM, ports) | GRATUIT |
| **Service** | Gère les tâches en cours d'exécution | GRATUIT |
| **Cluster** | Regroupement logique de services | GRATUIT |
| **ALB** | Load Balancer pour distribuer le trafic | ~18€/mois |

---

## 🐳 ARCHITECTURE

```
┌─────────────────────────────────────────────────────────────┐
│                        DÉVELOPPEUR                          │
│  docker build → docker tag → docker push                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      ECR (Registry)                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ ma-app:v1   │  │ ma-app:v2   │  │ ma-app:latest│        │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      ECS CLUSTER                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              TASK DEFINITION                         │   │
│  │  • Image: ECR URI                                    │   │
│  │  • CPU: 256 (.25 vCPU)                              │   │
│  │  • Memory: 512 MB                                    │   │
│  │  • Port: 3000                                        │   │
│  └─────────────────────────────────────────────────────┘   │
│                              │                              │
│                              ▼                              │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    SERVICE                           │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐          │   │
│  │  │ Task 1   │  │ Task 2   │  │ Task 3   │          │   │
│  │  │ (Fargate)│  │ (Fargate)│  │ (Fargate)│          │   │
│  │  └──────────┘  └──────────┘  └──────────┘          │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              APPLICATION LOAD BALANCER (optionnel)          │
│  • Distribue trafic entre tâches                            │
│  • Health checks                                            │
│  • HTTPS termination                                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 COMPARAISON DES MODES

| Aspect | ECS + EC2 | ECS + Fargate |
|--------|-----------|---------------|
| **Gestion serveurs** | Vous gérez les EC2 | AWS gère tout |
| **Scaling** | Manuel ou Auto Scaling | Automatique |
| **Coût** | Payez les EC2 | Payez par tâche |
| **Complexité** | Plus complexe | Plus simple |
| **Contrôle** | Total | Limité |
| **Idéal pour** | Workloads prévisibles | Workloads variables |

---

## 🚀 BESOIN D'AIDE RAPIDE ?

**Débutant ?**
- Qu'est-ce que ECS ? → [01-ECS-Concepts-Complets.md](./01-ECS-Concepts-Complets.md)
- Qu'est-ce que Fargate ? → [02-Fargate-Concepts-Complets.md](./02-Fargate-Concepts-Complets.md)
- Qu'est-ce que ECR ? → [03-ECR-Concepts-Complets.md](./03-ECR-Concepts-Complets.md)
- Comment créer un Dockerfile ? → [04-Docker-Basics.md](./04-Docker-Basics.md)

**Intermédiaire ?**
- Push image vers ECR ? → [06-Push-ECR.md](./06-Push-ECR.md)
- Créer un cluster ? → [07-ECS-Clusters.md](./07-ECS-Clusters.md)
- Créer une Task Definition ? → [08-Task-Definitions.md](./08-Task-Definitions.md)
- Créer un Service ? → [09-ECS-Services.md](./09-ECS-Services.md)

**Avancé ?**
- Load Balancer ? → [10-ALB-Integration.md](./10-ALB-Integration.md)
- Auto Scaling ? → [11-Auto-Scaling.md](./11-Auto-Scaling.md)
- Rolling Updates ? → [12-Rolling-Updates.md](./12-Rolling-Updates.md)
- Networking VPC ? → [13-Networking.md](./13-Networking.md)

**Problèmes ?**
- Image ne se push pas ? → [Troubleshooting.md](./Troubleshooting.md#ecr)
- Task ne démarre pas ? → [Troubleshooting.md](./Troubleshooting.md#task)
- Service unhealthy ? → [Troubleshooting.md](./Troubleshooting.md#service)
- Commandes CLI ? → [CLI-Commands.md](./CLI-Commands.md)

---

## 📌 NOTES IMPORTANTES

- **Région** : `eu-west-3` (Paris)
- **Free tier Fargate** : 750 heures/mois GRATUIT
- **Free tier ECR** : 500 MB stockage GRATUIT
- **CPU minimum** : 256 (.25 vCPU)
- **RAM minimum** : 512 MB
- **Port exposé** : Doit correspondre à votre app
- **VPC** : Fargate nécessite un VPC avec subnets
- **Security Group** : Doit autoriser le port de l'app
- **IAM Role** : ecsTaskExecutionRole requis

---

## 🎁 BONUS

### Cas d'usage courants

| Cas | Solution |
|-----|----------|
| Déployer une app Node.js | Dockerfile + ECR + ECS Fargate |
| Déployer une API Python | Dockerfile + ECR + ECS + ALB |
| Mise à jour sans downtime | Rolling Update (min 2 tâches) |
| Scaler automatiquement | Target Tracking (CPU/RAM) |
| Multi-conteneurs | Task Definition avec plusieurs containers |
| Logs centralisés | CloudWatch Logs (awslogs driver) |
| Secrets (DB password) | AWS Secrets Manager + Task Definition |
| Variables d'environnement | Task Definition > Environment |

---

## 🔗 LIENS UTILES

- **Voir GUIDE-SETUP-JOB8.md** : Configuration étape par étape du projet
- **Job 5 - CloudWatch + SNS** : Pour monitorer vos conteneurs

---

**Créé pour maîtriser ECS, Fargate et ECR rapidement** 📚

[⬅️ Retour au Job 7](../Job7-Athena-QuickSight/README.md)
