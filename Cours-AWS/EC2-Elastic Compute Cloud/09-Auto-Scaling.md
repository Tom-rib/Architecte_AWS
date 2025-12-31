# Auto Scaling Group - Scaling Automatique 📈

Groupe d'instances qui se crée/détruit automatiquement selon la charge.

---

## 🎯 À quoi ça sert ?

- Ajouter instances quand CPU > 70%
- Supprimer instances quand CPU < 30%
- Passer de 1 à 100 instances automatiquement
- Zéro intervention manuelle

---

## 📊 Paramètres clés

| Paramètre | Exemple | Signification |
|---|---|---|
| **Min** | 1 | Minimum d'instances actives |
| **Desired** | 2 | Nombre normal à maintenir |
| **Max** | 4 | Maximum si pics de charge |
| **Health check** | ELB | Vérifier instances saines |
| **Termination policy** | Default | Quelle instance tuer en premier |

---

## 🖼️ DASHBOARD AWS

### Créer un Auto Scaling Group

```
1. EC2 > Auto Scaling Groups > Create Auto Scaling group
2. Name : debian-asg
3. Launch template : debian-nginx-template
4. Version : $Latest
5. Next
```

### Étape 1 : Network

```
- VPC : default
- Subnets : 
  ✓ eu-west-3a
  ✓ eu-west-3b
  ✓ eu-west-3c
  (plus de zones = haute disponibilité)
```

### Étape 2 : Desired capacity

```
- Min : 1
- Desired : 2
- Max : 4
(ASG va créer 2 instances maintenant)
```

### Étape 3 : Load balancer (OPTIONNEL)

```
Si vous avez un Load Balancer :
- Attach to existing load balancer
- Sélectionnez le target group
```

### Étape 4 : Health check

```
- Type : ELB (si Load Balancer)
- Ou : EC2 (vérifier process)
- Grace period : 300 sec
```

### Étape 5 : Scaling (OPTIONNEL)

```
Policy : Target tracking
- Metric : CPU Utilization
- Target value : 70%
(ajoute instance si > 70%, enlève si < 30%)
```

### Créer

```
Cliquez "Create Auto Scaling group" ✓
```

### Voir vos ASG

```
EC2 > Auto Scaling Groups
- Status : Healthy / Unhealthy
- Instances : nb d'instances actives
- Desired : nb demandé
```

---

## 💻 CLI

### Créer un Auto Scaling Group

```bash
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name debian-asg \
  --launch-template LaunchTemplateName=debian-nginx-template \
  --min-size 1 \
  --desired-capacity 2 \
  --max-size 4 \
  --availability-zones eu-west-3a eu-west-3b eu-west-3c
```

### Lister les ASG

```bash
aws autoscaling describe-auto-scaling-groups
```

### Voir les instances d'un ASG

```bash
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names debian-asg \
  --query 'AutoScalingGroups[0].Instances'
```

### Changer la capacité

```bash
# Passer de 2 à 3 instances
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name debian-asg \
  --desired-capacity 3
```

### Ajouter une Scaling Policy

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

### Supprimer un ASG

```bash
# Attention : supprime aussi les instances !
aws autoscaling delete-auto-scaling-group \
  --auto-scaling-group-name debian-asg \
  --force-delete
```

---

## 📌 NOTES

- **Desire vs Min/Max** : ASG maintient Desired (crée/supprime pour rester à ce niveau)
- **Health Check** : élimine instances non saines
- **Termination Policy** : "Default" = supprime les plus récentes d'abord
- **Coût** : multiplié par nombre d'instances

---

[⬅️ Retour](./README.md)
