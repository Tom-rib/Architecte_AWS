# 🌐 04. Installation de l'Application Web

> **Objectif** : Finaliser l'application web et créer une AMI pour l'Auto Scaling.  
> **Durée** : 30 minutes  
> **Niveau** : ⭐ Débutant

---

## 🎯 Ce que tu vas faire

Dans cette étape :
- ✅ Vérifier l'installation d'Apache
- ✅ Améliorer la page web
- ✅ Tester l'application
- ✅ Créer une AMI (Amazon Machine Image) pour le scaling

---

## ✅ Étape 1 : Vérifier Apache

### 1.1. Se connecter à l'instance

```bash
ssh -i ~/.ssh/aws-keys/webapp-prod-keypair.pem ec2-user@IP-PUBLIQUE
```

### 1.2. Vérifier le statut

```bash
# Vérifier qu'Apache tourne
sudo systemctl status httpd

# Doit afficher : Active: active (running)
```

### 1.3. Vérifier la configuration

```bash
# Version d'Apache
httpd -v

# Tester la configuration
sudo httpd -t

# Doit afficher : Syntax OK
```

---

## 🎨 Étape 2 : Améliorer la page web

### 2.1. Page web dynamique

Créons une page qui affiche les informations de l'instance en temps réel :

```bash
# Créer un nouveau fichier index.html
sudo nano /var/www/html/index.html
```

Copie ce code HTML amélioré :

```html
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Projet AWS - EC2 Auto Scaling</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            padding: 50px;
            max-width: 800px;
            width: 100%;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }
        
        h1 {
            color: #667eea;
            font-size: 2.5em;
            margin-bottom: 10px;
            text-align: center;
        }
        
        h2 {
            color: #764ba2;
            font-size: 1.5em;
            margin-bottom: 30px;
            text-align: center;
            font-weight: 300;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        
        .info-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 20px;
            border-radius: 10px;
            color: white;
        }
        
        .info-label {
            font-size: 0.9em;
            opacity: 0.9;
            margin-bottom: 5px;
        }
        
        .info-value {
            font-size: 1.3em;
            font-weight: bold;
            word-break: break-all;
        }
        
        .status {
            text-align: center;
            padding: 20px;
            background: #4caf50;
            color: white;
            border-radius: 10px;
            font-size: 1.2em;
            margin-top: 30px;
        }
        
        .footer {
            text-align: center;
            margin-top: 30px;
            color: #666;
            font-size: 0.9em;
        }
        
        .timestamp {
            text-align: center;
            margin-top: 20px;
            color: #999;
            font-size: 0.85em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Projet AWS</h1>
        <h2>Application Web avec Auto Scaling & Load Balancer</h2>
        
        <div class="info-grid">
            <div class="info-card">
                <div class="info-label">Instance ID</div>
                <div class="info-value">
                    <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/instance-id'); ?>
                </div>
            </div>
            
            <div class="info-card">
                <div class="info-label">Availability Zone</div>
                <div class="info-value">
                    <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone'); ?>
                </div>
            </div>
            
            <div class="info-card">
                <div class="info-label">IP Privée</div>
                <div class="info-value">
                    <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/local-ipv4'); ?>
                </div>
            </div>
            
            <div class="info-card">
                <div class="info-label">IP Publique</div>
                <div class="info-value">
                    <?php echo @file_get_contents('http://169.254.169.254/latest/meta-data/public-ipv4'); ?>
                </div>
            </div>
        </div>
        
        <div class="status">
            ✅ Serveur opérationnel
        </div>
        
        <div class="timestamp">
            Dernière mise à jour : <?php echo date('d/m/Y H:i:s'); ?>
        </div>
        
        <div class="footer">
            Projet AWS - Administration Systèmes et Réseaux
        </div>
    </div>
</body>
</html>
```

⚠️ **Attention** : Ce fichier nécessite PHP ! Installons-le.

### 2.2. Installer PHP

```bash
# Installer PHP
sudo yum install -y php php-common php-cli

# Redémarrer Apache
sudo systemctl restart httpd

# Renommer le fichier en .php
sudo mv /var/www/html/index.html /var/www/html/index.php

# Permissions
sudo chown apache:apache /var/www/html/index.php
sudo chmod 644 /var/www/html/index.php
```

### 2.3. Configurer Apache pour PHP

```bash
# Éditer la configuration Apache
sudo nano /etc/httpd/conf/httpd.conf

# Trouve cette ligne (Ctrl+W pour chercher) :
DirectoryIndex index.html

# Remplace par :
DirectoryIndex index.php index.html
```

Sauvegarde (`Ctrl+O`, `Enter`, `Ctrl+X`)

```bash
# Redémarrer Apache
sudo systemctl restart httpd
```

---

## 🧪 Étape 3 : Tester l'application

### 3.1. Test local

```bash
# Depuis l'instance EC2
curl http://localhost

# Tu devrais voir le code HTML avec les infos
```

### 3.2. Test depuis le navigateur

1. Ouvre ton navigateur
2. Va sur `http://IP-PUBLIQUE`
3. ✅ Tu devrais voir la belle page avec :
   - Instance ID
   - Availability Zone
   - IP privée
   - IP publique
   - Statut opérationnel
   - Timestamp

### 3.3. Vérifier les métadonnées

Si les métadonnées ne s'affichent pas :

```bash
# Tester manuellement
curl http://169.254.169.254/latest/meta-data/instance-id
curl http://169.254.169.254/latest/meta-data/placement/availability-zone
curl http://169.254.169.254/latest/meta-data/local-ipv4
```

---

## 📸 Étape 4 : Créer une AMI

### 4.1. Pourquoi créer une AMI ?

Une **AMI (Amazon Machine Image)** est une image de ton instance. Elle contient :
- Le système d'exploitation
- Apache déjà installé et configuré
- Ton application web
- Toutes les configurations

✅ L'Auto Scaling utilisera cette AMI pour créer de nouvelles instances identiques !

### 4.2. Créer l'AMI

1. Console EC2 → **"Instances"**
2. Sélectionne ton instance `webapp-prod-ec2-web-01`
3. **Actions** → **Image and templates** → **Create image**

**Configuration :**

```yaml
Image name: webapp-prod-ami
Image description: AMI for web application with Apache and PHP
Reboot instance: No reboot (laisse décoché pour éviter l'arrêt)
```

4. Clique sur **"Create image"**
5. ⏱️ Attends 3-5 minutes

### 4.3. Vérifier l'AMI

1. Menu gauche → **"Images"** → **"AMIs"**
2. Trouve ton AMI : `webapp-prod-ami`
3. Attends que le **Status** passe à `Available` ✅

---

## 📋 Étape 5 : Script d'installation complet

Pour référence, voici le script complet d'installation :

```bash
#!/bin/bash
# Script d'installation automatique
# À utiliser dans le User Data EC2

# Mise à jour
yum update -y

# Installation d'Apache et PHP
yum install -y httpd php php-common php-cli

# Démarrage d'Apache
systemctl start httpd
systemctl enable httpd

# Création de la page web
cat > /var/www/html/index.php << 'EOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Projet AWS</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 50px;
            color: white;
        }
        .container {
            background: rgba(255,255,255,0.95);
            padding: 40px;
            border-radius: 10px;
            max-width: 800px;
            margin: auto;
            color: #333;
        }
        h1 { color: #667eea; text-align: center; }
        .info { background: #f5f5f5; padding: 15px; margin: 10px 0; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Application AWS</h1>
        <div class="info">
            <strong>Instance:</strong> <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/instance-id'); ?>
        </div>
        <div class="info">
            <strong>Zone:</strong> <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone'); ?>
        </div>
        <div class="info">
            <strong>IP Privée:</strong> <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/local-ipv4'); ?>
        </div>
    </div>
</body>
</html>
EOF

# Permissions
chown apache:apache /var/www/html/index.php
chmod 644 /var/www/html/index.php

# Redémarrer Apache
systemctl restart httpd
```

---

## 📊 Commandes de diagnostic

### Vérifier les logs

```bash
# Logs d'accès Apache
sudo tail -f /var/log/httpd/access_log

# Logs d'erreurs Apache
sudo tail -f /var/log/httpd/error_log

# Logs d'erreurs PHP
sudo tail -f /var/log/php-fpm/www-error.log
```

### Vérifier Apache et PHP

```bash
# Version d'Apache
httpd -v

# Version de PHP
php -v

# Modules Apache chargés
httpd -M | grep php

# Test de la config Apache
sudo httpd -t
```

### Vérifier les fichiers

```bash
# Lister les fichiers web
ls -lah /var/www/html/

# Voir le contenu
cat /var/www/html/index.php

# Vérifier les permissions
stat /var/www/html/index.php
```

---

## 🆘 Troubleshooting

### Problème : Page blanche ou erreur 500

**Cause** : Erreur PHP ou permissions

**Solution** :
```bash
# Vérifier les logs d'erreurs
sudo tail -50 /var/log/httpd/error_log

# Vérifier la syntaxe PHP
php -l /var/www/html/index.php

# Corriger les permissions
sudo chown -R apache:apache /var/www/html/
sudo chmod 755 /var/www/html/
sudo chmod 644 /var/www/html/index.php
```

---

### Problème : Métadonnées ne s'affichent pas

**Cause** : Service de métadonnées inaccessible ou PHP mal configuré

**Solution** :
```bash
# Tester les métadonnées manuellement
curl http://169.254.169.254/latest/meta-data/instance-id

# Si ça fonctionne, problème PHP :
php -r "echo file_get_contents('http://169.254.169.254/latest/meta-data/instance-id');"

# Vérifier allow_url_fopen
php -i | grep allow_url_fopen
# Doit être : allow_url_fopen => On
```

---

### Problème : AMI reste en "pending"

**Cause** : Création en cours

**Solution** :
- Attends 5-10 minutes
- Rafraîchis la page
- Si ça dépasse 15 minutes, supprime et recrée l'AMI

---

## ✅ Checklist de validation

- [ ] Apache et PHP installés et fonctionnels
- [ ] Page web affiche les informations d'instance
- [ ] Page accessible depuis Internet
- [ ] AMI créée avec statut "Available"
- [ ] Tests de la page réussis

---

## 🎯 Récapitulatif

Tu as maintenant :
- ✅ Une application web complète avec Apache et PHP
- ✅ Une page dynamique affichant les métadonnées EC2
- ✅ Une AMI prête pour l'Auto Scaling

---

## 🚀 Prochaine étape

**Direction [05_load_balancer.md](05_configuration_load_balancer.md)** pour créer le Load Balancer !

---

**💡 Astuce** : Cette AMI va servir de modèle pour toutes les instances créées par l'Auto Scaling. Assure-toi qu'elle fonctionne parfaitement !