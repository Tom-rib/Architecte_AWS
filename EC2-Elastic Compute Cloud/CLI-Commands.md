# CLI Commands - Référence complète 💻

Toutes les commandes AWS CLI pour Job 1.

---

## 📌 Configuration

```bash
# Configurer AWS CLI
aws configure
# Entrez :
# AWS Access Key ID: YOUR_KEY
# AWS Secret Access Key: YOUR_SECRET
# Default region: eu-west-3
# Default output format: json

# Vérifier configuration
aws sts get-caller-identity
```

---

## 🖥️ EC2 INSTANCES

### Lister instances

```bash
aws ec2 describe-instances --region eu-west-3
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"
```

### Créer instance

```bash
aws ec2 run-instances \
  --image-id ami-0a1b2c3d4e5f6g7h8 \
  --instance-type t2.micro \
  --key-name aws_arch \
  --security-group-ids sg-0123456789abcdef0 \
  --subnet-id subnet-0123456789abcdef0 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=debian-instance-1}]'
```

### Récupérer IP

```bash
aws ec2 describe-instances \
  --instance-ids i-0123456789abcdef0 \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text
```

### Arrêter instance

```bash
aws ec2 stop-instances --instance-ids i-0123456789abcdef0
```

### Démarrer instance

```bash
aws ec2 start-instances --instance-ids i-0123456789abcdef0
```

### Redémarrer instance

```bash
aws ec2 reboot-instances --instance-ids i-0123456789abcdef0
```

### Supprimer instance

```bash
aws ec2 terminate-instances --instance-ids i-0123456789abcdef0
```

---

## 📸 AMIS

### Créer AMI

```bash
aws ec2 create-image \
  --instance-id i-0123456789abcdef0 \
  --name debian-nginx-v1 \
  --description "Debian with Nginx PHP"
```

### Lister AMIs

```bash
aws ec2 describe-images --owners self
```

### Lancer instance depuis AMI

```bash
aws ec2 run-instances \
  --image-id ami-0a1b2c3d4e5f6g7h8 \
  --instance-type t2.micro \
  --key-name aws_arch
```

### Supprimer AMI

```bash
aws ec2 deregister-image --image-id ami-0a1b2c3d4e5f6g7h8
```

---

## 💾 SNAPSHOTS

### Créer snapshot

```bash
aws ec2 create-snapshot \
  --volume-id vol-0123456789abcdef0 \
  --description "Backup before upgrade"
```

### Lister snapshots

```bash
aws ec2 describe-snapshots --owner-ids self
```

### Créer volume depuis snapshot

```bash
aws ec2 create-volume \
  --snapshot-id snap-0123456789abcdef0 \
  --availability-zone eu-west-3a
```

### Attacher volume à instance

```bash
aws ec2 attach-volume \
  --volume-id vol-0123456789abcdef0 \
  --instance-id i-0123456789abcdef0 \
  --device /dev/sdf
```

### Supprimer snapshot

```bash
aws ec2 delete-snapshot --snapshot-id snap-0123456789abcdef0
```

---

## 🌐 ELASTIC IPS

### Allouer Elastic IP

```bash
aws ec2 allocate-address --region eu-west-3
```

### Lister Elastic IPs

```bash
aws ec2 describe-addresses
```

### Attacher à instance

```bash
aws ec2 associate-address \
  --instance-id i-0123456789abcdef0 \
  --allocation-id eipalloc-0123456789abcdef0
```

### Détacher d'instance

```bash
aws ec2 disassociate-address \
  --association-id eipassoc-0123456789abcdef0
```

### Libérer Elastic IP

```bash
aws ec2 release-address \
  --allocation-id eipalloc-0123456789abcdef0
```

---

## ⚙️ LAUNCH TEMPLATES

### Créer Launch Template

```bash
aws ec2 create-launch-template \
  --launch-template-name debian-nginx-template \
  --version-description "Debian with Nginx PHP" \
  --launch-template-data '{
    "ImageId": "ami-0a1b2c3d4e5f6g7h8",
    "InstanceType": "t2.micro",
    "KeyName": "aws_arch",
    "SecurityGroupIds": ["sg-0123456789abcdef0"]
  }'
```

### Lister Launch Templates

```bash
aws ec2 describe-launch-templates
```

### Voir versions template

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

## 📈 AUTO SCALING

### Créer Auto Scaling Group

```bash
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name debian-asg \
  --launch-template LaunchTemplateName=debian-nginx-template \
  --min-size 1 \
  --desired-capacity 2 \
  --max-size 4 \
  --availability-zones eu-west-3a eu-west-3b eu-west-3c
```

### Lister Auto Scaling Groups

```bash
aws autoscaling describe-auto-scaling-groups
```

### Voir instances d'un ASG

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names debian-asg \
  --query 'AutoScalingGroups[0].Instances'
```

### Changer capacité désirée

```bash
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name debian-asg \
  --desired-capacity 3
```

### Ajouter Scaling Policy

```bash
aws autoscaling put-scaling-policy \
  --auto-scaling-group-name debian-asg \
  --policy-name scale-up-policy \
  --policy-type TargetTrackingScaling \
  --target-tracking-configuration '{
    "TargetValue": 70.0,
    "PredefinedMetricSpecification": {
      "PredefinedMetricType": "ASGAverageCPUUtilization"
    }
  }'
```

### Supprimer ASG

```bash
aws autoscaling delete-auto-scaling-group \
  --auto-scaling-group-name debian-asg \
  --force-delete
```

---

## ⚖️ LOAD BALANCERS

### Créer Target Group

```bash
aws elbv2 create-target-group \
  --name debian-targets \
  --protocol HTTP \
  --port 80 \
  --vpc-id vpc-0123456789abcdef0 \
  --health-check-path /index.php
```

### Créer Load Balancer

```bash
aws elbv2 create-load-balancer \
  --name debian-alb \
  --subnets subnet-01 subnet-02 subnet-03 \
  --security-groups sg-0123456789abcdef0 \
  --scheme internet-facing
```

### Créer Listener

```bash
aws elbv2 create-listener \
  --load-balancer-arn arn:aws:elasticloadbalancing:... \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:...
```

### Lister Load Balancers

```bash
aws elbv2 describe-load-balancers
```

### Voir Target Health

```bash
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:...
```

---

## 📧 SNS

### Créer Topic

```bash
aws sns create-topic --name asg-notifications
```

### S'abonner à Topic

```bash
aws sns subscribe \
  --topic-arn arn:aws:sns:eu-west-3:123456789:asg-notifications \
  --protocol email \
  --notification-endpoint votre@email.com
```

### Lister Topics

```bash
aws sns list-topics
```

### Lister Subscriptions

```bash
aws sns list-subscriptions
```

### Envoyer message test

```bash
aws sns publish \
  --topic-arn arn:aws:sns:eu-west-3:123456789:asg-notifications \
  --message "Test message"
```

### Créer notification ASG

```bash
aws autoscaling put-notification-configuration \
  --auto-scaling-group-name debian-asg \
  --topic-arn arn:aws:sns:eu-west-3:123456789:asg-notifications \
  --notification-types \
    "autoscaling:EC2_INSTANCE_LAUNCH" \
    "autoscaling:EC2_INSTANCE_TERMINATE"
```

---

## 🔐 SECURITY GROUPS

### Créer Security Group

```bash
aws ec2 create-security-group \
  --group-name sg-ec2-default \
  --description "SSH, HTTP, HTTPS" \
  --vpc-id vpc-0123456789abcdef0
```

### Ajouter règle (Inbound)

```bash
aws ec2 authorize-security-group-ingress \
  --group-id sg-0123456789abcdef0 \
  --protocol tcp \
  --port 22 \
  --cidr YOUR_IP/32
```

### Voir Security Groups

```bash
aws ec2 describe-security-groups
```

---

## 🔑 KEY PAIRS

### Lister Key Pairs

```bash
aws ec2 describe-key-pairs
```

### Créer Key Pair

```bash
aws ec2 create-key-pair \
  --key-name aws_arch \
  --query 'KeyMaterial' \
  --output text > aws_arch.pem
```

---

## 💡 TIPS

### Exporter en JSON

```bash
aws ec2 describe-instances --output json > instances.json
```

### Filtrer résultats

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Environment,Values=test" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name]'
```

### Utiliser JMESPath queries

```bash
aws ec2 describe-instances \
  --query 'Reservations[].Instances[].{ID:InstanceId, IP:PublicIpAddress, State:State.Name}'
```

---

[⬅️ Retour](./README.md)
