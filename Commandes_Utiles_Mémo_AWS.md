# 📝 Commandes Utiles - Mémo AWS

> **Objectif** : Référence rapide des commandes AWS CLI et Linux les plus utiles.

---

## 🖥️ Commandes AWS CLI

### Configuration

```bash
# Configurer AWS CLI
aws configure

# Afficher la configuration actuelle
aws configure list

# Tester la connexion
aws sts get-caller-identity

# Changer de région par défaut
aws configure set region eu-west-3
```

---

### EC2 - Instances

```bash
# Lister toutes les instances
aws ec2 describe-instances --region eu-west-3

# Lister uniquement les instances en cours
aws ec2 describe-instances --region eu-west-3 \
  --filters "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name,PublicIpAddress]' \
  --output table

# Lister par tag
aws ec2 describe-instances --region eu-west-3 \
  --filters "Name=tag:Project,Values=webapp-aws"

# Démarrer une instance
aws ec2 start-instances --instance-ids i-xxxxxxxxx

# Arrêter une instance
aws ec2 stop-instances --instance-ids i-xxxxxxxxx

# Terminer une instance
aws ec2 terminate-instances --instance-ids i-xxxxxxxxx

# Obtenir l'IP publique
aws ec2 describe-instances --instance-ids i-xxxxxxxxx \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text
```

---

### Load Balancer

```bash
# Lister les Load Balancers
aws elbv2 describe-load-balancers --region eu-west-3

# Détails d'un Load Balancer
aws elbv2 describe-load-balancers \
  --names webapp-prod-alb \
  --region eu-west-3

# Lister les Target Groups
aws elbv2 describe-target-groups --region eu-west-3

# Voir l'état des targets
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:... \
  --region eu-west-3
```

---

### Auto Scaling

```bash
# Lister les Auto Scaling Groups
aws autoscaling describe-auto-scaling-groups --region eu-west-3

# Détails d'un ASG
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names webapp-prod-asg \
  --region eu-west-3

# Changer la capacité désirée
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name webapp-prod-asg \
  --desired-capacity 4 \
  --region eu-west-3

# Voir l'historique des scaling activities
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name webapp-prod-asg \
  --max-records 10 \
  --region eu-west-3

# Suspendre le scaling
aws autoscaling suspend-processes \
  --auto-scaling-group-name webapp-prod-asg \
  --region eu-west-3

# Reprendre le scaling
aws autoscaling resume-processes \
  --auto-scaling-group-name webapp-prod-asg \
  --region eu-west-3
```

---

### VPC et Réseau

```bash
# Lister les VPCs
aws ec2 describe-vpcs --region eu-west-3

# Lister les Subnets
aws ec2 describe-subnets --region eu-west-3 \
  --filters "Name=vpc-id,Values=vpc-xxxxx"

# Lister les Security Groups
aws ec2 describe-security-groups --region eu-west-3

# Lister les Internet Gateways
aws ec2 describe-internet-gateways --region eu-west-3
```

---

### AMI et Snapshots

```bash
# Lister mes AMIs
aws ec2 describe-images --owners self --region eu-west-3

# Lister mes Snapshots
aws ec2 describe-snapshots --owner-ids self --region eu-west-3

# Créer une AMI depuis une instance
aws ec2 create-image \
  --instance-id i-xxxxxxxxx \
  --name "webapp-backup-$(date +%Y%m%d)" \
  --region eu-west-3

# Supprimer une AMI
aws ec2 deregister-image --image-id ami-xxxxxxxxx --region eu-west-3

# Supprimer un Snapshot
aws ec2 delete-snapshot --snapshot-id snap-xxxxxxxxx --region eu-west-3
```

---

### CloudWatch

```bash
# Lister les alarmes
aws cloudwatch describe-alarms --region eu-west-3

# Voir les métriques d'une instance
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=i-xxxxxxxxx \
  --start-time 2025-11-12T00:00:00Z \
  --end-time 2025-11-12T23:59:59Z \
  --period 3600 \
  --statistics Average \
  --region eu-west-3

# Créer une alarme
aws cloudwatch put-metric-alarm \
  --alarm-name high-cpu \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 2 \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --period 60 \
  --statistic Average \
  --threshold 70 \
  --region eu-west-3
```

---

## 🐧 Commandes Linux (sur les instances EC2)

### Gestion des services

```bash
# Apache
sudo systemctl start httpd      # Démarrer
sudo systemctl stop httpd       # Arrêter
sudo systemctl restart httpd    # Redémarrer
sudo systemctl status httpd     # Vérifier l'état
sudo systemctl enable httpd     # Activer au démarrage
sudo systemctl disable httpd    # Désactiver au démarrage

# Vérifier les logs d'Apache
sudo tail -f /var/log/httpd/access_log
sudo tail -f /var/log/httpd/error_log

# Tester la configuration Apache
sudo httpd -t

# Recharger la config sans redémarrage
sudo systemctl reload httpd
```

---

### Surveillance système

```bash
# Utilisation CPU/RAM
top                    # Interactif
htop                   # Plus visuel (si installé)
free -h               # Mémoire
uptime                # Charge système

# Processus
ps aux                # Tous les processus
ps aux | grep httpd   # Processus Apache

# Espace disque
df -h                 # Disques montés
du -sh /var/www/html  # Taille d'un dossier

# Réseau
netstat -tuln         # Ports en écoute
ss -tuln              # Alternative moderne
lsof -i :80          # Qui utilise le port 80
curl http://localhost # Tester localement
```

---

### Gestion des fichiers

```bash
# Navigation
cd /var/www/html      # Aller dans le dossier web
pwd                   # Afficher le chemin actuel
ls -lah               # Lister avec détails

# Édition
sudo nano /var/www/html/index.php   # Éditeur simple
sudo vim /var/www/html/index.php    # Éditeur avancé

# Permissions
sudo chown apache:apache /var/www/html/index.php
sudo chmod 644 /var/www/html/index.php
sudo chmod -R 755 /var/www/html/

# Copie et déplacement
sudo cp index.php index.php.bak
sudo mv index.php.old /tmp/
```

---

### Logs et diagnostic

```bash
# Logs système
sudo journalctl -u httpd -f       # Logs Apache en temps réel
sudo journalctl --since "1 hour ago"

# Logs cloud-init (démarrage)
sudo cat /var/log/cloud-init.log
sudo cat /var/log/cloud-init-output.log

# Historique des commandes
history
history | grep ssh
```

---

### Métadonnées EC2

```bash
# Récupérer les métadonnées de l'instance
METADATA_URL="http://169.254.169.254/latest/meta-data"

# Instance ID
curl -s $METADATA_URL/instance-id

# Availability Zone
curl -s $METADATA_URL/placement/availability-zone

# IP privée
curl -s $METADATA_URL/local-ipv4

# IP publique
curl -s $METADATA_URL/public-ipv4

# Région
curl -s $METADATA_URL/placement/region

# Type d'instance
curl -s $METADATA_URL/instance-type

# AMI ID
curl -s $METADATA_URL/ami-id

# Toutes les métadonnées disponibles
curl -s $METADATA_URL/
```

---

### Tests réseau

```bash
# Connectivité
ping -c 4 8.8.8.8              # Ping Google DNS
ping -c 4 google.com           # Test résolution DNS

# Ports ouverts
telnet google.com 80           # Tester port 80
nc -zv google.com 443          # Tester port 443

# Téléchargement
wget https://example.com/file
curl -O https://example.com/file

# Vitesse réseau
speedtest-cli   # Si installé
```

---

### Package Management (Amazon Linux)

```bash
# Rechercher un package
yum search apache

# Installer un package
sudo yum install -y httpd

# Mettre à jour tous les packages
sudo yum update -y

# Lister les packages installés
yum list installed

# Supprimer un package
sudo yum remove httpd
```

---

## 🔥 Commandes de test de charge

```bash
# Apache Bench (ab)
ab -n 1000 -c 10 http://example.com/

# Stress CPU
sudo yum install -y stress-ng
stress-ng --cpu 2 --timeout 300s

# Génération de charge avec dd
dd if=/dev/zero of=/tmp/test bs=1M count=1000

# Requêtes en boucle
for i in {1..100}; do curl -s http://example.com > /dev/null; done

# Surveillance de la charge
watch -n 1 'uptime'
```

---

## 🔑 SSH et Connexion

```bash
# Connexion SSH classique
ssh -i ~/.ssh/ma-cle.pem ec2-user@13.xx.xx.xx

# Connexion avec port forwarding
ssh -i ma-cle.pem -L 8080:localhost:80 ec2-user@IP

# Copie de fichiers (SCP)
scp -i ma-cle.pem fichier.txt ec2-user@IP:/home/ec2-user/
scp -i ma-cle.pem ec2-user@IP:/var/log/httpd/access_log ./

# Copie récursive de dossiers
scp -r -i ma-cle.pem dossier/ ec2-user@IP:/home/ec2-user/
```

---

## 🎯 Commandes one-liners utiles

```bash
# Voir les 10 IPs les plus actives dans les logs Apache
sudo awk '{print $1}' /var/log/httpd/access_log | sort | uniq -c | sort -rn | head -10

# Trouver les plus gros fichiers
find /var/log -type f -exec du -h {} + | sort -rh | head -10

# Nettoyer les logs anciens
sudo find /var/log -name "*.log" -mtime +30 -delete

# Surveiller l'utilisation CPU en continu
watch -n 1 'top -bn1 | head -20'

# Compter les requêtes par code HTTP
sudo awk '{print $9}' /var/log/httpd/access_log | sort | uniq -c | sort -rn
```

---

## 💾 Backup et Restore

```bash
# Backup du site web
sudo tar -czf /tmp/website-backup-$(date +%Y%m%d).tar.gz /var/www/html

# Restore
sudo tar -xzf /tmp/website-backup-20251112.tar.gz -C /

# Backup de la config Apache
sudo cp -r /etc/httpd/conf /tmp/httpd-conf-backup
```

---

## 🎓 Bonnes pratiques

```bash
# Toujours vérifier avant de supprimer
aws ec2 describe-instances --instance-ids i-xxxxx --dry-run

# Utiliser des alias pour gagner du temps
alias ll='ls -lah'
alias awseu='aws --region eu-west-3'

# Ajouter à ~/.bashrc pour les garder
echo "alias ll='ls -lah'" >> ~/.bashrc
source ~/.bashrc
```

---

**💡 Astuce** : Sauvegarde ce fichier et consulte-le régulièrement !