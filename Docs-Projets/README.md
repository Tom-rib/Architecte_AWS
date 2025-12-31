# 📚 Documentation des 9 Jobs AWS

> Guide complet pour déployer une infrastructure AWS de A à Z

---

## 🎯 Objectif du Projet

Ce projet couvre **9 Jobs AWS progressifs** pour maîtriser les services cloud essentiels. Chaque job inclut les instructions **Dashboard (interface web)** et **CLI (ligne de commande)**.

---

## 📖 Structure des Fichiers

### Introduction
| Fichier | Description |
|---------|-------------|
| [00_concepts.md](./00_concepts.md) | Concepts AWS essentiels (VPC, IAM, régions...) |
| [01_preparation.md](./01_preparation.md) | Configuration du compte, sécurité, prérequis |
| [02_guide_ssh.md](./02_guide_ssh.md) | Guide complet de connexion SSH |

### Les 9 Jobs
| Job | Fichier | Services AWS | Durée |
|-----|---------|--------------|-------|
| **Job 1** | [Job1_EC2_AutoScaling_ALB.md](./Job1_EC2_AutoScaling_ALB.md) | EC2, Auto Scaling, Load Balancer | 2-3h |
| **Job 2** | [Job2_S3_CloudFront.md](./Job2_S3_CloudFront.md) | S3, CloudFront | 1h |
| **Job 3** | [Job3_RDS.md](./Job3_RDS.md) | RDS (MySQL/PostgreSQL) | 1h |
| **Job 4** | [Job4_Lambda_API.md](./Job4_Lambda_API.md) | Lambda, API Gateway | 1-2h |
| **Job 5** | [Job5_CloudWatch_SNS.md](./Job5_CloudWatch_SNS.md) | CloudWatch, SNS | 1h |
| **Job 6** | [Job6_Glue_ETL.md](./Job6_Glue_ETL.md) | AWS Glue, S3 | 1-2h |
| **Job 7** | [Job7_Athena_QuickSight.md](./Job7_Athena_QuickSight.md) | Athena, QuickSight | 1-2h |
| **Job 8** | [Job8_ECS_Fargate.md](./Job8_ECS_Fargate.md) | ECS, Fargate, ECR | 2h |
| **Job 9** | [Job9_StepFunctions.md](./Job9_StepFunctions.md) | Step Functions, Lambda | 1-2h |

---

## 🚀 Ordre Recommandé

```
1. Lire 00_concepts.md (comprendre les bases)
2. Suivre 01_preparation.md (configurer le compte)
3. Lire 02_guide_ssh.md (maîtriser SSH)
4. Faire les Jobs dans l'ordre (1 → 9)
5. Nettoyer les ressources après chaque job
```

---

## 💰 Coûts AWS

| Service | Free Tier (12 mois) |
|---------|---------------------|
| EC2 | 750h/mois (t2.micro) |
| RDS | 750h/mois (db.t3.micro) |
| S3 | 5 GB stockage |
| Lambda | 1M requêtes/mois |
| CloudWatch | 10 alarmes |
| SNS | 1000 notifications |
| Fargate | 750h vCPU/mois |
| Step Functions | 4000 transitions/mois |

⚠️ **Important** : Toujours supprimer les ressources après utilisation !

---

## 🌍 Région Utilisée

**eu-west-3 (Paris)** - Utilisée dans tous les exemples

---

## 🔐 Sécurité

- ✅ Activer MFA sur le compte root
- ✅ Utiliser des utilisateurs IAM (pas root)
- ✅ Security Groups restrictifs
- ✅ Ne jamais committer les credentials
- ✅ Vérifier la facture régulièrement

---

## 📝 Format des Guides

Chaque job suit cette structure :

```
🎯 Objectif
📦 Ressources AWS utilisées
💰 Coûts
🖥️ Dashboard (étapes GUI)
💻 CLI (commandes)
🔧 Troubleshooting
🧹 Nettoyage
✅ Checklist finale
```

---

## ⏱️ Durée Totale Estimée

| Phase | Durée |
|-------|-------|
| Préparation | 1-2h |
| Jobs 1-3 | 4-5h |
| Jobs 4-6 | 3-4h |
| Jobs 7-9 | 4-5h |
| **Total** | **12-16h** |

---

## 🎓 Compétences Acquises

À la fin de ce projet, vous saurez :

- ✅ Déployer une infrastructure web scalable
- ✅ Gérer le stockage cloud (S3, RDS)
- ✅ Créer des APIs serverless
- ✅ Monitorer et alerter
- ✅ Créer des pipelines de données
- ✅ Analyser des données avec SQL
- ✅ Déployer des conteneurs
- ✅ Orchestrer des workflows

---

## 📞 Ressources

- [Documentation AWS](https://docs.aws.amazon.com/)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS Pricing Calculator](https://calculator.aws/)

---

**Bon courage ! 🚀**
