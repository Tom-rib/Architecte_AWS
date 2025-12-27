# 🗑️ 09. Suppression des Ressources

> **Objectif** : Supprimer proprement toutes les ressources AWS créées.  
> **Durée** : 15 minutes  
> **Niveau** : ⭐ Débutant

---

## ⚠️ AVERTISSEMENT IMPORTANT

**Pourquoi supprimer les ressources ?**
- Éviter les frais inutiles
- Respecter les limites du Free Tier
- Garder un compte AWS propre

**Que vas-tu perdre ?**
- Toute l'infrastructure créée
- Les données et configurations
- Les métriques CloudWatch

💡 **Conseil** : Fais des captures d'écran avant de tout supprimer !

---

## 📋 Ordre de suppression (CRITIQUE)

**Respecte CET ORDRE** pour éviter les erreurs :

```
1️⃣  Auto Scaling Group (+ instances associées)
2️⃣  Load Balancer
3️⃣  Target Group
4️⃣  Instances EC2 restantes (si existent)
5️⃣  AMI et Snapshots
6️⃣  Launch Template
7️⃣  Security Groups
8️⃣  Subnets
9️⃣  Internet Gateway
🔟  VPC
1️⃣1️⃣  CloudWatch Alarms et Dashboard
1️⃣2️⃣  Key Pair (optionnel)
```

---

## 🚀 Méthode rapide : Script automatique

### Script de suppression automatique

```bash
#!/bin/bash
# cleanup_aws.sh - Script de nettoyage automatique
# Usage: ./cleanup_aws.sh

REGION="eu-west-3"
PROJECT_TAG="webapp-prod"

echo "⚠️  ATTENTION : Ce script va supprimer toutes les ressources du projet !"
read -p "Continuer ? (tapez 'OUI' pour confirmer) : " confirm

if [ "$confirm" != "OUI" ]; then
    echo "❌ Annulé"
    exit 1
fi

echo "🧹 Début du nettoyage..."

# 1. Supprimer Auto Scaling Group
echo "1️⃣  Suppression Auto Scaling Group..."
ASG_NAME=$(aws autoscaling describe-auto-scaling-groups --region $REGION \
    --query "AutoScalingGroups[?contains(AutoScalingGroupName, '${PROJECT_TAG}')].AutoScalingGroupName" \
    --output text)

if [ ! -z "$ASG_NAME" ]; then
    aws autoscaling delete-auto-scaling-group \
        --auto-scaling-group-name $ASG_NAME \
        --force-delete \
        --region $REGION
    echo "✅ Auto Scaling Group supprimé"
    sleep 30
fi

# 2. Supprimer Load Balancer
echo "2️⃣  Suppression Load Balancer..."
ALB_ARN=$(aws elbv2 describe-load-balancers --region $REGION \
    --query "LoadBalancers[?contains(LoadBalancerName, '${PROJECT_TAG}')].LoadBalancerArn" \
    --output text)

if [ ! -z "$ALB_ARN" ]; then
    aws elbv2 delete-load-balancer --load-balancer-arn $ALB_ARN --region $REGION
    echo "✅ Load Balancer supprimé"
    sleep 30
fi

# 3. Supprimer Target Group
echo "3️⃣  Suppression Target Group..."
TG_ARN=$(aws elbv2 describe-target-groups --region $REGION \
    --query "TargetGroups[?contains(TargetGroupName, '${PROJECT_TAG}')].TargetGroupArn" \
    --output text)

if [ ! -z "$TG_ARN" ]; then
    aws elbv2 delete-target-group --target-group-arn $TG_ARN --region $REGION
    echo "✅ Target Group supprimé"
fi

# 4. Supprimer instances restantes
echo "4️⃣  Suppression instances EC2..."
INSTANCE_IDS=$(aws ec2 describe-instances --region $REGION \
    --filters "Name=tag:Project,Values=webapp-aws" "Name=instance-state-name,Values=running,stopped" \
    --query 'Reservations[*].Instances[*].InstanceId' \
    --output text)

if [ ! -z "$INSTANCE_IDS" ]; then
    aws ec2 terminate-instances --instance-ids $INSTANCE_IDS --region $REGION
    echo "✅ Instances terminées"
    sleep 60
fi

echo "✅ Nettoyage terminé !"
echo "⚠️  Poursuis manuellement pour VPC, Security Groups, etc."
```

---

## 🖱️ Méthode manuelle : Console AWS

### 1️⃣ Supprimer l'Auto Scaling Group

1. Console EC2 → **"Auto Scaling Groups"**
2. Sélectionne `webapp-prod-asg`
3. **Actions** → **Delete**
4. Tape `delete` pour confirmer
5. ⏱️ Attends 2-3 minutes

✅ **Vérification** : Les instances de l'ASG sont automatiquement terminées

---

### 2️⃣ Supprimer le Load Balancer

1. Console EC2 → **"Load Balancers"**
2. Sélectionne `webapp-prod-alb`
3. **Actions** → **Delete load balancer**
4. Tape `confirm`
5. ⏱️ Attends 2-3 minutes

---

### 3️⃣ Supprimer le Target Group

1. Console EC2 → **"Target Groups"**
2. Sélectionne `webapp-prod-tg`
3. **Actions** → **Delete**
4. Confirme

---

### 4️⃣ Supprimer les instances restantes

1. Console EC2 → **"Instances"**
2. Filtre par tag : `Project: webapp-aws`
3. Sélectionne toutes les instances
4. **Instance state** → **Terminate instance**
5. Confirme
6. ⏱️ Attends que l'état passe à `Terminated`

---

### 5️⃣ Supprimer l'AMI et les Snapshots

**AMI :**
1. Console EC2 → **"AMIs"**
2. Sélectionne `webapp-prod-ami`
3. **Actions** → **Deregister AMI**
4. Confirme

**Snapshots :**
1. Console EC2 → **"Snapshots"**
2. Trouve les snapshots associés à l'AMI (même timestamp)
3. Sélectionne-les
4. **Actions** → **Delete snapshot**
5. Confirme

---

### 6️⃣ Supprimer le Launch Template

1. Console EC2 → **"Launch Templates"**
2. Sélectionne `webapp-prod-lt`
3. **Actions** → **Delete template**
4. Confirme

---

### 7️⃣ Supprimer les Security Groups

⚠️ **Ordre important** : Supprime d'abord `sg-web`, puis `sg-alb`

1. Console EC2 → **"Security Groups"**
2. Sélectionne `webapp-prod-sg-web`
3. **Actions** → **Delete security groups**
4. Confirme
5. Répète pour `webapp-prod-sg-alb`

**Si erreur "dependency violation"** :
- Attends 5 minutes que les ressources se libèrent
- Réessaye

---

### 8️⃣ Supprimer les Subnets

1. Console VPC → **"Subnets"**
2. Filtre par VPC : `webapp-prod-vpc`
3. Sélectionne les 2 subnets
4. **Actions** → **Delete subnet**
5. Confirme

---

### 9️⃣ Supprimer l'Internet Gateway

1. Console VPC → **"Internet Gateways"**
2. Sélectionne l'IGW du projet
3. **Actions** → **Detach from VPC**
4. Confirme
5. **Actions** → **Delete internet gateway**
6. Confirme

---

### 🔟 Supprimer le VPC

1. Console VPC → **"Your VPCs"**
2. Sélectionne `webapp-prod-vpc`
3. **Actions** → **Delete VPC**
4. Confirme

AWS supprime automatiquement :
- Route tables
- Network ACLs
- Autres ressources associées

---

### 1️⃣1️⃣ Nettoyer CloudWatch

**Alarmes :**
1. CloudWatch → **"Alarms"**
2. Sélectionne toutes les alarmes du projet
3. **Actions** → **Delete**

**Dashboard :**
1. CloudWatch → **"Dashboards"**
2. Sélectionne `webapp-prod-dashboard`
3. **Actions** → **Delete**

---

### 1️⃣2️⃣ Supprimer la Key Pair (optionnel)

1. Console EC2 → **"Key Pairs"**
2. Sélectionne `webapp-prod-keypair`
3. **Actions** → **Delete**

**Supprime aussi le fichier local :**
```bash
rm ~/.ssh/aws-keys/webapp-prod-keypair.pem
```

---

## ✅ Checklist de vérification

Coche au fur et à mesure :

- [ ] Auto Scaling Group supprimé
- [ ] Load Balancer supprimé
- [ ] Target Group supprimé
- [ ] Toutes les instances EC2 terminées
- [ ] AMI désenregistrée
- [ ] Snapshots supprimés
- [ ] Launch Template supprimé
- [ ] Security Groups supprimés (sauf `default`)
- [ ] Subnets supprimés
- [ ] Internet Gateway supprimé
- [ ] VPC supprimé
- [ ] Alarmes CloudWatch supprimées
- [ ] Dashboard CloudWatch supprimé
- [ ] Key Pair supprimée (optionnel)

---

## 💰 Vérifier les coûts

### Étape 1 : Consulter la facture

1. Console AWS → Barre de recherche → **"Billing"**
2. **Bills** → Mois en cours
3. Développe chaque service et vérifie :

```
✅ EC2 Instances : $0.00
✅ Load Balancers : $0.00
✅ EBS Volumes : $0.00
✅ Snapshots : $0.00
✅ Data Transfer : < $0.10
```

### Étape 2 : Vérifier Free Tier Usage

1. **Billing** → **Free Tier**
2. Vérifie que tu n'as pas dépassé les limites

---

## 🆘 Problèmes courants

### Problème 1 : "Resource in use"

**Solution** : Attends que les ressources dépendantes se libèrent (5-10 min)

---

### Problème 2 : Security Group ne se supprime pas

**Erreur** : `DependencyViolation`

**Solutions** :
1. Vérifie qu'aucune instance n'utilise le SG
2. Vérifie qu'aucun Load Balancer n'utilise le SG
3. Attends 5 minutes
4. Réessaye

---

### Problème 3 : VPC ne se supprime pas

**Solutions dans l'ordre** :
1. Supprime tous les Subnets
2. Détache l'Internet Gateway
3. Supprime l'Internet Gateway
4. Supprime les Route Tables personnalisées
5. Supprime les Security Groups (sauf `default`)
6. Réessaye de supprimer le VPC

---

## 🔍 Script de vérification post-nettoyage

```bash
#!/bin/bash
# verify_cleanup.sh

REGION="eu-west-3"

echo "🔍 Vérification des ressources restantes..."

echo -e "\n📌 Instances EC2:"
aws ec2 describe-instances --region $REGION \
  --filters "Name=tag:Project,Values=webapp-aws" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' \
  --output table

echo -e "\n📌 Load Balancers:"
aws elbv2 describe-load-balancers --region $REGION \
  --query 'LoadBalancers[?contains(LoadBalancerName, `webapp-prod`)].LoadBalancerName' \
  --output table

echo -e "\n📌 Auto Scaling Groups:"
aws autoscaling describe-auto-scaling-groups --region $REGION \
  --query 'AutoScalingGroups[?contains(AutoScalingGroupName, `webapp-prod`)].AutoScalingGroupName' \
  --output table

echo -e "\n📌 VPCs:"
aws ec2 describe-vpcs --region $REGION \
  --filters "Name=tag:Name,Values=*webapp-prod*" \
  --query 'Vpcs[*].[VpcId,CidrBlock]' \
  --output table

echo -e "\n✅ Vérification terminée"
```

---

## 📸 Avant de supprimer : Sauvegarde !

**Ce qu'il faut sauvegarder pour ton rapport :**

📷 **Captures d'écran** :
- Architecture VPC
- Instances EC2 en cours
- Load Balancer avec targets healthy
- Auto Scaling Group configuration
- Métriques CloudWatch
- Page web fonctionnelle

📄 **Configurations** :
- Copie des Security Group rules
- Configuration de l'Auto Scaling
- Scaling policies
- User data scripts

---

## 🎯 Récapitulatif

**Temps total** : ~15-20 minutes

**Économies** : Évite des frais mensuels de ~50-100€

**Résultat** : Compte AWS propre et sans frais récurrents

---

## ⏭️ Après le nettoyage

Tu peux maintenant :
- ✅ Refaire le projet depuis le début pour t'entraîner
- ✅ Modifier le projet pour tester d'autres configurations
- ✅ Passer à un autre projet AWS

---

**💡 Conseil final** : Vérifie ta facture AWS dans 24-48h pour t'assurer qu'il n'y a vraiment plus de frais !

**🎓 Félicitations** : Tu as terminé le projet complet !