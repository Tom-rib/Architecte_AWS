# 🚀 Projet AWS : Application Web Scalable avec EC2, Load Balancer et Auto Scaling

![AWS](https://img.shields.io/badge/AWS-Cloud-orange?style=flat-square&logo=amazon-aws)
![Niveau](https://img.shields.io/badge/Niveau-Interm%C3%A9diaire-blue?style=flat-square)
![Durée](https://img.shields.io/badge/Dur%C3%A9e-4%E2%80%936h-green?style=flat-square)

## 📋 Présentation du projet

Ce projet consiste à déployer une **infrastructure web hautement disponible et scalable** sur Amazon Web Services (AWS). 

Tu vas apprendre à :
- Créer et configurer des serveurs virtuels (EC2)
- Mettre en place un système de répartition de charge (Load Balancer)
- Automatiser le scaling en fonction du trafic (Auto Scaling)
- Sécuriser ton infrastructure avec des Security Groups
- Surveiller tes ressources avec CloudWatch

## 🎯 Objectifs pédagogiques

✅ Comprendre l'architecture cloud AWS  
✅ Maîtriser les instances EC2  
✅ Configurer un Load Balancer  
✅ Implémenter l'Auto Scaling  
✅ Sécuriser une application web  
✅ Surveiller les performances  

## 🏗️ Architecture

```
                    Internet
                       |
                       v
                [Internet Gateway]
                       |
                       v
              [Application Load Balancer]
                   (Port 80/443)
                       |
        +--------------+---------------+
        |                              |
        v                              v
   [EC2 Instance 1]             [EC2 Instance 2]
   - Apache/Nginx               - Apache/Nginx
   - Security Group             - Security Group
        |                              |
        +---------------+--------------+
                        |
                        v
               [CloudWatch Metrics]
               - CPU Utilization
               - Network Traffic
               - Auto Scaling Alarms
```

## 📚 Documentation complète

### 🧠 Phase 1 : Compréhension (30 min)
- [📖 00. Concepts AWS essentiels](Docs-Projets/00_concepts.md)
  - Qu'est-ce que le cloud ?
  - Services AWS de base
  - VPC, EC2, Load Balancer, Auto Scaling

### 🛠️ Phase 2 : Préparation (1h30)
- [⚙️ 01. Prérequis et configuration initiale](Docs-Projets/01_preparation.md)
  - Création du compte AWS
  - Configuration de la console
  - Schéma réseau
  
- [🔒 02. VPC et Security Groups](Docs-Projets/02_vpc_securite.md)
  - Configuration du réseau virtuel
  - Règles de sécurité
  - Bonnes pratiques

### ⚙️ Phase 3 : Déploiement (2h30)
- [💻 03. Création de l'instance EC2](Docs-Projets/03_instance_ec2.md)
  - Choix de l'AMI
  - Configuration de l'instance
  - Connexion SSH
  
- [🌐 04. Installation de l'application web](Docs-Projets/04_application_web.md)
  - Installation d'Apache
  - Page de test
  - Vérification
  
- [⚖️ 05. Configuration du Load Balancer](Docs-Projets/05_load_balancer.md)
  - Création de l'ALB
  - Target Groups
  - Health Checks
  
- [📈 06. Mise en place de l'Auto Scaling](Docs-Projets/06_auto_scaling.md)
  - Launch Template
  - Auto Scaling Group
  - Scaling Policies

### ✅ Phase 4 : Validation (1h15)
- [🧪 07. Tests et validation](Docs-Projets/07_tests_validation.md)
  - Tests de charge
  - Vérification du scaling
  - Tests de haute disponibilité
  
- [📊 08. Surveillance CloudWatch](Docs-Projets/08_surveillance.md)
  - Métriques importantes
  - Alarmes
  - Dashboards

### 🧹 Phase 5 : Nettoyage (15 min)
- [🗑️ 09. Suppression des ressources](Docs-Projets/09_nettoyage.md)
  - Ordre de suppression
  - Vérification des coûts
  - Checklist complète

## 📦 Ressources additionnelles

### Scripts automatisés
- [📜 Scripts d'installation](scripts/)
  - `install_web_server.sh` : Installation automatique d'Apache
  - `test_load.sh` : Script de test de charge
  - `cleanup_aws.sh` : Nettoyage automatique

### Fichiers de configuration
- [⚙️ Configurations](configs/)
  - `user-data.sh` : Script de démarrage EC2
  - `security-group-rules.json` : Règles de sécurité



## ⏱️ Temps de réalisation estimé

| Phase | Durée | Niveau |
|-------|-------|--------|
| Compréhension | 30 min | ⭐ Débutant |
| Préparation | 1h30 | ⭐ Débutant |
| Déploiement | 2h30 | ⭐⭐ Intermédiaire |
| Validation | 1h15 | ⭐⭐ Intermédiaire |
| Nettoyage | 15 min | ⭐ Débutant |
| **TOTAL** | **4-6h** | ⭐⭐ Intermédiaire |

## 💰 Coûts AWS

Ce projet est réalisable **gratuitement** avec le Free Tier AWS :
- ✅ 750 heures EC2 t2.micro/mois (pendant 12 mois)
- ✅ 750 heures Load Balancer/mois
- ✅ CloudWatch : 10 alarmes gratuites

⚠️ **Important** : Pense à supprimer tes ressources après le projet !

## 🛠️ Prérequis techniques

**Obligatoire :**
- Compte AWS (carte bancaire requise, mais pas de débit avec Free Tier)
- Navigateur web récent
- Connexion Internet stable

**Recommandé :**
- Connaissances de base en Linux
- Notions de réseaux (IP, ports, protocoles)
- Terminal/ligne de commande

**Optionnel :**
- AWS CLI installé localement
- Client SSH (PuTTY sur Windows, natif sur Linux/Mac)

## 📖 Ordre de lecture recommandé

1. **Commence par lire** `00_concepts.md` pour comprendre les bases
2. **Suis l'ordre numérique** des fichiers dans `docs/`
3. **Ne saute pas d'étapes**, chaque fichier dépend du précédent
4. **Teste après chaque étape** avant de passer à la suivante
5. **N'oublie pas le nettoyage** pour éviter les frais

## 🎓 Compétences visées

À la fin de ce projet, tu seras capable de :
- ✅ Créer une infrastructure cloud complète
- ✅ Déployer des applications web sur AWS
- ✅ Mettre en place de la haute disponibilité
- ✅ Configurer l'auto-scaling
- ✅ Sécuriser une infrastructure AWS
- ✅ Surveiller et diagnostiquer des problèmes

## 🚨 Rappels de sécurité

⚠️ **NE JAMAIS** :
- Partager tes clés d'accès AWS
- Committer tes credentials sur GitHub
- Laisser des ressources tournant inutilement
- Utiliser le compte root pour les opérations quotidiennes

✅ **TOUJOURS** :
- Utiliser des Security Groups restrictifs
- Activer MFA sur ton compte AWS
- Supprimer les ressources après utilisation
- Vérifier ta facture AWS régulièrement

## 📞 Besoin d'aide ?

- 📘 [Documentation AWS officielle](https://docs.aws.amazon.com/)
- 💬 [Forums AWS](https://repost.aws/)
- 📧 [Support AWS](https://aws.amazon.com/support/)

## 📝 Licence

Ce projet est fourni à des fins éducatives. Libre à toi de l'adapter et de le partager !

---

**🎯 Prêt à commencer ? Direction le fichier [00_concepts.md](Docs-Projets/00_concepts.md) !**

---

*Projet réalisé dans le cadre de la formation Administration Systèmes et Réseaux - 2ème année*