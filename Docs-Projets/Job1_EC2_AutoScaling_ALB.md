# Job 1 : EC2 + Auto Scaling + Load Balancer 🚀

> Déployer une application web scalable avec haute disponibilité

---

## 🎯 Objectif

Déployer une application web sur EC2 Debian avec :
- Auto Scaling pour gérer la charge automatiquement
- Load Balancer pour distribuer le trafic
- HTTPS pour sécuriser les connexions (optionnel)

---

## 📦 Ressources AWS Utilisées

| Service | Rôle |
|---------|------|
| EC2 | Serveurs web |
| Launch Template | Modèle d'instance |
| Auto Scaling Group | Gestion automatique |
| Application Load Balancer | Répartition de charge |
| Security Groups | Pare-feu |
| SNS | Notifications (optionnel) |
| Certificate Manager | HTTPS (optionnel) |

---

## 💰 Coûts

| Service | Free Tier |
|---------|-----------|
| EC2 t2.micro | 750h/mois gratuit |
| ALB | 750h/mois gratuit |
| SNS | 1000 notifs gratuites |

⚠️ 2 instances t2.micro = 1500h/mois → dépasse le free tier (~15€/mois)

---

# Étape 1 : Créer une instance EC2 Debian

## 🖥️ Dashboard

```
1. EC2 → Instances → Launch instances

2. Name : webapp-prod-ec2

3. Application and OS Images :
   - Debian 12 (HVM) - 64-bit (x86)

4. Instance type : t2.micro (Free tier eligible)

5. Key pair : aws_arch (ou créer une nouvelle)

6. Network settings → Edit :
   - VPC : default
   - Subnet : No preference
   - Auto-assign public IP : Enable
   - Security group : Create security group
     - Name : webapp-sg
     - Inbound rules :
       • SSH (22) - Source : My IP
       • HTTP (80) - Source : Anywhere (0.0.0.0/0)
       • HTTPS (443) - Source : Anywhere (0.0.0.0/0)

7. Configure storage : 20 GiB gp3

8. Launch instance ✓
```

## 💻 CLI

```bash
# Créer le Security Group
aws ec2 create-security-group \
  --group-name webapp-sg \
  --description "Security group for web app" \
  --region eu-west-3

# Récupérer l'ID du Security Group
SG_ID=$(aws ec2 describe-security-groups \
  --group-names webapp-sg \
  --query 'SecurityGroups[0].GroupId' \
  --output text)

# Ajouter les règles
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp --port 22 --cidr $(curl -s ifconfig.me)/32

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp --port 80 --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp --port 443 --cidr 0.0.0.0/0

# Lancer l'instance
aws ec2 run-instances \
  --image-id ami-0xxx (ID AMI Debian 12) \
  --instance-type t2.micro \
  --key-name aws_arch \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=webapp-prod-ec2}]' \
  --region eu-west-3
```

---

# Étape 2 : Se connecter et installer l'application

## 🖥️ Connexion SSH

```bash
# Windows PowerShell
ssh -i "C:\aws-keys\aws_arch.pem" admin@<IP_PUBLIQUE>

# Linux/Mac
ssh -i ~/.ssh/aws_arch.pem admin@<IP_PUBLIQUE>
```

## 💻 Installation Nginx + PHP

```bash
# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Installer Nginx et PHP
sudo apt install -y nginx php-fpm php-common

# Démarrer et activer Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Démarrer PHP-FPM
sudo systemctl start php8.2-fpm
sudo systemctl enable php8.2-fpm
```

## 💻 Configurer Nginx pour PHP

```bash
# Éditer la configuration
sudo nano /etc/nginx/sites-available/default
```

Remplacez le contenu par :

```nginx
server {
    listen 80 default_server;
    root /var/www/html;
    index index.php index.html;

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
}
```

```bash
# Tester et redémarrer
sudo nginx -t
sudo systemctl restart nginx
```

## 💻 Créer la page d'accueil

```bash
sudo tee /var/www/html/index.php > /dev/null << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>AWS Auto Scaling</title>
    <style>
        body { 
            background: linear-gradient(135deg, #667eea, #764ba2); 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            min-height: 100vh; 
            font-family: Arial, sans-serif;
        }
        .container { 
            background: rgba(255,255,255,0.95); 
            border-radius: 20px; 
            padding: 50px; 
            max-width: 800px; 
        }
        .info-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); 
            gap: 20px; 
            margin: 30px 0; 
        }
        .info-card { 
            background: linear-gradient(135deg, #667eea, #764ba2); 
            padding: 20px; 
            border-radius: 10px; 
            color: white; 
        }
        .status { 
            text-align: center; 
            padding: 20px; 
            background: #4caf50; 
            color: white; 
            border-radius: 10px; 
            margin-top: 30px; 
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 AWS Auto Scaling Demo</h1>
        <div class="info-grid">
            <div class="info-card">
                <div><strong>Instance ID</strong></div>
                <div><?php echo @file_get_contents('http://169.254.169.254/latest/meta-data/instance-id') ?: 'N/A'; ?></div>
            </div>
            <div class="info-card">
                <div><strong>Availability Zone</strong></div>
                <div><?php echo @file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone') ?: 'N/A'; ?></div>
            </div>
            <div class="info-card">
                <div><strong>IP Privée</strong></div>
                <div><?php echo @file_get_contents('http://169.254.169.254/latest/meta-data/local-ipv4') ?: 'N/A'; ?></div>
            </div>
        </div>
        <div class="status">✅ Instance Debian opérationnelle</div>
    </div>
</body>
</html>
EOF

# Définir les permissions
sudo chown www-data:www-data /var/www/html/index.php
sudo chmod 644 /var/www/html/index.php
```

## ✅ Vérification

```bash
curl localhost
# Doit afficher la page HTML
```

---

# Étape 3 : Créer un Launch Template

## 🖥️ Dashboard

```
1. EC2 → Launch Templates → Create launch template

2. Launch template name : debian-nginx-template

3. Template version description : v1 - Nginx PHP app

4. Application and OS Images :
   - Debian 12

5. Instance type : t2.micro

6. Key pair : aws_arch

7. Network settings :
   - Security groups : webapp-sg

8. Advanced details → User data :
   (Coller le script ci-dessous)

9. Create launch template ✓
```

### Script User Data

```bash
#!/bin/bash
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "====================================="
echo "Début du script user-data (Debian)"
echo "Date: $(date)"
echo "====================================="

# Mise à jour et installation
sudo apt update && sudo apt upgrade -y
sudo apt install -y nginx php-fpm php-common

# Démarrer les services
sudo systemctl start nginx
sudo systemctl enable nginx
sudo systemctl start php8.2-fpm
sudo systemctl enable php8.2-fpm

# Configuration Nginx
sudo tee /etc/nginx/sites-available/default > /dev/null <<'EOFNGINX'
server {
    listen 80 default_server;
    root /var/www/html;
    index index.php index.html;
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
}
EOFNGINX

# Page d'accueil (même contenu que ci-dessus)
sudo tee /var/www/html/index.php > /dev/null << 'EOFHTML'
<!DOCTYPE html>
<html>
<head><title>AWS Auto Scaling</title>
<style>body{background:linear-gradient(135deg,#667eea,#764ba2);display:flex;align-items:center;justify-content:center;min-height:100vh;font-family:Arial;}.container{background:rgba(255,255,255,0.95);border-radius:20px;padding:50px;max-width:800px;}.info-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(250px,1fr));gap:20px;margin:30px 0;}.info-card{background:linear-gradient(135deg,#667eea,#764ba2);padding:20px;border-radius:10px;color:white;}.status{text-align:center;padding:20px;background:#4caf50;color:white;border-radius:10px;margin-top:30px;}</style>
</head>
<body>
<div class="container">
<h1>🚀 AWS Auto Scaling</h1>
<div class="info-grid">
<div class="info-card"><div>Instance ID</div><div><?php echo @file_get_contents('http://169.254.169.254/latest/meta-data/instance-id') ?: 'N/A'; ?></div></div>
<div class="info-card"><div>Availability Zone</div><div><?php echo @file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone') ?: 'N/A'; ?></div></div>
<div class="info-card"><div>IP Privée</div><div><?php echo @file_get_contents('http://169.254.169.254/latest/meta-data/local-ipv4') ?: 'N/A'; ?></div></div>
</div>
<div class="status">✅ Instance opérationnelle</div>
</div>
</body>
</html>
EOFHTML

sudo chown www-data:www-data /var/www/html/index.php
sudo chmod 644 /var/www/html/index.php
sudo systemctl restart nginx

echo "✅ Script user-data terminé avec succès"
```

⚠️ **Important** : Vérifiez que "User data has already been base64 encoded" est **DÉCOCHÉ** ☐

## 💻 CLI

```bash
# Encoder le user-data en base64
USER_DATA=$(base64 -w 0 user_data.sh)

# Créer le launch template
aws ec2 create-launch-template \
  --launch-template-name debian-nginx-template \
  --version-description "v1 - Nginx PHP app" \
  --launch-template-data '{
    "ImageId": "ami-0xxx",
    "InstanceType": "t2.micro",
    "KeyName": "aws_arch",
    "SecurityGroupIds": ["sg-xxx"],
    "UserData": "'$USER_DATA'"
  }' \
  --region eu-west-3
```

---

# Étape 4 : Créer l'Auto Scaling Group

## 🖥️ Dashboard

```
1. EC2 → Auto Scaling Groups → Create Auto Scaling group

2. Name : debian-asg

3. Launch template : debian-nginx-template

4. Next

5. Network :
   - VPC : default
   - Availability Zones : 
     ☑ eu-west-3a
     ☑ eu-west-3b
     ☑ eu-west-3c

6. Next (Load balancing - on configure après)

7. Group size :
   - Desired capacity : 2
   - Minimum capacity : 1
   - Maximum capacity : 4

8. Scaling policies : None (on ajoute après)

9. Notifications : Skip (on ajoute après)

10. Tags :
    - Key: Name, Value: webapp-asg-instance

11. Create Auto Scaling group ✓
```

## 💻 CLI

```bash
# Récupérer les subnets
SUBNETS=$(aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=vpc-xxx" \
  --query 'Subnets[*].SubnetId' \
  --output text | tr '\t' ',')

# Créer l'Auto Scaling Group
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name debian-asg \
  --launch-template LaunchTemplateName=debian-nginx-template,Version='$Latest' \
  --min-size 1 \
  --max-size 4 \
  --desired-capacity 2 \
  --vpc-zone-identifier "$SUBNETS" \
  --tags "Key=Name,Value=webapp-asg-instance,PropagateAtLaunch=true" \
  --region eu-west-3
```

---

# Étape 5 : Créer le Load Balancer

## 🖥️ Dashboard

### 5.1 Créer le Target Group

```
1. EC2 → Target Groups → Create target group

2. Target type : Instances

3. Target group name : debian-targets

4. Protocol : HTTP
   Port : 80

5. VPC : default

6. Health checks :
   - Protocol : HTTP
   - Path : /index.php
   - Healthy threshold : 2
   - Unhealthy threshold : 2
   - Timeout : 5
   - Interval : 30

7. Next

8. Ne pas enregistrer de targets (ASG le fera)

9. Create target group ✓
```

### 5.2 Créer l'Application Load Balancer

```
1. EC2 → Load Balancers → Create Load Balancer

2. Application Load Balancer → Create

3. Name : debian-alb

4. Scheme : Internet-facing

5. IP address type : IPv4

6. Network mapping :
   - VPC : default
   - Mappings : 
     ☑ eu-west-3a
     ☑ eu-west-3b
     ☑ eu-west-3c

7. Security groups : webapp-sg

8. Listeners :
   - HTTP : 80 → Forward to : debian-targets

9. Create load balancer ✓
```

### 5.3 Attacher l'ASG au Target Group

```
1. EC2 → Auto Scaling Groups → debian-asg

2. Onglet "Load balancing" → Edit

3. Application, Network or Gateway Load Balancer target groups :
   - ☑ Cocher
   - Sélectionner : debian-targets

4. Update ✓
```

## 💻 CLI

```bash
# Créer le Target Group
TG_ARN=$(aws elbv2 create-target-group \
  --name debian-targets \
  --protocol HTTP \
  --port 80 \
  --vpc-id vpc-xxx \
  --health-check-path /index.php \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text \
  --region eu-west-3)

# Créer le Load Balancer
ALB_ARN=$(aws elbv2 create-load-balancer \
  --name debian-alb \
  --subnets subnet-xxx subnet-yyy subnet-zzz \
  --security-groups sg-xxx \
  --scheme internet-facing \
  --type application \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text \
  --region eu-west-3)

# Créer le Listener
aws elbv2 create-listener \
  --load-balancer-arn $ALB_ARN \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=$TG_ARN \
  --region eu-west-3

# Attacher l'ASG au Target Group
aws autoscaling attach-load-balancer-target-groups \
  --auto-scaling-group-name debian-asg \
  --target-group-arns $TG_ARN \
  --region eu-west-3
```

---

# Étape 6 : Ajouter une Scaling Policy (Optionnel)

## 🖥️ Dashboard

```
1. EC2 → Auto Scaling Groups → debian-asg

2. Onglet "Automatic scaling" → Create dynamic scaling policy

3. Policy type : Target tracking scaling

4. Scaling policy name : cpu-target-70

5. Metric type : Average CPU utilization

6. Target value : 70

7. Create ✓
```

## 💻 CLI

```bash
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name debian-asg \
  --policy-name cpu-target-70 \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    },
    "TargetValue": 70.0
  }' \
  --region eu-west-3
```

---

# Étape 7 : Notifications SNS (Optionnel)

## 🖥️ Dashboard

```
1. SNS → Topics → Create topic
   - Type : Standard
   - Name : asg-notifications
   - Create topic ✓

2. SNS → Subscriptions → Create subscription
   - Topic ARN : arn:aws:sns:...:asg-notifications
   - Protocol : Email
   - Endpoint : votre-email@example.com
   - Create subscription ✓
   - ⚠️ Confirmez via l'email reçu !

3. EC2 → Auto Scaling Groups → debian-asg
   - Onglet "Activity" → Notifications → Create notification
   - SNS Topic : asg-notifications
   - Event types : ☑ Launch, ☑ Terminate
   - Create ✓
```

## 💻 CLI

```bash
# Créer le topic SNS
TOPIC_ARN=$(aws sns create-topic \
  --name asg-notifications \
  --query 'TopicArn' \
  --output text \
  --region eu-west-3)

# S'abonner par email
aws sns subscribe \
  --topic-arn $TOPIC_ARN \
  --protocol email \
  --notification-endpoint votre-email@example.com \
  --region eu-west-3

# Attacher les notifications à l'ASG
aws autoscaling put-notification-configuration \
  --auto-scaling-group-name debian-asg \
  --topic-arn $TOPIC_ARN \
  --notification-types \
    "autoscaling:EC2_INSTANCE_LAUNCH" \
    "autoscaling:EC2_INSTANCE_TERMINATE" \
  --region eu-west-3
```

---

# Étape 8 : Tester l'infrastructure

## ✅ Tests à effectuer

### 1. Vérifier le Load Balancer

```
1. EC2 → Load Balancers → debian-alb
2. Copier le "DNS name"
3. Ouvrir : http://<DNS_NAME>
4. Rafraîchir (F5) plusieurs fois
5. ✓ L'Instance ID doit changer = LB fonctionne !
```

### 2. Vérifier les Target Groups

```
1. EC2 → Target Groups → debian-targets
2. Onglet "Targets"
3. Toutes les instances doivent être "healthy"
```

### 3. Tester le scaling

```bash
# Augmenter la capacité manuellement
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name debian-asg \
  --desired-capacity 3 \
  --region eu-west-3

# Observer dans EC2 → Instances
# Une nouvelle instance doit apparaître
```

---

# Étape 9 : HTTPS (Optionnel)

## Générer un certificat auto-signé

```bash
# Sur une instance EC2
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/ssl/private/nginx-selfsigned.key \
  -out /etc/ssl/certs/nginx-selfsigned.crt
```

## Configurer Nginx pour HTTPS

```bash
sudo nano /etc/nginx/sites-available/default
```

```nginx
# Redirection HTTP → HTTPS
server {
    listen 80 default_server;
    return 301 https://$host$request_uri;
}

# HTTPS
server {
    listen 443 ssl http2 default_server;
    
    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    
    root /var/www/html;
    index index.php index.html;
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
}
```

```bash
sudo nginx -t
sudo systemctl restart nginx
```

---

# 🧹 Nettoyage

```bash
# 1. Supprimer l'Auto Scaling Group
aws autoscaling delete-auto-scaling-group \
  --auto-scaling-group-name debian-asg \
  --force-delete \
  --region eu-west-3

# 2. Supprimer le Launch Template
aws ec2 delete-launch-template \
  --launch-template-name debian-nginx-template \
  --region eu-west-3

# 3. Supprimer le Load Balancer
aws elbv2 delete-load-balancer \
  --load-balancer-arn $ALB_ARN \
  --region eu-west-3

# 4. Supprimer le Target Group
aws elbv2 delete-target-group \
  --target-group-arn $TG_ARN \
  --region eu-west-3

# 5. Supprimer le Security Group (après que les instances soient terminées)
aws ec2 delete-security-group \
  --group-id $SG_ID \
  --region eu-west-3
```

---

## ✅ Checklist Finale

- [ ] Instance EC2 créée et accessible
- [ ] Nginx + PHP installés
- [ ] Launch Template créé avec User Data
- [ ] Auto Scaling Group configuré (min 1, max 4)
- [ ] Load Balancer créé et fonctionnel
- [ ] Target Group healthy
- [ ] Scaling Policy configurée
- [ ] Notifications SNS (optionnel)
- [ ] HTTPS configuré (optionnel)

---

[⬅️ Retour : 02_guide_ssh.md](./02_guide_ssh.md) | [➡️ Suite : Job2_S3_CloudFront.md](./Job2_S3_CloudFront.md)
