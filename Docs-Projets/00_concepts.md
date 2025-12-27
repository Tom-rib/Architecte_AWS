# 📖 00. Concepts AWS Essentiels

> **Objectif** : Comprendre les notions de base d'AWS avant de démarrer le projet.  
> **Durée** : 30 minutes  
> **Niveau** : ⭐ Débutant

---

## 🌐 Qu'est-ce que le Cloud Computing ?

Le **cloud computing** (informatique en nuage) consiste à utiliser des serveurs distants pour stocker, gérer et traiter des données, au lieu d'utiliser un serveur local ou un ordinateur personnel.

### Les 3 types de cloud

| Type | Description | Exemple |
|------|-------------|---------|
| **IaaS** | Infrastructure as a Service | AWS EC2, Azure VM |
| **PaaS** | Platform as a Service | Heroku, Google App Engine |
| **SaaS** | Software as a Service | Gmail, Office 365 |

**AWS propose principalement de l'IaaS** : tu gères l'infrastructure (serveurs, réseau, stockage).

---

## 🏢 Qu'est-ce qu'AWS ?

**Amazon Web Services (AWS)** est la plateforme cloud la plus utilisée au monde. Elle propose plus de 200 services pour :
- Héberger des applications
- Stocker des données
- Gérer des bases de données
- Analyser des données
- Sécuriser des infrastructures

### Avantages d'AWS

✅ **Pas d'investissement initial** : tu paies uniquement ce que tu utilises  
✅ **Scalabilité** : adapte tes ressources à la demande  
✅ **Haute disponibilité** : services répartis dans le monde entier  
✅ **Sécurité** : certifications et conformité  

---

## 🧩 Services AWS utilisés dans ce projet

### 1. 💻 Amazon EC2 (Elastic Compute Cloud)

**C'est quoi ?**  
Des serveurs virtuels dans le cloud. Tu peux lancer, arrêter et configurer des machines virtuelles en quelques clics.

**À quoi ça sert ?**  
Héberger des applications, des sites web, des bases de données, etc.

**Concepts clés :**
- **Instance** : un serveur virtuel
- **AMI (Amazon Machine Image)** : image système (Linux, Windows, etc.)
- **Type d'instance** : t2.micro, t2.small, etc. (CPU, RAM, stockage)
- **Key Pair** : clés SSH pour se connecter à l'instance

**Exemple d'utilisation :**
```bash
# Se connecter à une instance EC2
ssh -i ma-cle.pem ec2-user@54.123.45.67
```

---

### 2. ⚖️ Elastic Load Balancer (ELB)

**C'est quoi ?**  
Un répartiteur de charge qui distribue le trafic entre plusieurs serveurs.

**À quoi ça sert ?**  
- Améliorer la disponibilité (si un serveur tombe, les autres prennent le relais)
- Répartir la charge (éviter la surcharge d'un seul serveur)

**Types de Load Balancer :**
- **Application Load Balancer (ALB)** : pour HTTP/HTTPS → **on utilisera celui-ci**
- **Network Load Balancer (NLB)** : pour TCP/UDP
- **Classic Load Balancer** : ancienne version (déprécié)

**Schéma :**
```
  Utilisateur 1 ──┐
  Utilisateur 2 ──┼──→ [Load Balancer] ──┬──→ Serveur 1
  Utilisateur 3 ──┘                       ├──→ Serveur 2
                                          └──→ Serveur 3
```

---

### 3. 📈 Auto Scaling

**C'est quoi ?**  
Un service qui ajuste automatiquement le nombre d'instances EC2 en fonction de la charge.

**À quoi ça sert ?**  
- **Scale out** : ajouter des serveurs si le trafic augmente
- **Scale in** : supprimer des serveurs si le trafic diminue

**Concepts clés :**
- **Launch Template** : modèle de configuration pour lancer des instances
- **Auto Scaling Group** : groupe d'instances gérées automatiquement
- **Scaling Policy** : règles de scaling (ex : ajouter 1 instance si CPU > 70%)

**Exemple :**
```
08h00 : 1 instance (trafic faible)
12h00 : 5 instances (pic de midi)
18h00 : 3 instances (trafic modéré)
02h00 : 1 instance (nuit)
```

---

### 4. 🔒 Security Groups

**C'est quoi ?**  
Un pare-feu virtuel qui contrôle le trafic entrant et sortant des instances EC2.

**À quoi ça sert ?**  
Sécuriser tes serveurs en autorisant uniquement certains ports et adresses IP.

**Règles de base :**
```
Inbound Rules (trafic entrant) :
- Port 22 (SSH) : accès administrateur
- Port 80 (HTTP) : accès web
- Port 443 (HTTPS) : accès web sécurisé

Outbound Rules (trafic sortant) :
- Généralement : tout autorisé (0.0.0.0/0)
```

**Exemple :**
```json
{
  "Port": 80,
  "Protocol": "TCP",
  "Source": "0.0.0.0/0",
  "Description": "Autoriser le trafic web depuis Internet"
}
```

---

### 5. 🌐 VPC (Virtual Private Cloud)

**C'est quoi ?**  
Un réseau virtuel isolé dans le cloud AWS.

**À quoi ça sert ?**  
Créer ton propre réseau avec tes propres règles (sous-réseaux, passerelles, tables de routage).

**Concepts clés :**
- **Subnet** : sous-réseau (public ou privé)
- **Internet Gateway** : permet l'accès à Internet
- **Route Table** : table de routage du trafic

**Schéma simplifié :**
```
         [Internet]
             |
      [Internet Gateway]
             |
          [VPC]
         /       \
  [Subnet A]  [Subnet B]
   (public)    (privé)
      |            |
  [EC2 Web]   [EC2 BDD]
```

---

### 6. 📊 CloudWatch

**C'est quoi ?**  
Un service de surveillance et d'observation des ressources AWS.

**À quoi ça sert ?**  
- Collecter des métriques (CPU, RAM, réseau)
- Créer des alarmes (alertes si CPU > 80%)
- Visualiser des dashboards

**Métriques utiles :**
- **CPUUtilization** : utilisation du processeur
- **NetworkIn/Out** : trafic réseau
- **StatusCheckFailed** : échec du health check

---

## 🔄 Flux de fonctionnement global

Voici comment tous ces services vont interagir dans notre projet :

```
1. L'utilisateur accède à l'URL du Load Balancer
         ↓
2. Le Load Balancer vérifie quelles instances sont en bonne santé
         ↓
3. Il envoie la requête vers une instance disponible
         ↓
4. L'instance EC2 traite la requête et renvoie la page web
         ↓
5. CloudWatch surveille les métriques (CPU, trafic)
         ↓
6. Si CPU > 70%, l'Auto Scaling ajoute une nouvelle instance
         ↓
7. Le Load Balancer intègre automatiquement la nouvelle instance
```

---

## 📝 Vocabulaire AWS à connaître

| Terme | Définition |
|-------|------------|
| **Region** | Zone géographique AWS (ex : eu-west-3 = Paris) |
| **Availability Zone (AZ)** | Centre de données dans une région |
| **AMI** | Image système pour créer une instance EC2 |
| **Instance** | Serveur virtuel EC2 |
| **Snapshot** | Sauvegarde d'un volume (disque) |
| **Elastic IP** | Adresse IP publique fixe |
| **IAM** | Gestion des accès et permissions |
| **Free Tier** | Offre gratuite AWS (12 mois) |
| **Tag** | Étiquette pour organiser les ressources |

---

## 🎯 Ce qu'il faut retenir

✅ **EC2** = serveurs virtuels  
✅ **Load Balancer** = répartiteur de charge  
✅ **Auto Scaling** = ajustement automatique du nombre de serveurs  
✅ **Security Groups** = pare-feu pour sécuriser  
✅ **VPC** = réseau virtuel isolé  
✅ **CloudWatch** = surveillance et alertes  

---

## 🧪 Quiz de compréhension

Avant de passer à la suite, vérifie que tu as compris :

1. ❓ Quelle est la différence entre un Load Balancer et Auto Scaling ?
2. ❓ À quoi sert un Security Group ?
3. ❓ Pourquoi utilise-t-on plusieurs instances EC2 plutôt qu'une seule ?
4. ❓ Qu'est-ce qu'une AMI ?
5. ❓ Comment CloudWatch aide-t-il à gérer l'infrastructure ?

<details>
<summary>🔍 Voir les réponses</summary>

1. Le Load Balancer répartit le trafic entre les serveurs. L'Auto Scaling ajuste le nombre de serveurs.
2. Un Security Group contrôle le trafic entrant/sortant (comme un firewall).
3. Pour la haute disponibilité : si un serveur tombe, les autres continuent de fonctionner.
4. Une AMI est une image système (template) pour créer des instances EC2.
5. CloudWatch surveille les métriques et déclenche des alarmes pour automatiser les actions (comme le scaling).

</details>

---

## 📚 Ressources complémentaires

- [AWS pour les débutants (vidéo)](https://www.youtube.com/watch?v=r4YIdn2eTm4)
- [Documentation EC2](https://docs.aws.amazon.com/ec2/)
- [Documentation ELB](https://docs.aws.amazon.com/elasticloadbalancing/)
- [Glossaire AWS complet](https://docs.aws.amazon.com/general/latest/gr/glos-chap.html)

---

**🎯 Prêt pour la suite ? Direction [01_preparation.md](01_preparation.md) !**