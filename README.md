# 🚀 Architecte AWS - Les 9 Jobs

![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Niveau](https://img.shields.io/badge/Niveau-Intermédiaire-blue?style=for-the-badge)
![Durée](https://img.shields.io/badge/Durée-12--16h-green?style=for-the-badge)
![Free Tier](https://img.shields.io/badge/Free_Tier-Compatible-brightgreen?style=for-the-badge)

> 📚 Projet complet de déploiement d'infrastructure AWS couvrant 9 jobs progressifs, de EC2 à Step Functions.

---

## 📋 Présentation

Ce repository contient **toute la documentation et le code** pour maîtriser les services AWS essentiels à travers 9 jobs pratiques. Chaque job inclut les instructions **Dashboard (interface web)** et **CLI (ligne de commande)**.

### 🎯 Objectifs

À la fin de ce projet, vous saurez :

- ✅ Déployer une infrastructure web scalable (EC2, ALB, Auto Scaling)
- ✅ Héberger des sites statiques avec CDN mondial (S3, CloudFront)
- ✅ Gérer des bases de données managées (RDS)
- ✅ Créer des APIs serverless (Lambda, API Gateway)
- ✅ Monitorer et alerter (CloudWatch, SNS)
- ✅ Créer des pipelines ETL (AWS Glue)
- ✅ Analyser des données avec SQL (Athena, QuickSight)
- ✅ Déployer des conteneurs (ECS, Fargate, ECR)
- ✅ Orchestrer des workflows (Step Functions)

---

## 📁 Structure du Repository

```
📦 Architecte_AWS/
│
├── 📂 Docs-Projets/              # 🎯 GUIDES PAS-À-PAS DES 9 JOBS
│   ├── 00_concepts.md            # Concepts AWS essentiels
│   ├── 01_preparation.md         # Configuration du compte
│   ├── 02_guide_ssh.md           # Guide SSH complet
│   ├── Job1_EC2_AutoScaling_ALB.md
│   ├── Job2_S3_CloudFront.md
│   ├── Job3_RDS.md
│   ├── Job4_Lambda_API.md
│   ├── Job5_CloudWatch_SNS.md
│   ├── Job6_Glue_ETL.md
│   ├── Job7_Athena_QuickSight.md
│   ├── Job8_ECS_Fargate.md
│   └── Job9_StepFunctions.md
│
├── 📂 Cours-AWS/                 # 📖 MÉMOS & RÉFÉRENCE
│   ├── S3-DD Cloud + Hébergement web/
│   ├── RDS-Base de donnée relationnelles/
│   ├── ECS Fargate ECR/
│   ├── Athena Quicksight/
│   └── ...
│
├── 📂 Scripts + code + site/     # 💻 CODE SOURCE
│   └── App-ECS/                  # Application Node.js pour ECS
│
└── 📄 Architecte_AWS.pdf         # PDF original du projet
```

---

## 🗺️ Les 9 Jobs

| Job | Titre | Services AWS | Durée | Difficulté |
|:---:|-------|--------------|:-----:|:----------:|
| **1** | [EC2 + Auto Scaling + Load Balancer](Docs-Projets/Job1_EC2_AutoScaling_ALB.md) | EC2, ALB, ASG, SNS | 2-3h | ⭐⭐ |
| **2** | [Hébergement S3 + CloudFront](Docs-Projets/Job2_S3_CloudFront.md) | S3, CloudFront | 1h | ⭐ |
| **3** | [Base de données RDS](Docs-Projets/Job3_RDS.md) | RDS (MySQL/PostgreSQL) | 1h | ⭐ |
| **4** | [API Serverless Lambda](Docs-Projets/Job4_Lambda_API.md) | Lambda, API Gateway | 1-2h | ⭐⭐ |
| **5** | [Monitoring CloudWatch + SNS](Docs-Projets/Job5_CloudWatch_SNS.md) | CloudWatch, SNS | 1h | ⭐ |
| **6** | [Pipeline ETL Glue](Docs-Projets/Job6_Glue_ETL.md) | AWS Glue, S3 | 1-2h | ⭐⭐ |
| **7** | [Analyse Athena + QuickSight](Docs-Projets/Job7_Athena_QuickSight.md) | Athena, QuickSight | 1-2h | ⭐⭐ |
| **8** | [Conteneurs ECS Fargate](Docs-Projets/Job8_ECS_Fargate.md) | ECS, Fargate, ECR | 2h | ⭐⭐⭐ |
| **9** | [Orchestration Step Functions](Docs-Projets/Job9_StepFunctions.md) | Step Functions, Lambda | 1-2h | ⭐⭐⭐ |

---

## 🚀 Démarrage Rapide

### Prérequis

- [ ] Compte AWS créé ([aws.amazon.com](https://aws.amazon.com))
- [ ] MFA activé sur le compte root
- [ ] Utilisateur IAM admin créé
- [ ] Région **eu-west-3 (Paris)** sélectionnée
- [ ] Clé SSH créée

### Ordre recommandé

```
1. 📖 Lire Docs-Projets/00_concepts.md
2. ⚙️ Suivre Docs-Projets/01_preparation.md
3. 🔐 Lire Docs-Projets/02_guide_ssh.md
4. 🎯 Faire les Jobs 1 → 9 dans l'ordre
5. 🧹 Nettoyer les ressources après chaque job
```

---

## 💰 Coûts AWS (Free Tier)

| Service | Limite gratuite (12 mois) |
|---------|---------------------------|
| EC2 | 750h/mois (t2.micro) |
| RDS | 750h/mois (db.t3.micro) |
| S3 | 5 GB stockage |
| Lambda | 1M requêtes/mois |
| CloudWatch | 10 alarmes |
| SNS | 1000 notifications |
| Fargate | 750h vCPU/mois |
| Step Functions | 4000 transitions/mois |

> ⚠️ **Important** : Toujours supprimer les ressources après utilisation pour éviter les frais !

---

## 🔐 Sécurité

### ⚠️ NE JAMAIS :
- Partager vos clés d'accès AWS
- Committer vos credentials sur GitHub
- Laisser des ressources tourner inutilement
- Utiliser le compte root au quotidien

### ✅ TOUJOURS :
- Utiliser des Security Groups restrictifs
- Activer MFA sur votre compte
- Supprimer les ressources après utilisation
- Vérifier votre facture AWS régulièrement

---

## 📚 Ressources

- 📘 [Documentation AWS officielle](https://docs.aws.amazon.com/)
- 💰 [AWS Free Tier](https://aws.amazon.com/free/)
- 🧮 [AWS Pricing Calculator](https://calculator.aws/)
- 💬 [Forums AWS](https://repost.aws/)

---

## 🎓 Compétences visées

Ce projet valide les compétences suivantes :

- ✅ Administrer et sécuriser les infrastructures virtualisées
- ✅ Mettre en production des évolutions de l'infrastructure
- ✅ Participer à la détection et au traitement des incidents de sécurité
- ✅ Concevoir une architecture cloud complète

---

## 📝 Licence

Ce projet est fourni à des fins éducatives. Libre à vous de l'adapter et de le partager !

---

<div align="center">

**🎯 Prêt à commencer ?**

[![Commencer](https://img.shields.io/badge/Commencer_le_Job_1-FF9900?style=for-the-badge&logo=amazon-aws&logoColor=white)](Docs-Projets/Job1_EC2_AutoScaling_ALB.md)

---

*Projet réalisé dans le cadre de la formation Administration Systèmes et Réseaux - 2ème année*

**La Plateforme_**

</div>