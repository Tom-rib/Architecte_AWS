# Installer l'App - Nginx + PHP 📦

Installer un serveur web avec PHP sur votre instance.

---

## 🎯 À quoi ça sert ?

Page dynamique affichant les infos de l'instance (ID, zone, IP).

---

## 🖼️ DASHBOARD AWS

Rien à faire ici, tout en SSH.

---

## 💻 CLI - SSH

### 1. Mettre à jour le système

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Installer Nginx et PHP

```bash
sudo apt install -y nginx php-fpm php-common
```

### 3. Créer la page d'accueil

```bash
sudo tee /var/www/html/index.php > /dev/null << 'EOFPHP'
<!DOCTYPE html>
<html>
<head>
    <title>AWS Auto Scaling</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; }
        .info { background: #f0f0f0; padding: 20px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <h1>🚀 Instance EC2 Opérationnelle</h1>
    <div class="info">
        <p><strong>Instance ID :</strong> <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/instance-id'); ?></p>
        <p><strong>Availability Zone :</strong> <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone'); ?></p>
        <p><strong>Private IP :</strong> <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/local-ipv4'); ?></p>
        <p><strong>Instance Type :</strong> <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/instance-type'); ?></p>
    </div>
    <p>✅ Nginx + PHP en cours d'exécution</p>
</body>
</html>
EOFPHP
```

### 4. Fixer les permissions

```bash
sudo chown www-data:www-data /var/www/html/index.php
sudo systemctl restart nginx
```

### 5. Vérifier

```bash
curl localhost
# Doit afficher le HTML
```

---

## 🧪 TESTER

Depuis votre PC, ouvrez le navigateur :

```
http://54.123.45.67
```

Vous devez voir :
```
🚀 Instance EC2 Opérationnelle

Instance ID : i-0123456789abcdef0
Availability Zone : eu-west-3a
Private IP : 10.0.1.5
Instance Type : t2.micro

✅ Nginx + PHP en cours d'exécution
```

---

## 💡 NOTES

- **Métadonnées AWS** : `http://169.254.169.254/...` (endpoint spécial, accessible uniquement depuis l'instance)
- **www-data** : utilisateur Nginx/PHP (permissions)
- **index.php** : première page affichée automatiquement

---

[⬅️ Retour](./README.md)
