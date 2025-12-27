# 📊 08. Surveillance CloudWatch

> **Objectif** : Mettre en place une surveillance complète avec CloudWatch.  
> **Durée** : 30 minutes  
> **Niveau** : ⭐⭐ Intermédiaire

---

## 🎯 Objectifs de la surveillance

- ✅ Visualiser les métriques en temps réel
- ✅ Créer des alarmes pour être alerté
- ✅ Configurer un dashboard personnalisé
- ✅ Analyser les logs

---

## 📈 Métriques importantes à surveiller

### Métriques EC2

| Métrique | Description | Seuil recommandé |
|----------|-------------|------------------|
| **CPUUtilization** | Utilisation CPU | < 70% |
| **NetworkIn** | Trafic entrant | Dépend de l'usage |
| **NetworkOut** | Trafic sortant | Dépend de l'usage |
| **StatusCheckFailed** | Échecs de health check | 0 |
| **DiskReadBytes** | Lecture disque | Surveillance |
| **DiskWriteBytes** | Écriture disque | Surveillance |

### Métriques Load Balancer

| Métrique | Description | Seuil recommandé |
|----------|-------------|------------------|
| **RequestCount** | Nombre de requêtes | Surveillance |
| **TargetResponseTime** | Temps de réponse | < 1 seconde |
| **HealthyHostCount** | Instances saines | ≥ 2 |
| **UnHealthyHostCount** | Instances défaillantes | 0 |
| **HTTP_5XX_Count** | Erreurs serveur | 0 |
| **HTTP_4XX_Count** | Erreurs client | Faible |

---

## 🚨 Créer des alarmes CloudWatch

### Alarme 1 : CPU élevé

1. Console CloudWatch → **"Alarms"** → **"Create alarm"**
2. **Select metric** → **EC2** → **By Auto Scaling Group**
3. Sélectionne `webapp-prod-asg` → **CPUUtilization**
4. Configuration :

```yaml
Statistic: Average
Period: 5 minutes
Threshold type: Static
Whenever CPUUtilization is: Greater than 70
```

5. **Actions** (optionnel) :
   - Send notification to : [Ton email]
   - Create new topic : `webapp-prod-alerts`

6. **Name** : `webapp-prod-cpu-high`

### Alarme 2 : Instances Unhealthy

1. **Select metric** → **ApplicationELB** → **Per AppELB Metrics**
2. Sélectionne ton ALB → **UnHealthyHostCount**
3. Configuration :

```yaml
Statistic: Maximum
Period: 1 minute
Threshold: Greater than 0
```

4. **Name** : `webapp-prod-unhealthy-hosts`

### Alarme 3 : Erreurs HTTP 5XX

1. **Select metric** → **ApplicationELB** → **HTTPCode_Target_5XX_Count**
2. Configuration :

```yaml
Statistic: Sum
Period: 5 minutes
Threshold: Greater than 10
```

3. **Name** : `webapp-prod-http-errors`

---

## 📊 Créer un Dashboard personnalisé

### Étape 1 : Créer le dashboard

1. CloudWatch → **"Dashboards"** → **"Create dashboard"**
2. **Dashboard name** : `webapp-prod-dashboard`
3. Clique sur **"Create dashboard"**

### Étape 2 : Ajouter des widgets

#### Widget 1 : CPU Utilization (Line Chart)

1. **Add widget** → **Line**
2. **Select metric** → **EC2** → **By Auto Scaling Group**
3. Sélectionne : `webapp-prod-asg` → **CPUUtilization**
4. **Graphed metrics** → **Statistic** : Average, **Period** : 5 minutes
5. **Create widget**

#### Widget 2 : Nombre d'instances (Number)

1. **Add widget** → **Number**
2. **EC2** → **By Auto Scaling Group** → **GroupDesiredCapacity**
3. **Create widget**

#### Widget 3 : Healthy vs Unhealthy Hosts (Line)

1. **Add widget** → **Line**
2. **ApplicationELB** → **Per AppELB Metrics**
3. Sélectionne :
   - **HealthyHostCount**
   - **UnHealthyHostCount**
4. **Create widget**

#### Widget 4 : Request Count (Line)

1. **Add widget** → **Line**
2. **ApplicationELB** → **RequestCount**
3. **Statistic** : Sum, **Period** : 1 minute
4. **Create widget**

### Étape 3 : Organiser le dashboard

Déplace et redimensionne les widgets pour une disposition claire.

**Exemple de layout** :
```
+-------------------+-------------------+
| CPU Utilization   | Request Count     |
+-------------------+-------------------+
| Healthy Hosts     | Desired Capacity  |
+-------------------+-------------------+
```

---

## 📝 Logs et analyse

### CloudWatch Logs Insights

Pour analyser les logs plus finement (si activés) :

1. CloudWatch → **"Logs"** → **"Logs Insights"**
2. **Select log group**
3. Exemple de requêtes :

```sql
# Top 10 des IPs les plus actives
fields @timestamp, @message
| filter @message like /GET/
| parse @message /(?<ip>\d+\.\d+\.\d+\.\d+)/
| stats count() as requests by ip
| sort requests desc
| limit 10

# Temps de réponse moyen par heure
fields @timestamp, request_time
| filter ispresent(request_time)
| stats avg(request_time) as avg_response by bin(1h)
```

---

## ✅ Checklist CloudWatch

- [ ] Alarmes créées (CPU, Unhealthy, HTTP errors)
- [ ] Dashboard personnalisé configuré
- [ ] Notifications par email configurées (optionnel)
- [ ] Métriques visibles et à jour

---

## 🎯 Récapitulatif

Tu as maintenant :
- ✅ Des alarmes pour être prévenu des problèmes
- ✅ Un dashboard pour visualiser l'état de l'infrastructure
- ✅ Une surveillance proactive

---

# 🗑️ 09. Suppression des Ressources (Nettoyage)

> **Objectif** : Supprimer proprement toutes les ressources pour éviter les frais.  
> **Durée** : 15 minutes  
> **Niveau** : ⭐ Débutant

---

## ⚠️ IMPORTANT : Ordre de suppression

Il est **CRUCIAL** de suivre cet ordre pour éviter les erreurs :

```
1. Auto Scaling Group
2. Load Balancer
3. Target Group
4. Instances EC2 (si restantes)
5. AMI et Snapshots
6. Launch Template
7. Security Groups
8. VPC (Subnets, IGW, Route Tables)
9. CloudWatch Alarms et Dashboards
```

---

## 🧹 Étape 1 : Supprimer l'Auto Scaling Group

1. Console EC2 → **"Auto Scaling Groups"**
2. Sélectionne `webapp-prod-asg`
3. **Actions** → **Delete**
4. ✅ Confirme en tapant : `delete`
5. ⏱️ Attends que toutes les instances soient terminées (2-3 minutes)

---

## ⚖️ Étape 2 : Supprimer le Load Balancer

1. Console EC2 → **"Load Balancers"**
2. Sélectionne `webapp-prod-alb`
3. **Actions** → **Delete load balancer**
4. ✅ Confirme en tapant : `confirm`
5. ⏱️ Attends 2-3 minutes

---

## 🎯 Étape 3 : Supprimer le Target Group

1. Console EC2 → **"Target Groups"**
2. Sélectionne `webapp-prod-tg`
3. **Actions** → **Delete**
4. ✅ Confirme

---

## 💻 Étape 4 : Supprimer les instances restantes

1. Console EC2 → **"Instances"**
2. Sélectionne toutes les instances avec tag `webapp-prod`
3. **Instance state** → **Terminate instance**
4. ✅ Confirme
5. ⏱️ Attends que l'état passe à `Terminated`

---

## 📸 Étape 5 : Supprimer l'AMI et les Snapshots

### Supprimer l'AMI

1. Console EC2 → **"AMIs"**
2. Sélectionne `webapp-prod-ami`
3. **Actions** → **Deregister AMI**
4. ✅ Confirme

### Supprimer les Snapshots

1. Console EC2 → **"Snapshots"**
2. Filtre par tag `webapp-prod`
3. Sélectionne les snapshots associés à l'AMI
4. **Actions** → **Delete snapshot**
5. ✅ Confirme

---

## 📝 Étape 6 : Supprimer le Launch Template

1. Console EC2 → **"Launch Templates"**
2. Sélectionne `webapp-prod-lt`
3. **Actions** → **Delete template**
4. ✅ Confirme

---

## 🔒 Étape 7 : Supprimer les Security Groups

⚠️ **Attention** : Supprime dans cet ordre !

1. Console EC2 → **"Security Groups"**
2. Sélectionne `webapp-prod-sg-web`
3. **Actions** → **Delete security groups**
4. ✅ Confirme
5. Répète pour `webapp-prod-sg-alb`

Si erreur "dependency violation" :
- Attends que toutes les instances soient bien terminées
- Vérifie qu'aucun Load Balancer n'utilise le SG

---

## 🌐 Étape 8 : Supprimer le VPC

### Supprimer les Subnets

1. Console VPC → **"Subnets"**
2. Filtre par VPC : `webapp-prod-vpc`
3. Sélectionne tous les subnets
4. **Actions** → **Delete subnet**
5. ✅ Confirme

### Détacher et supprimer l'Internet Gateway

1. Console VPC → **"Internet Gateways"**
2. Sélectionne l'IGW du projet
3. **Actions** → **Detach from VPC**
4. ✅ Confirme
5. **Actions** → **Delete internet gateway**

### Supprimer le VPC

1. Console VPC → **"Your VPCs"**
2. Sélectionne `webapp-prod-vpc`
3. **Actions** → **Delete VPC**
4. ✅ Confirme

AWS supprime automatiquement :
- Route tables associées
- Network ACLs
- DHCP options sets

---

## 📊 Étape 9 : Nettoyer CloudWatch

### Supprimer les alarmes

1. CloudWatch → **"Alarms"** → **"All alarms"**
2. Sélectionne toutes les alarmes du projet
3. **Actions** → **Delete**
4. ✅ Confirme

### Supprimer le dashboard

1. CloudWatch → **"Dashboards"**
2. Sélectionne `webapp-prod-dashboard`
3. **Actions** → **Delete**
4. ✅ Confirme

---

## 🔑 Étape 10 : Supprimer la Key Pair (optionnel)

1. Console EC2 → **"Key Pairs"**
2. Sélectionne `webapp-prod-keypair`
3. **Actions** → **Delete**
4. ✅ Confirme

⚠️ **Attention** : Supprime aussi le fichier `.pem` de ton ordinateur

```bash
rm ~/.ssh/aws-keys/webapp-prod-keypair.pem
```

---

## ✅ Checklist de nettoyage

Vérifie que tout est supprimé :

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
- [ ] Key Pair supprimée

---

## 💰 Étape 11 : Vérifier les coûts

### Vérifier qu'il n'y a plus de frais

1. Console AWS → **"Billing and Cost Management"**
2. **Bills** → Mois en cours
3. ✅ Vérifie que les coûts EC2, ELB sont à $0.00

### Services à vérifier

```
EC2 Instances : $0.00
Load Balancers : $0.00
EBS Volumes : $0.00
Snapshots : $0.00
Data Transfer : Minimal
```

---

## 🔍 Script de vérification (AWS CLI)

```bash
#!/bin/bash
# Script de vérification du nettoyage

echo "=== Vérification des ressources restantes ==="

echo "Instances EC2:"
aws ec2 describe-instances --region eu-west-3 \
  --filters "Name=tag:Project,Values=webapp-aws" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name]' \
  --output table

echo "Load Balancers:"
aws elbv2 describe-load-balancers --region eu-west-3 \
  --query 'LoadBalancers[?contains(LoadBalancerName, `webapp-prod`)].LoadBalancerName'

echo "Auto Scaling Groups:"
aws autoscaling describe-auto-scaling-groups --region eu-west-3 \
  --query 'AutoScalingGroups[?contains(AutoScalingGroupName, `webapp-prod`)].AutoScalingGroupName'

echo "=== Fin de la vérification ==="
```

---

## 🆘 Problèmes de suppression

### Erreur : "Resource in use"

**Solution** : Attends que les ressources dépendantes soient supprimées.

### Erreur : "DependencyViolation" (Security Group)

**Solution** :
```bash
1. Vérifie qu'aucune instance n'utilise le SG
2. Vérifie qu'aucun Load Balancer n'utilise le SG
3. Attends 5 minutes et réessaye
```

### Erreur : VPC ne se supprime pas

**Solution** :
```bash
1. Supprime tous les Subnets
2. Détache et supprime l'Internet Gateway
3. Supprime les Route Tables personnalisées
4. Supprime les Security Groups personnalisés
5. Essaye de nouveau de supprimer le VPC
```

---

## 🎯 Récapitulatif final

✅ **Bravo !** Tu as :
- Créé une infrastructure cloud complète
- Mis en place de la haute disponibilité
- Configuré de l'auto-scaling
- Surveillé ton infrastructure
- Nettoyé proprement toutes les ressources

---

**💡 Important** : Vérifie ta facture AWS dans 24-48h pour t'assurer qu'il n'y a plus de frais !