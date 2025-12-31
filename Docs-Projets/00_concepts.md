# 00 - Concepts AWS Essentiels 🧠

> Comprendre les bases avant de commencer les 9 Jobs

---

## 🌐 Qu'est-ce que le Cloud ?

Le **cloud computing** permet d'accéder à des ressources informatiques (serveurs, stockage, bases de données) via Internet, sans posséder physiquement l'infrastructure.

### Avantages du Cloud

| Avantage | Description |
|----------|-------------|
| **Élasticité** | Augmenter/réduire les ressources à la demande |
| **Pay-as-you-go** | Payer uniquement ce qu'on utilise |
| **Haute disponibilité** | Redondance et failover automatique |
| **Scalabilité** | Gérer des pics de trafic facilement |
| **Sécurité** | Infrastructure sécurisée par AWS |

---

## 🏗️ Services AWS Utilisés dans ce Projet

### 1. EC2 (Elastic Compute Cloud)
Serveurs virtuels dans le cloud.
- **Instance** = Un serveur virtuel
- **AMI** = Image de base (OS + logiciels)
- **Instance Type** = Taille du serveur (CPU, RAM)

### 2. VPC (Virtual Private Cloud)
Réseau virtuel isolé dans AWS.
- **Subnet** = Sous-réseau (public ou privé)
- **Internet Gateway** = Porte vers Internet
- **Route Table** = Règles de routage

### 3. Security Groups
Pare-feu virtuel pour vos instances.
- Règles **Inbound** = Trafic entrant
- Règles **Outbound** = Trafic sortant
- Par défaut : tout bloqué en entrée

### 4. Load Balancer (ALB)
Répartiteur de charge entre plusieurs instances.
- Distribue le trafic équitablement
- Health checks automatiques
- Haute disponibilité

### 5. Auto Scaling
Ajuste automatiquement le nombre d'instances.
- **Launch Template** = Modèle d'instance
- **Auto Scaling Group** = Groupe géré
- **Scaling Policy** = Règles de scaling

### 6. S3 (Simple Storage Service)
Stockage d'objets illimité.
- **Bucket** = Conteneur de fichiers
- **Object** = Fichier stocké
- Hébergement de sites statiques

### 7. CloudFront
CDN (Content Delivery Network) mondial.
- 200+ points de présence
- Cache des fichiers statiques
- HTTPS gratuit

### 8. RDS (Relational Database Service)
Base de données managée.
- MySQL, PostgreSQL, etc.
- Backups automatiques
- Haute disponibilité (Multi-AZ)

### 9. Lambda
Fonctions serverless.
- Exécution à la demande
- Pas de serveur à gérer
- Facturation à la milliseconde

### 10. API Gateway
Point d'entrée pour vos APIs.
- Routes HTTP/REST
- Authentification
- Throttling

### 11. CloudWatch
Monitoring et alertes.
- Métriques (CPU, mémoire, etc.)
- Logs centralisés
- Alarmes et notifications

### 12. SNS (Simple Notification Service)
Service de notifications.
- Email, SMS, HTTP
- Pub/Sub pattern
- Intégration avec CloudWatch

### 13. AWS Glue
ETL (Extract, Transform, Load) serverless.
- Crawlers pour détecter les schémas
- Jobs de transformation
- Data Catalog

### 14. Athena
Requêtes SQL sur S3.
- Serverless
- Pay per query
- Format Parquet, CSV, JSON

### 15. QuickSight
Visualisation de données.
- Dashboards interactifs
- Connexion à Athena/RDS
- Partage facile

### 16. ECS (Elastic Container Service)
Orchestration de conteneurs.
- **Cluster** = Groupe de ressources
- **Task Definition** = Configuration conteneur
- **Service** = Gestion du déploiement

### 17. Fargate
Exécution de conteneurs sans serveur.
- Pas d'instances à gérer
- Pay per vCPU/memory
- Scaling automatique

### 18. ECR (Elastic Container Registry)
Registry Docker privé.
- Stockage d'images Docker
- Scan de vulnérabilités
- Intégration ECS/Fargate

### 19. Step Functions
Orchestration de workflows.
- Machine d'état visuelle
- Coordination de Lambda
- Gestion des erreurs

### 20. IAM (Identity and Access Management)
Gestion des permissions.
- **Users** = Utilisateurs humains
- **Roles** = Permissions pour services
- **Policies** = Règles d'accès

---

## 🌍 Régions et Zones de Disponibilité

### Région
Zone géographique (ex: eu-west-3 = Paris)

### Zone de Disponibilité (AZ)
Data center isolé dans une région (ex: eu-west-3a, eu-west-3b)

```
Région eu-west-3 (Paris)
├── eu-west-3a (Data Center 1)
├── eu-west-3b (Data Center 2)
└── eu-west-3c (Data Center 3)
```

**Bonne pratique** : Déployer sur plusieurs AZ pour la haute disponibilité.

---

## 💰 AWS Free Tier

### 12 mois gratuits (nouveaux comptes)

| Service | Limite gratuite |
|---------|-----------------|
| EC2 | 750h/mois (t2.micro) |
| RDS | 750h/mois (db.t2.micro) |
| S3 | 5 GB stockage |
| Lambda | 1M requêtes/mois |
| CloudWatch | 10 alarmes |
| SNS | 1000 notifications |

⚠️ **Important** : Toujours vérifier sa facture !

---

## 🔐 Bonnes Pratiques de Sécurité

1. **MFA** sur le compte root
2. **IAM users** pour les opérations quotidiennes
3. **Security Groups** restrictifs
4. **Chiffrement** des données (au repos et en transit)
5. **Rotation** des credentials
6. **CloudTrail** pour l'audit

---

## 📚 Ressources Utiles

- [Documentation AWS](https://docs.aws.amazon.com/)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS Well-Architected](https://aws.amazon.com/architecture/well-architected/)
- [AWS Pricing Calculator](https://calculator.aws/)

---

[➡️ Suite : 01_preparation.md](./01_preparation.md)
