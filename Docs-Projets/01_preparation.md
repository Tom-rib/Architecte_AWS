# ⚙️ 01. Prérequis et Configuration Initiale

> **Objectif** : Préparer ton environnement AWS et comprendre l'architecture du projet.  
> **Durée** : 45 minutes  
> **Niveau** : ⭐ Débutant

---

## 📋 Checklist des prérequis

Avant de commencer, assure-toi d'avoir :

- [ ] Un compte AWS (Free Tier activé)
- [ ] Une carte bancaire valide (pour validation du compte, pas de débit)
- [ ] Une connexion Internet stable
- [ ] Un navigateur web récent (Chrome, Firefox, Edge)
- [ ] Un éditeur de texte (VS Code, Notepad++, Sublime)
- [ ] (Optionnel) Un client SSH : PuTTY pour Windows, natif pour Linux/Mac

---

## 🆕 Création du compte AWS

### Étape 1 : Inscription

1. Va sur [aws.amazon.com](https://aws.amazon.com/)
2. Clique sur **"Créer un compte AWS"**
3. Remplis les informations :
   - Adresse email
   - Nom du compte
   - Mot de passe fort (min. 8 caractères)

### Étape 2 : Informations de contact

```
Type de compte : Personnel
Nom complet : [Ton nom]
Téléphone : [Ton numéro]
Pays : France
Adresse : [Ton adresse]
```

### Étape 3 : Informations de paiement

⚠️ **Important** : La carte bancaire est obligatoire pour valider le compte, mais tu ne seras **pas débité** si tu restes dans les limites du Free Tier.

AWS va effectuer une autorisation de 1€ (qui sera annulée).

### Étape 4 : Vérification d'identité

- Choisis **"Appel téléphonique"** ou **"SMS"**
- Saisis le code reçu
- Valide ton compte

### Étape 5 : Choix du plan

- Sélectionne **"Forfait de support de base - Gratuit"**
- C'est suffisant pour ce projet

✅ **Félicitations !** Ton compte AWS est créé.

---

## 🔐 Configuration de la sécurité

### 1. Activer l'authentification multifacteur (MFA)

⚠️ **TRÈS IMPORTANT** : Protège ton compte root !

1. Connecte-toi à la [console AWS](https://console.aws.amazon.com/)
2. Clique sur ton nom (en haut à droite) → **"Security credentials"**
3. Section **"Multi-factor authentication (MFA)"** → **"Assign MFA device"**
4. Choisis **"Authenticator app"**
5. Scanne le QR code avec :
   - Google Authenticator (mobile)
   - Microsoft Authenticator (mobile)
   - Authy (mobile/desktop)
6. Entre les 2 codes consécutifs
7. Clique sur **"Assign MFA"**

### 2. Créer un utilisateur IAM (pas d'utilisation du root)

```
Best practice : NE JAMAIS utiliser le compte root au quotidien
```

**Étapes :**

1. Dans la console AWS, cherche **"IAM"** dans la barre de recherche
2. Menu de gauche → **"Users"** → **"Add users"**
3. Nom d'utilisateur : `admin-user`
4. Coche **"Provide user access to the AWS Management Console"**
5. Choisis **"I want to create an IAM user"**
6. Définis un mot de passe
7. **Permissions** : Attache la policy **"AdministratorAccess"**
8. Clique sur **"Create user"**

✅ Utilise ce compte IAM pour la suite du projet !

---

## 🌍 Choix de la région AWS

### Régions disponibles

Pour ce projet, choisis une région **proche géographiquement** :

| Région | Code | Emplacement |
|--------|------|-------------|
| Europe (Paris) | `eu-west-3` | 🇫🇷 **Recommandé** |
| Europe (Irlande) | `eu-west-1` | 🇮🇪 Alternative |
| Europe (Francfort) | `eu-central-1` | 🇩🇪 Alternative |

### Comment changer de région ?

1. En haut à droite de la console AWS, clique sur le **nom de la région**
2. Sélectionne **"Europe (Paris) eu-west-3"**

⚠️ **Attention** : Reste sur la **même région** pour tout le projet !

---

## 🏗️ Architecture du projet

Voici ce que nous allons construire :

```
                         INTERNET
                            |
                            v
                   [Internet Gateway]
                            |
                   +--------+--------+
                   |      VPC        |
                   | 10.0.0.0/16     |
                   +--------+--------+
                            |
              +-------------+-------------+
              |                           |
        [Subnet Public A]          [Subnet Public B]
        10.0.1.0/24                10.0.2.0/24
        AZ : eu-west-3a            AZ : eu-west-3b
              |                           |
              |                           |
      [EC2 Instance 1]            [EC2 Instance 2]
      - Apache Web                - Apache Web
      - Security Group            - Security Group
              |                           |
              +-------------+-------------+
                            |
                 [Application Load Balancer]
                       (Port 80)
                            |
                            v
                   [Auto Scaling Group]
                   Min: 2 | Max: 5
```

### Composants de l'architecture

| Composant | Description | Quantité |
|-----------|-------------|----------|
| **VPC** | Réseau virtuel isolé | 1 |
| **Subnets** | Sous-réseaux publics | 2 (multi-AZ) |
| **Internet Gateway** | Accès Internet | 1 |
| **Load Balancer** | Répartiteur de charge | 1 |
| **EC2 Instances** | Serveurs web | 2 à 5 (dynamique) |
| **Auto Scaling Group** | Gestion automatique | 1 |
| **Security Groups** | Pare-feu | 2 |

---

## 🎨 Schéma réseau détaillé

### Plan d'adressage IP

```
VPC : 10.0.0.0/16 (65 536 adresses)
│
├── Subnet Public A (AZ-A) : 10.0.1.0/24 (256 adresses)
│   └── EC2 Instances (Auto Scaling)
│
├── Subnet Public B (AZ-B) : 10.0.2.0/24 (256 adresses)
│   └── EC2 Instances (Auto Scaling)
│
└── Internet Gateway : accès Internet pour tous les subnets
```

### Flux de trafic

```
1. Utilisateur → http://load-balancer-dns-name.com
2. Internet Gateway → VPC
3. Load Balancer → Health Check des instances
4. Load Balancer → Instance EC2 disponible (round-robin)
5. Instance EC2 → Traite la requête
6. Instance EC2 → Renvoie la page HTML
7. Load Balancer → Renvoie au client
```

---

## 📊 Ressources nécessaires

### Free Tier AWS (12 mois gratuits)

| Service | Limite gratuite | Notre utilisation |
|---------|-----------------|-------------------|
| **EC2** | 750h/mois (t2.micro) | ✅ 2-5 instances |
| **Load Balancer** | 750h/mois | ✅ 1 ALB |
| **Data Transfer** | 15 Go/mois | ✅ < 5 Go |
| **CloudWatch** | 10 alarmes | ✅ 3 alarmes |
| **Auto Scaling** | Gratuit | ✅ 1 groupe |

⚠️ **Conseil** : Active les alertes de facturation pour être prévenu si tu dépasses.

### Activer les alertes de facturation

1. Console AWS → Cherche **"Billing"**
2. Menu gauche → **"Billing preferences"**
3. Coche **"Receive Billing Alerts"**
4. Entre ton email
5. Clique sur **"Save preferences"**

---

## 🗂️ Organisation des ressources

### Convention de nommage

Pour rester organisé, utilise une convention de nommage cohérente :

```
Format : [projet]-[environnement]-[service]-[description]

Exemples :
- VPC : webapp-prod-vpc
- Subnet : webapp-prod-subnet-public-a
- EC2 : webapp-prod-ec2-web
- Load Balancer : webapp-prod-alb
- Security Group : webapp-prod-sg-web
- Auto Scaling : webapp-prod-asg
```

### Tags AWS

Les tags t'aideront à retrouver tes ressources :

```json
{
  "Project": "webapp-aws",
  "Environment": "production",
  "Owner": "[Ton nom]",
  "CostCenter": "formation"
}
```

---

## 🛠️ Outils recommandés

### 1. Console AWS (interface web)

✅ **On utilisera principalement ça**  
- Simple et visuel
- Parfait pour apprendre
- Accessible depuis n'importe où

### 2. AWS CLI (ligne de commande) - Optionnel

Installation si tu veux automatiser :

**Linux/Mac :**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows :**
```powershell
# Télécharge depuis : https://awscli.amazonaws.com/AWSCLIV2.msi
# Lance l'installateur
```

**Configuration :**
```bash
aws configure
AWS Access Key ID: [Depuis IAM]
AWS Secret Access Key: [Depuis IAM]
Default region name: eu-west-3
Default output format: json
```

---

## ✅ Checklist avant de commencer

Vérifie que tu as :

- [ ] Compte AWS créé et vérifié
- [ ] MFA activé sur le compte root
- [ ] Utilisateur IAM admin créé
- [ ] Région eu-west-3 (Paris) sélectionnée
- [ ] Alertes de facturation activées
- [ ] Convention de nommage définie
- [ ] Architecture comprise

---

## 📝 Récapitulatif

Tu as maintenant :
- ✅ Un compte AWS sécurisé
- ✅ Compris l'architecture du projet
- ✅ Défini la région et le plan d'adressage
- ✅ Activé les alertes de coûts

---

## 🚀 Prochaine étape

**Direction [02_vpc_securite.md](02_vpc_securite.md)** pour créer le réseau virtuel et les règles de sécurité !

---

## 🆘 Problèmes courants

### Erreur : "Votre compte nécessite une vérification"

➡️ **Solution** : Attends 24h maximum, AWS vérifie ton compte.

### Erreur : "Limite de région dépassée"

➡️ **Solution** : Certains comptes récents ont des limites. Contacte le support AWS.

### Je n'ai pas reçu le SMS de vérification

➡️ **Solution** : Choisis "Appel téléphonique" à la place.

---

