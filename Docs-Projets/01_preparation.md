# 01 - Préparation et Configuration 🛠️

> Tout configurer avant de commencer les 9 Jobs

---

## ✅ Prérequis

- [ ] Compte AWS créé (carte bancaire requise)
- [ ] MFA activé sur le compte root
- [ ] Utilisateur IAM admin créé
- [ ] AWS CLI installé (optionnel)
- [ ] Client SSH (PuTTY sur Windows ou terminal natif)

---

## 🔐 Étape 1 : Sécuriser le compte AWS

### 1.1 Activer MFA sur le compte root

```
1. Console AWS → Cliquez sur votre nom (en haut à droite)
2. Security credentials
3. Multi-factor authentication (MFA) → Assign MFA device
4. Choisissez "Authenticator app"
5. Scannez le QR code avec Google Authenticator / Authy
6. Entrez 2 codes consécutifs
7. Cliquez "Add MFA" ✓
```

### 1.2 Créer un utilisateur IAM admin

```
1. IAM → Users → Create user
2. User name : admin-tom (ou votre nom)
3. ☑ Provide user access to AWS Management Console
4. ☑ I want to create an IAM user
5. Custom password → Entrez un mot de passe fort
6. Next

7. Attach policies directly
8. Cochez : AdministratorAccess
9. Next → Create user ✓

10. Téléchargez les credentials CSV !
```

⚠️ **Important** : Déconnectez-vous du root et reconnectez-vous avec l'utilisateur IAM.

---

## 🌍 Étape 2 : Choisir la région

### Région recommandée : eu-west-3 (Paris)

```
1. Console AWS → En haut à droite
2. Cliquez sur le nom de la région actuelle
3. Sélectionnez : Europe (Paris) eu-west-3
```

⚠️ **Restez sur la même région pour tout le projet !**

---

## 💻 Étape 3 : Installer AWS CLI (Optionnel)

### Windows (PowerShell Admin)

```powershell
# Télécharger et installer
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi

# Vérifier l'installation
aws --version
```

### Linux/Mac

```bash
# Télécharger
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Décompresser et installer
unzip awscliv2.zip
sudo ./aws/install

# Vérifier
aws --version
```

### Configurer AWS CLI

```bash
aws configure
```

Entrez :
- **AWS Access Key ID** : (depuis le CSV téléchargé)
- **AWS Secret Access Key** : (depuis le CSV téléchargé)
- **Default region name** : eu-west-3
- **Default output format** : json

---

## 🔑 Étape 4 : Créer une paire de clés SSH

### 🖥️ Dashboard

```
1. EC2 → Key Pairs (menu gauche)
2. Create key pair
3. Name : aws_arch (ou votre nom)
4. Key pair type : RSA
5. Private key file format : .pem
6. Create key pair ✓
7. Le fichier .pem se télécharge automatiquement
```

### 💻 CLI

```bash
aws ec2 create-key-pair \
  --key-name aws_arch \
  --query 'KeyMaterial' \
  --output text > aws_arch.pem

# Définir les permissions
chmod 400 aws_arch.pem
```

### Stocker la clé en sécurité

**Windows :**
```
C:\aws-keys\aws_arch.pem
```

**Linux/Mac :**
```
~/.ssh/aws_arch.pem
```

---

## 💵 Étape 5 : Activer les alertes de facturation

```
1. Console AWS → Billing Dashboard (chercher "Billing")
2. Menu gauche → Billing preferences
3. ☑ Receive Billing Alerts
4. Entrez votre email
5. Save preferences ✓
```

### Créer une alerte budget

```
1. Billing → Budgets → Create a budget
2. Budget type : Cost budget
3. Budget name : Monthly-Budget
4. Budget amount : 10 (ou votre limite)
5. Configure alerts → 80% threshold
6. Email : votre-email@example.com
7. Create budget ✓
```

---

## 🏗️ Architecture du Projet

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
        eu-west-3a                 eu-west-3b
              |                           |
      [EC2 Instance]              [EC2 Instance]
              |                           |
              +-------------+-------------+
                            |
                 [Application Load Balancer]
                            |
                   [Auto Scaling Group]
```

---

## 📝 Convention de nommage

Utilisez une convention cohérente :

```
Format : [projet]-[environnement]-[service]-[description]

Exemples :
- VPC          : webapp-prod-vpc
- Subnet       : webapp-prod-subnet-public-a
- EC2          : webapp-prod-ec2-web
- Load Balancer: webapp-prod-alb
- Security Group: webapp-prod-sg-web
- Auto Scaling : webapp-prod-asg
```

---

## 🏷️ Tags recommandés

```json
{
  "Project": "webapp-aws",
  "Environment": "production",
  "Owner": "VotreNom",
  "CostCenter": "formation"
}
```

---

## ✅ Checklist avant de commencer

- [ ] Compte AWS sécurisé (MFA + IAM user)
- [ ] Région eu-west-3 sélectionnée
- [ ] Paire de clés SSH créée
- [ ] Alertes de facturation activées
- [ ] AWS CLI configuré (optionnel)

---

[⬅️ Retour : 00_concepts.md](./00_concepts.md) | [➡️ Suite : 02_guide_ssh.md](./02_guide_ssh.md)
