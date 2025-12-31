# 02 - Guide Complet de Connexion SSH 🔐

> Se connecter à vos instances EC2 en toute sécurité

---

## 🎯 Qu'est-ce que SSH ?

**SSH (Secure Shell)** est un protocole cryptographique pour accéder à distance à vos serveurs EC2. Il permet de contrôler complètement votre instance via ligne de commande.

---

## 📋 Prérequis

- Fichier de clé `.pem` téléchargé
- Adresse IP publique de l'instance
- Port 22 ouvert dans le Security Group

---

## 🖥️ Windows (PowerShell)

### Étape 1 : Configurer les permissions de la clé

Ouvrez **PowerShell en Administrateur** :

```powershell
# Supprimer l'héritage des permissions
icacls "C:\aws-keys\aws_arch.pem" /inheritance:r

# Donner accès uniquement à votre utilisateur
icacls "C:\aws-keys\aws_arch.pem" /grant:r "$($env:USERNAME):(F)"
```

### Étape 2 : Se connecter

```powershell
# Connexion SSH (remplacez IP_PUBLIQUE)
ssh -i "C:\aws-keys\aws_arch.pem" admin@IP_PUBLIQUE

# Exemple concret
ssh -i "C:\aws-keys\aws_arch.pem" admin@54.123.45.67
```

### Utilisateurs par défaut selon l'OS

| AMI | Utilisateur |
|-----|-------------|
| **Debian** | `admin` |
| **Ubuntu** | `ubuntu` |
| **Amazon Linux** | `ec2-user` |
| **RHEL** | `ec2-user` |
| **CentOS** | `centos` |

---

## 🍎 Linux / Mac (Terminal)

### Étape 1 : Configurer les permissions

```bash
# Définir permissions restrictives (lecture seule pour le propriétaire)
chmod 400 ~/.ssh/aws_arch.pem
```

### Étape 2 : Se connecter

```bash
# Connexion SSH
ssh -i ~/.ssh/aws_arch.pem admin@IP_PUBLIQUE

# Exemple
ssh -i ~/.ssh/aws_arch.pem admin@54.123.45.67
```

---

## 🪟 Windows (PuTTY)

### Étape 1 : Convertir .pem en .ppk

```
1. Téléchargez PuTTY et PuTTYgen
   https://www.chiark.greenend.org.uk/~sgtatham/putty/

2. Ouvrez PuTTYgen
3. Load → Sélectionnez votre fichier .pem
4. Save private key → Enregistrez en .ppk
```

### Étape 2 : Configurer PuTTY

```
1. Ouvrez PuTTY
2. Session :
   - Host Name : IP_PUBLIQUE
   - Port : 22
3. Connection → SSH → Auth → Credentials :
   - Private key file : Sélectionnez le .ppk
4. Connection → Data :
   - Auto-login username : admin (ou ubuntu/ec2-user)
5. Session → Save (pour réutiliser)
6. Open
```

---

## 📤 Transférer des fichiers avec SCP

### Upload (local → serveur)

```bash
# Un fichier
scp -i aws_arch.pem mon-fichier.txt admin@IP:/home/admin/

# Un dossier entier
scp -i aws_arch.pem -r mon-dossier/ admin@IP:/home/admin/
```

### Download (serveur → local)

```bash
# Un fichier
scp -i aws_arch.pem admin@IP:/home/admin/fichier.txt .

# Un dossier entier
scp -i aws_arch.pem -r admin@IP:/home/admin/dossier/ .
```

### Windows PowerShell

```powershell
# Upload
scp -i "C:\aws-keys\aws_arch.pem" C:\Users\Tom\fichier.txt admin@IP:/home/admin/

# Download
scp -i "C:\aws-keys\aws_arch.pem" admin@IP:/home/admin/fichier.txt C:\Users\Tom\
```

---

## 🔧 Commandes utiles une fois connecté

### Système

```bash
# Mettre à jour les paquets
sudo apt update && sudo apt upgrade -y

# Voir l'espace disque
df -h

# Voir la RAM
free -h

# Voir les processus
top
htop  # (si installé)

# Voir les logs système
sudo tail -f /var/log/syslog
```

### Réseau

```bash
# Voir l'IP
ip addr show
curl ifconfig.me  # IP publique

# Tester la connectivité
ping -c 4 google.com

# Voir les ports ouverts
sudo netstat -tuln
sudo ss -tuln
```

### Services

```bash
# Status d'un service
sudo systemctl status nginx

# Démarrer/Arrêter/Redémarrer
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx

# Activer au démarrage
sudo systemctl enable nginx
```

---

## ❌ Dépannage

### Erreur : "Permission denied (publickey)"

**Causes :**
- Mauvaises permissions sur le fichier .pem
- Mauvais utilisateur
- Mauvaise clé

**Solutions :**
```bash
# Vérifier les permissions
ls -la aws_arch.pem
# Doit être : -r-------- (400)

# Corriger
chmod 400 aws_arch.pem

# Essayer un autre utilisateur
ssh -i aws_arch.pem ubuntu@IP
ssh -i aws_arch.pem ec2-user@IP
```

### Erreur : "Connection timed out"

**Causes :**
- Port 22 bloqué dans le Security Group
- Instance éteinte
- Mauvaise IP

**Solutions :**
```
1. Vérifier que l'instance est "running"
2. EC2 → Instance → Security → Security Groups
3. Vérifier : Inbound rules → SSH (22) autorisé
4. Source : Votre IP ou 0.0.0.0/0 (moins sécurisé)
```

### Erreur : "Host key verification failed"

**Solution :**
```bash
# Supprimer l'ancienne clé
ssh-keygen -R IP_PUBLIQUE

# Ou accepter la nouvelle clé
# Tapez "yes" quand demandé
```

### Erreur : "Connection refused"

**Causes :**
- SSH pas installé/démarré sur l'instance
- Mauvais port

**Solution :**
```bash
# Vérifier que SSH tourne (depuis la console AWS - EC2 Instance Connect)
sudo systemctl status sshd
sudo systemctl start sshd
```

---

## 🔒 Bonnes pratiques SSH

1. **Ne jamais partager** votre fichier .pem
2. **Restreindre le port 22** à votre IP uniquement
3. **Désactiver** le login root : `PermitRootLogin no`
4. **Utiliser des clés** plutôt que des mots de passe
5. **Changer le port SSH** (optionnel) : port 2222 au lieu de 22

---

## 📝 Aide-mémoire

```bash
# Connexion rapide
ssh -i KEY.pem USER@IP

# Avec verbose (debug)
ssh -v -i KEY.pem USER@IP

# Tunnel SSH (forward port local)
ssh -i KEY.pem -L 8080:localhost:80 USER@IP

# Exécuter une commande sans rester connecté
ssh -i KEY.pem USER@IP "commande"
```

---

[⬅️ Retour : 01_preparation.md](./01_preparation.md) | [➡️ Suite : Job1_EC2_AutoScaling_ALB.md](./Job1_EC2_AutoScaling_ALB.md)
