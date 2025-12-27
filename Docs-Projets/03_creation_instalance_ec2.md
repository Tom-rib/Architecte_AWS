# 💻 03. Création de l'instance EC2

> **Objectif** : Créer et configurer une instance EC2 avec une application web de test.  
> **Durée** : 45 minutes  
> **Niveau** : ⭐⭐ Intermédiaire

---

## 🎯 Ce que tu vas créer

Dans cette étape, nous allons :
- ✅ Créer une paire de clés SSH
- ✅ Lancer une instance EC2 t2.micro
- ✅ Se connecter à l'instance
- ✅ Vérifier le bon fonctionnement

---

## 🔑 Étape 1 : Créer une paire de clés SSH

### 1.1. Accéder au service EC2

1. Console AWS → Cherche **"EC2"**
2. Clique sur **"EC2"**
3. Vérifie la région : **Europe (Paris) eu-west-3**

### 1.2. Créer la paire de clés

1. Menu de gauche → **"Network & Security"** → **"Key Pairs"**
2. Clique sur **"Create key pair"**

**Configuration :**

```yaml
Name: webapp-prod-keypair
Key pair type: RSA
Private key file format: 
  - .pem (Linux/Mac)
  - .ppk (Windows avec PuTTY)
```

3. Clique sur **"Create key pair"**
4. 💾 **IMPORTANT** : Le fichier se télécharge automatiquement
5. **Sauvegarde-le précieusement** (tu ne pourras pas le retélécharger)

### 1.3. Sécuriser la clé (Linux/Mac)

```bash
# Déplace la clé dans un dossier dédié
mkdir -p ~/.ssh/aws-keys
mv ~/Downloads/webapp-prod-keypair.pem ~/.ssh/aws-keys/

# Change les permissions (obligatoire)
chmod 400 ~/.ssh/aws-keys/webapp-prod-keypair.pem
```

### 1.4. Sécuriser la clé (Windows avec PuTTY)

Si tu as téléchargé un fichier `.pem` sur Windows :

1. Télécharge **PuTTYgen** depuis [putty.org](https://www.putty.org/)
2. Ouvre PuTTYgen
3. **Conversions** → **Import key**
4. Sélectionne `webapp-prod-keypair.pem`
5. **Save private key** (au format `.ppk`)
6. Sauvegarde le fichier `.ppk`

---

## 🚀 Étape 2 : Lancer une instance EC2

### 2.1. Démarrer la création

1. Console EC2 → **"Instances"** (menu gauche)
2. Clique sur **"Launch instances"**

### 2.2. Configuration de l'instance

#### Nom et tags

```yaml
Name: webapp-prod-ec2-web-01
Tags:
  - Key: Name, Value: webapp-prod-ec2-web-01
  - Key: Project, Value: webapp-aws
  - Key: Environment, Value: production
```

#### Application and OS Images (AMI)

```yaml
AMI: Amazon Linux 2023 AMI
Architecture: 64-bit (x86)
```

✅ **Choisis l'AMI gratuite** avec le badge "Free tier eligible"

#### Instance type

```yaml
Instance type: t2.micro
  - 1 vCPU
  - 1 GiB RAM
  - Free tier eligible ✅
```

#### Key pair

```yaml
Key pair name: webapp-prod-keypair
```

#### Network settings

Clique sur **"Edit"** et configure :

```yaml
VPC: webapp-prod-vpc
Subnet: webapp-prod-subnet-public1-eu-west-3a
Auto-assign public IP: Enable
Firewall (security groups): Select existing security group
Security group: webapp-prod-sg-web
```

#### Configure storage

```yaml
Size: 8 GiB (par défaut)
Volume type: gp3 (par défaut)
Delete on termination: Yes (coché)
```

✅ 8 GiB est suffisant et reste dans le Free Tier (30 Go max)

#### Advanced details

Scroll jusqu'à **"User data"** et colle ce script :

```bash
#!/bin/bash
# Script d'installation automatique d'Apache

# Mise à jour du système
yum update -y

# Installation d'Apache
yum install -y httpd

# Démarrage d'Apache
systemctl start httpd
systemctl enable httpd

# Création d'une page de test
echo "<html>
<head>
    <title>Instance EC2 - Test</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255,255,255,0.1);
            padding: 40px;
            border-radius: 10px;
            text-align: center;
        }
        h1 { font-size: 3em; }
        .info { 
            background: rgba(0,0,0,0.2);
            padding: 20px;
            margin-top: 20px;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class='container'>
        <h1>🚀 Application Web AWS</h1>
        <h2>Instance EC2 opérationnelle !</h2>
        <div class='info'>
            <p><strong>Instance ID:</strong> $(ec2-metadata --instance-id | cut -d ' ' -f 2)</p>
            <p><strong>Availability Zone:</strong> $(ec2-metadata --availability-zone | cut -d ' ' -f 2)</p>
            <p><strong>Private IP:</strong> $(ec2-metadata --local-ipv4 | cut -d ' ' -f 2)</p>
            <p><strong>Public IP:</strong> $(ec2-metadata --public-ipv4 | cut -d ' ' -f 2)</p>
        </div>
        <p style='margin-top: 30px; font-size: 0.8em;'>Projet AWS - Auto Scaling & Load Balancer</p>
    </div>
</body>
</html>" > /var/www/html/index.html

# Permissions
chown apache:apache /var/www/html/index.html
chmod 644 /var/www/html/index.html
```

**Ce script fait quoi ?**
- Met à jour le système
- Installe Apache (serveur web)
- Démarre Apache automatiquement
- Crée une belle page HTML avec les infos de l'instance

### 2.3. Résumé et lancement

1. Dans le panneau de droite, vérifie le **Summary**
2. **Number of instances** : `1`
3. Clique sur **"Launch instance"**
4. ✅ Message : "Successfully initiated launch of instance"
5. Clique sur l'ID de l'instance (ex : `i-0123456789abcdef`)

---

## 🔍 Étape 3 : Vérifier l'instance

### 3.1. État de l'instance

1. Console EC2 → **"Instances"**
2. Trouve ton instance : `webapp-prod-ec2-web-01`
3. Attends que :
   - **Instance state** : `Running` ✅
   - **Status check** : `2/2 checks passed` ✅

⏱️ Ça prend 1-2 minutes

### 3.2. Récupérer les informations

Sélectionne ton instance et note :

```yaml
Instance ID: i-xxxxxxxxxxxxxxxxx
Public IPv4 address: 13.xx.xx.xx
Private IPv4 address: 10.0.1.xx
Availability Zone: eu-west-3a
```

---

## 🔌 Étape 4 : Se connecter en SSH

### 4.1. Connexion depuis Linux/Mac

Ouvre un terminal :

```bash
# Remplace l'IP par celle de ton instance
ssh -i ~/.ssh/aws-keys/webapp-prod-keypair.pem ec2-user@13.xx.xx.xx
```

**Première connexion :**
```
The authenticity of host '13.xx.xx.xx' can't be established.
Are you sure you want to continue connecting (yes/no)? 
```
👉 Tape **yes**

✅ Tu es connecté ! Tu devrais voir :

```
       __|  __|_  )
       _|  (     /   Amazon Linux 2023
      ___|\___|___|

[ec2-user@ip-10-0-1-xx ~]$ 
```

### 4.2. Connexion depuis Windows (PuTTY)

1. Ouvre **PuTTY**
2. **Host Name** : `ec2-user@13.xx.xx.xx`
3. **Port** : `22`
4. Menu gauche → **Connection** → **SSH** → **Auth**
5. **Private key file** : Sélectionne ton fichier `.ppk`
6. Clique sur **Open**
7. Accepte le certificat (première fois)

✅ Tu es connecté !

---

## ✅ Étape 5 : Vérifier Apache

### 5.1. Vérifier le service

Une fois connecté en SSH :

```bash
# Vérifier qu'Apache tourne
sudo systemctl status httpd

# Tu devrais voir :
# Active: active (running)
```

Si Apache ne tourne pas :

```bash
sudo systemctl start httpd
sudo systemctl enable httpd
```

### 5.2. Tester localement

```bash
# Depuis l'instance EC2
curl http://localhost

# Tu devrais voir le code HTML de la page
```

### 5.3. Tester depuis ton navigateur

1. Ouvre ton navigateur
2. Va sur : `http://13.xx.xx.xx` (remplace par l'IP publique de ton instance)
3. ✅ Tu devrais voir la page web avec les infos de l'instance

**Si ça ne fonctionne pas** :
- Vérifie le Security Group (port 80 autorisé ?)
- Vérifie que l'instance a une IP publique
- Vérifie qu'Apache tourne : `sudo systemctl status httpd`

---

## 📊 Étape 6 : Tests de validation

### 6.1. Vérifier les logs Apache

```bash
# Logs d'accès
sudo tail -f /var/log/httpd/access_log

# Logs d'erreurs
sudo tail -f /var/log/httpd/error_log
```

### 6.2. Vérifier les métadonnées EC2

```bash
# Instance ID
ec2-metadata --instance-id

# Availability Zone
ec2-metadata --availability-zone

# IP privée
ec2-metadata --local-ipv4

# IP publique
ec2-metadata --public-ipv4
```

### 6.3. Test de connectivité réseau

```bash
# Ping vers Internet
ping -c 4 8.8.8.8

# Résolution DNS
nslookup google.com

# Connexion HTTP
curl -I https://www.google.com
```

---

## 📝 Commandes utiles

### Gestion d'Apache

```bash
# Démarrer Apache
sudo systemctl start httpd

# Arrêter Apache
sudo systemctl stop httpd

# Redémarrer Apache
sudo systemctl restart httpd

# Recharger la config (sans redémarrage)
sudo systemctl reload httpd

# Vérifier le statut
sudo systemctl status httpd

# Activer au démarrage
sudo systemctl enable httpd
```

### Gestion des fichiers web

```bash
# Aller dans le dossier web
cd /var/www/html

# Lister les fichiers
ls -lah

# Éditer la page
sudo nano index.html

# Voir les permissions
ls -l /var/www/html/index.html
```

### Surveillance système

```bash
# Utilisation CPU/RAM
top

# Espace disque
df -h

# Processus Apache
ps aux | grep httpd

# Connexions réseau
netstat -tuln | grep 80
```

---

## 🎨 Personnaliser la page web

### Créer une page personnalisée

```bash
# Se connecter en SSH
ssh -i ta-cle.pem ec2-user@IP-PUBLIQUE

# Éditer la page
sudo nano /var/www/html/index.html

# Modifier le contenu HTML
# Sauvegarder : Ctrl+O, Enter, Ctrl+X

# Tester les changements
curl http://localhost
```

**Exemple de page simple :**

```html
<!DOCTYPE html>
<html>
<head>
    <title>Mon instance EC2</title>
</head>
<body>
    <h1>Bienvenue sur mon serveur AWS !</h1>
    <p>Cette instance est hébergée sur Amazon EC2</p>
</body>
</html>
```

---

## 🆘 Troubleshooting

### Problème : "Connection timed out" en SSH

**Causes possibles** :
1. Security Group ne permet pas le SSH (port 22)
2. Mauvaise clé SSH
3. Instance éteinte

**Solutions** :
```bash
# 1. Vérifier le Security Group
Console EC2 → Instance → Security → Security groups
Vérifier : Inbound rules → SSH (22) depuis ton IP

# 2. Vérifier la clé
ls -l ~/.ssh/aws-keys/webapp-prod-keypair.pem
# Doit être : -r--------

# 3. Vérifier l'état de l'instance
Console EC2 → Instances → Instance state doit être "Running"
```

---

### Problème : "Permission denied (publickey)"

**Cause** : Mauvais utilisateur ou mauvaise clé

**Solution** :
```bash
# Amazon Linux 2023 : ec2-user
ssh -i ta-cle.pem ec2-user@IP

# Ubuntu : ubuntu
ssh -i ta-cle.pem ubuntu@IP

# Vérifier les permissions de la clé
chmod 400 ta-cle.pem
```

---

### Problème : La page web ne s'affiche pas

**Checklist** :
1. ✅ Instance en état "Running"
2. ✅ Apache démarré : `sudo systemctl status httpd`
3. ✅ Security Group autorise port 80
4. ✅ IP publique assignée à l'instance
5. ✅ Fichier `/var/www/html/index.html` existe

**Test rapide** :
```bash
# Depuis l'instance
curl http://localhost

# Si ça fonctionne localement mais pas depuis Internet :
# → Problème de Security Group
```

---

## ✅ Checklist de validation

Avant de passer à l'étape suivante :

- [ ] Instance EC2 créée et en état "Running"
- [ ] Connexion SSH fonctionnelle
- [ ] Apache installé et démarré
- [ ] Page web accessible depuis Internet
- [ ] IP publique notée quelque part
- [ ] Métadonnées EC2 affichées sur la page

---

## 🎯 Récapitulatif

Tu as maintenant :
- ✅ Une instance EC2 fonctionnelle
- ✅ Un serveur web Apache installé
- ✅ Une page web accessible publiquement
- ✅ Une connexion SSH configurée

---

## 🚀 Prochaine étape

**Direction [04_application_web.md](04_installation_application_web.md)** pour améliorer l'application web !

---
