# Launch Template - Modèle d'Instance ⚙️

Configuration réutilisable pour créer des instances identiques automatiquement.

---

## 🎯 À quoi ça sert ?

- Auto Scaling : crée des instances sans intervention manuelle
- Cohérence : toutes les instances identiques
- Rapidité : créer 100 instances identiques en 1 clic
- User Data : script auto-exécuté au lancement

---

## 🖼️ DASHBOARD AWS

### Créer un Launch Template

```
1. EC2 > Launch Templates > Create launch template
2. Name : debian-nginx-template
3. Description : Debian with Nginx PHP for Auto Scaling
```

### Étape 1 : AMI

```
- AMI : Debian 12
```

### Étape 2 : Instance type

```
- Instance type : t2.micro
```

### Étape 3 : Key pair

```
- Key pair : aws_arch
```

### Étape 4 : Security group

```
- Security group : sélectionnez celui de votre instance (port 22, 80, 443)
```

### Étape 5 : Storage

```
- Size : 20 GB
- Type : gp3
- Encryption : enabled
- Delete on termination : checked
```

### Étape 6 : Advanced (User Data)

```
⚠️ TRÈS IMPORTANT

Cliquez "Advanced details"
Section "User data" :
Colez ce script :

#!/bin/bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y nginx php-fpm php-common
sudo systemctl start nginx
sudo systemctl enable nginx
sudo tee /var/www/html/index.php > /dev/null << 'EOFPHP'
<!DOCTYPE html>
<html>
<head><title>AWS Auto Scaling</title></head>
<body style="text-align:center; padding:50px;">
  <h1>Instance <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/instance-id'); ?></h1>
  <p>Zone: <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone'); ?></p>
  <p>IP: <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/local-ipv4'); ?></p>
  <p>✅ Auto lancée!</p>
</body>
</html>
EOFPHP
sudo chown www-data:www-data /var/www/html/index.php
sudo systemctl restart nginx

⚠️ Si vu un message : "User data has already been base64 encoded"
→ DÉCOCHEZ la case
```

### Créer

```
Cliquez "Create launch template" ✓
```

### Voir vos templates

```
EC2 > Launch Templates
- Sélectionnez votre template
- Voir les versions, détails
```

---

## 💻 CLI

### Créer un Launch Template

```bash
aws ec2 create-launch-template \
  --launch-template-name debian-nginx-template \
  --version-description "Debian with Nginx PHP" \
  --launch-template-data '{
    "ImageId": "ami-0a1b2c3d4e5f6g7h8",
    "InstanceType": "t2.micro",
    "KeyName": "aws_arch",
    "SecurityGroupIds": ["sg-0123456789abcdef0"],
    "BlockDeviceMappings": [{
      "DeviceName": "/dev/xvda",
      "Ebs": {"VolumeSize": 20, "VolumeType": "gp3"}
    }],
    "UserData": "IyEvYmluL2Jhc2gK..."
  }'
```

### Lister les Launch Templates

```bash
aws ec2 describe-launch-templates
```

### Voir les versions d'un template

```bash
aws ec2 describe-launch-template-versions \
  --launch-template-name debian-nginx-template
```

### Créer instance depuis template

```bash
aws ec2 run-instances \
  --launch-template LaunchTemplateName=debian-nginx-template,Version='$Latest'
```

---

## 📌 NOTES

- **User Data** : exécuté UNE FOIS au lancement (toujours root)
- **Versions** : Launch Templates sont versionnées, versions antérieures conservées
- **Modification** : créer nouvelle version (ne modifiez pas l'ancienne)
- **Cas d'usage** : OBLIGATOIRE pour Auto Scaling

---

[⬅️ Retour](./README.md)
