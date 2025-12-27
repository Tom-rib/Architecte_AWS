# SSH - Protocole de Connexion Sécurisée 🔓

SSH (Secure Shell) = connexion cryptographique à votre serveur EC2. Contrôle total via terminal.

---

## 🎯 À quoi ça sert ?

- Accéder à votre instance en ligne de commande
- Installer/configurer logiciels
- Exécuter des commandes
- Transférer des fichiers (SCP)

---

## 📊 Comparaison : Connexion locale vs SSH

| | SSH | EC2 Instance Connect | PuTTY |
|---|---|---|---|
| **Outil** | Terminal natif | Navigateur AWS | Client SSH GUI |
| **Setup** | 2 commandes | 0 (dans la console) | Télécharger + setup |
| **Facilité** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Cas d'usage** | Production | Quick test | Windows |
| **Clé requise** | Oui | Non | Oui |

---

## 🖼️ DASHBOARD AWS

### Étape 1 : Créer une paire de clés (lors du lancement)

```
1. EC2 > Launch instance
2. Étape 'Key pair'
3. Cliquez "Create new key pair"
4. Name : aws_arch
5. Format : RSA (pour Linux/Mac/PowerShell)
6. Create key pair ✓
7. Fichier .pem téléchargé automatiquement
8. ⚠️ CONSERVEZ-LE EN LIEU SÛR !
```

### Étape 2 : Récupérer l'adresse IP publique

```
1. EC2 > Instances
2. Sélectionnez votre instance
3. Notez :
   - Public IPv4 : 54.123.45.67
   - IPv4 DNS : ec2-54-123-45-67.eu-west-3.compute.amazonaws.com
```

### Étape 3 : Utiliser EC2 Instance Connect (rapide)

```
1. Instances > Sélectionnez
2. Bouton "Connect" en haut
3. Onglet "EC2 Instance Connect"
4. Cliquez "Connect"
5. Terminal s'ouvre ! ✓
(Aucune clé requise, mais limité à 1 heure)
```

---

## 💻 CLI - Windows PowerShell (ADMIN)

### Étape 1 : Préparer le fichier .pem (UNE FOIS)

```powershell
# Fixer les permissions
icacls "C:\aws-keys\aws_arch.pem" /inheritance:r
icacls "C:\aws-keys\aws_arch.pem" /grant:r "$($env:USERNAME):(F)"

# Vérifier
icacls "C:\aws-keys\aws_arch.pem"
# Retour : ...F (full permissions pour vous seul)
```

### Étape 2 : Se connecter

```powershell
# Debian (user = admin)
ssh -i "C:\aws-keys\aws_arch.pem" admin@54.123.45.67

# Ubuntu (user = ubuntu)
ssh -i "C:\aws-keys\aws_arch.pem" ubuntu@54.123.45.67

# Via DNS (identique)
ssh -i "C:\aws-keys\aws_arch.pem" admin@ec2-54-123-45-67.eu-west-3.compute.amazonaws.com
```

### Étape 3 : Accepter la clé d'hôte (1ère fois)

```
The authenticity of host '54.123.45.67' can't be established.
RSA key fingerprint is SHA256:...
Are you sure you want to continue connecting (yes/no/[fingerprint])?

Tapez : yes
Entrée ✓
```

Vous êtes connecté ! 🎉

```
admin@ip-172-31-33-216:~$
```

---

## 💻 CLI - Linux/Mac (Terminal)

### Étape 1 : Fixer les permissions

```bash
chmod 400 ~/aws_arch.pem
```

### Étape 2 : Se connecter

```bash
ssh -i ~/aws_arch.pem admin@54.123.45.67
```

---

## 💻 CLI - Windows PuTTY (Alternative)

### Étape 1 : Convertir .pem en .ppk

```
1. Téléchargez PuTTYgen
2. File > Load private key > aws_arch.pem
3. Conversions > Export OpenSSH key
4. Sauvegardez en .ppk
```

### Étape 2 : Configurer PuTTY

```
1. PuTTY > Session
2. Host Name : 54.123.45.67
3. Connection > SSH > Auth
4. Private key file : sélectionnez .ppk
5. Open ✓
```

---

## 📤 Transférer des fichiers avec SCP

### Uploader un fichier

```powershell
scp -i "C:\aws-keys\aws_arch.pem" "C:\mon-fichier.txt" admin@54.123.45.67:/home/admin/
```

### Télécharger un fichier

```powershell
scp -i "C:\aws-keys\aws_arch.pem" admin@54.123.45.67:/home/admin/fichier.txt "C:\Users\Tom\"
```

---

## 🔧 COMMANDES UTILES (une fois connecté)

### Vérification système

```bash
# Utilisateur courant
whoami
# Retour : admin

# IP privée
hostname -I
# Retour : 10.0.1.5

# OS
cat /etc/os-release
# Retour : Debian GNU/Linux 12

# Espace disque
df -h
# Retour : /dev/xvda1  20G  2.5G  17.5G

# RAM et CPU
free -h
# Retour : Mem: 1.0Gi  150Mi  850Mi

# Processus (appuyez 'q' pour quitter)
top

# Version Nginx
nginx -v

# Fichiers dans le répertoire courant
ls -la
```

### Maintenance

```bash
# Mettre à jour les paquets
sudo apt update && sudo apt upgrade -y

# Voir les logs système
sudo tail -f /var/log/syslog

# Redémarrer l'instance
sudo reboot

# Arrêter l'instance
sudo shutdown -h now

# Quitter SSH
exit
```

---

## 🔴 DÉPANNAGE

### "Permission denied (publickey)"

```
❌ Cause : permissions du .pem mauvaises
✅ Solution :
icacls "C:\aws-keys\aws_arch.pem" /inheritance:r
icacls "C:\aws-keys\aws_arch.pem" /grant:r "$($env:USERNAME):(F)"
```

### "Connection timed out"

```
❌ Cause : Security Group port 22 fermé, instance arrêtée, ou IP fausse
✅ Solutions :
1. Vérifiez EC2 > Instances > Status = "Running"
2. Vérifiez la Public IPv4 correcte
3. Vérifiez Security Group :
   EC2 > Security Groups > Port 22 (SSH) autorisé
```

### "Host key verification failed"

```
❌ Cause : clé d'hôte non acceptée
✅ Solution :
Tapez 'yes' à la première connexion
```

### "The .pem file is not recognized"

```
❌ Cause : chemin faux ou fichier endommagé
✅ Solution :
1. Vérifiez le chemin exact : C:\aws-keys\aws_arch.pem
2. Téléchargez la clé à nouveau depuis AWS
```

### "ssh: command not found" (Windows ancien)

```
❌ Cause : SSH non disponible
✅ Solutions :
1. Utilisez PowerShell (built-in depuis Windows 10)
2. Installez Git Bash
3. Utilisez PuTTY
```

---

## 📌 NOTES IMPORTANTES

- **User par défaut Debian** : `admin`
- **User par défaut Ubuntu** : `ubuntu`
- **User par défaut Amazon Linux** : `ec2-user`
- **Ne partagez JAMAIS le .pem** : c'est l'accès root à votre serveur
- **Gardez le .pem safe** : perte = impossible de se reconnecter
- **Permissions obligatoires** : chmod 400 (Linux/Mac) ou icacls (Windows)
- **Instance Connect** : temporaire (1h max), pratique pour test rapide
- **SSH** : permanent, à privilégier pour production

---

[⬅️ Retour](./README.md)
