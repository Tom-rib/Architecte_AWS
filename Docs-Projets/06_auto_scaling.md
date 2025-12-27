# 📈 06. Mise en place de l'Auto Scaling

> **Objectif** : Configurer l'Auto Scaling pour adapter automatiquement le nombre d'instances.  
> **Durée** : 1 heure  
> **Niveau** : ⭐⭐⭐ Avancé

---

## 🎯 Ce que tu vas créer

Dans cette étape :
- ✅ Créer un Launch Template
- ✅ Créer un Auto Scaling Group
- ✅ Configurer des Scaling Policies
- ✅ Tester le scaling automatique

---

## 📚 Rappel : Qu'est-ce que l'Auto Scaling ?

L'**Auto Scaling** ajuste automatiquement le nombre d'instances EC2 en fonction de la charge :

```
Charge faible  → 2 instances (minimum)
Charge normale → 3 instances
Charge élevée  → 5 instances (maximum)
```

**Avantages** :
- ✅ Économies : paye uniquement ce dont tu as besoin
- ✅ Performance : toujours assez de ressources
- ✅ Disponibilité : remplacement automatique en cas de panne

---

## 📝 Étape 1 : Créer un Launch Template

### 1.1. Qu'est-ce qu'un Launch Template ?

Un **Launch Template** est un modèle de configuration pour lancer des instances EC2. Il contient :
- L'AMI à utiliser
- Le type d'instance
- Le Security Group
- Les scripts de démarrage
- Etc.

### 1.2. Créer le Launch Template

1. Console EC2 → Menu gauche → **"Instances"** → **"Launch Templates"**
2. Clique sur **"Create launch template"**

**Configuration :**

#### Launch template name and description

```yaml
Launch template name: webapp-prod-lt
Template version description: Initial version with Apache and PHP
```

#### Application and OS Images (AMI)

⚠️ **IMPORTANT** : Utilise l'AMI que tu as créée précédemment !

1. Clique sur **"My AMIs"**
2. Sélectionne **"Owned by me"**
3. Choisis `webapp-prod-ami`

#### Instance type

```yaml
Instance type: t2.micro
```

#### Key pair

```yaml
Key pair name: webapp-prod-keypair
```

#### Network settings

```yaml
Subnet: Don't include in launch template
Security groups: webapp-prod-sg-web
```

⚠️ **Ne mets PAS de subnet** dans le Launch Template. L'Auto Scaling Group le gérera.

#### Storage (volumes)

```yaml
Volume 1 (AMI Root):
  Size: 8 GiB
  Volume type: gp3
  Delete on termination: Yes
```

#### Resource tags

Clique sur **"Add tag"** :

```yaml
Key: Name
Value: webapp-prod-asg-instance
Resource types: ☑ Instances, ☑ Volumes
```

#### Advanced details

Scroll jusqu'à **"User data"** et ajoute (optionnel, pour vérifier qu'Apache démarre) :

```bash
#!/bin/bash
# S'assurer qu'Apache est démarré
systemctl start httpd
systemctl enable httpd
```

### 1.3. Créer le template

1. Clique sur **"Create launch template"**
2. ✅ Message : "Successfully created launch template"

---

## 🚀 Étape 2 : Créer l'Auto Scaling Group

### 2.1. Démarrer la création

1. Console EC2 → **"Auto Scaling Groups"**
2. Clique sur **"Create Auto Scaling group"**

### 2.2. Choose launch template

```yaml
Auto Scaling group name: webapp-prod-asg
Launch template: webapp-prod-lt
```

Clique sur **"Next"**

### 2.3. Choose instance launch options

#### Network

```yaml
VPC: webapp-prod-vpc

Availability Zones and subnets:
  ☑ webapp-prod-subnet-public1-eu-west-3a
  ☑ webapp-prod-subnet-public2-eu-west-3b
```

⚠️ **Important** : Sélectionne les **2 subnets publics** dans les 2 AZ différentes.

Clique sur **"Next"**

### 2.4. Configure advanced options

#### Load balancing

```yaml
☑ Attach to an existing load balancer
Choose from your load balancer target groups
Existing load balancer target groups: webapp-prod-tg
```

#### Health checks

```yaml
☑ Turn on Elastic Load Balancing health checks
Health check grace period: 300 seconds
```

**Explication** : Grace period = temps d'attente avant le premier health check (le temps que l'instance démarre).

#### Additional settings

```yaml
☑ Enable group metrics collection within CloudWatch
```

Clique sur **"Next"**

### 2.5. Configure group size and scaling policies

#### Group size

```yaml
Desired capacity: 2
Minimum capacity: 2
Maximum capacity: 5
```

**Explications** :
- **Desired** : nombre d'instances à maintenir normalement
- **Minimum** : nombre minimal (toujours au moins 2 instances)
- **Maximum** : nombre maximal (limite de scaling)

#### Scaling policies

Sélectionne **"Target tracking scaling policy"**

```yaml
Scaling policy name: webapp-prod-scaling-policy
Metric type: Average CPU utilization
Target value: 50
```

**Explication** : Si la moyenne CPU dépasse 50%, l'Auto Scaling ajoute des instances.

#### Instance scale-in protection

```yaml
☐ Enable instance scale-in protection (laisse décoché)
```

Clique sur **"Next"**

### 2.6. Add notifications (optionnel)

On peut passer cette étape. Clique sur **"Next"**

### 2.7. Add tags

Les tags du Launch Template s'appliquent automatiquement.

Clique sur **"Next"**

### 2.8. Review

Vérifie toute la configuration et clique sur **"Create Auto Scaling group"**

✅ L'Auto Scaling Group est créé !

---

## 🔍 Étape 3 : Vérifier l'Auto Scaling Group

### 3.1. Voir les instances lancées

1. Console EC2 → **"Auto Scaling Groups"**
2. Sélectionne `webapp-prod-asg`
3. Onglet **"Activity"** : tu vois les instances en cours de lancement
4. ⏱️ Attends 2-3 minutes

### 3.2. Vérifier les instances EC2

1. Console EC2 → **"Instances"**
2. Tu devrais voir **2 nouvelles instances** avec le nom `webapp-prod-asg-instance`
3. Vérifie qu'elles sont dans des **AZ différentes** :
   - Instance 1 : `eu-west-3a`
   - Instance 2 : `eu-west-3b`

### 3.3. Vérifier le Target Group

1. Console EC2 → **"Target Groups"**
2. Sélectionne `webapp-prod-tg`
3. Onglet **"Targets"**
4. ⏱️ Attends 30-60 secondes
5. Toutes les instances doivent être **"Healthy"** ✅

---

## 🧪 Étape 4 : Tester le scaling automatique

### 4.1. Scale Out (ajouter des instances)

Pour tester, on va simuler une charge CPU élevée.

**Méthode 1 : Via une scaling policy manuelle (test rapide)**

1. Auto Scaling Groups → `webapp-prod-asg`
2. Onglet **"Automatic scaling"**
3. Tu peux voir la policy : `webapp-prod-scaling-policy`

**Méthode 2 : Simuler une charge CPU**

1. Connecte-toi à une instance :
```bash
ssh -i ta-cle.pem ec2-user@IP-INSTANCE
```

2. Installe stress (outil de test de charge) :
```bash
sudo yum install -y stress
```

3. Lance un test de charge :
```bash
# Charge CPU à 100% pendant 5 minutes
stress --cpu 2 --timeout 300s

# Surveille le CPU
top
```

4. Après ~2 minutes, vérifie l'Auto Scaling :
   - Console → Auto Scaling Groups → `webapp-prod-asg`
   - Onglet **"Activity"** : tu devrais voir une nouvelle instance se lancer

### 4.2. Scale In (retirer des instances)

1. Arrête le test de charge (Ctrl+C)
2. Attends 5-10 minutes
3. L'Auto Scaling devrait automatiquement **retirer** les instances en trop
4. Le nombre d'instances revient à **2** (desired capacity)

---

## 📊 Étape 5 : Configurer des alarmes CloudWatch

### 5.1. Créer une alarme pour CPU élevé

1. Console CloudWatch → **"Alarms"** → **"All alarms"**
2. Clique sur **"Create alarm"**
3. **Select metric** → **EC2** → **By Auto Scaling Group**
4. Sélectionne `webapp-prod-asg` → `CPUUtilization`
5. **Specify metric and conditions** :

```yaml
Metric name: CPUUtilization
Statistic: Average
Period: 1 minute

Conditions:
  Threshold type: Static
  Whenever CPUUtilization is: Greater than
  than: 70
```

6. **Configure actions** (optionnel) :

```yaml
Alarm state trigger: In alarm
Send notification to: [Ton email]
```

7. **Add name and description** :

```yaml
Alarm name: webapp-prod-high-cpu
Alarm description: Alert when CPU > 70%
```

8. **Create alarm**

---

## 🎨 Configuration avancée (optionnel)

### Step Scaling Policy

Pour un contrôle plus fin du scaling :

```yaml
Policy name: webapp-prod-step-scaling
Metric: Average CPU Utilization

Step adjustments:
  - CPU 50-60%: +1 instance
  - CPU 60-80%: +2 instances
  - CPU > 80%: +3 instances
```

### Scheduled Scaling

Pour anticiper des pics de charge connus :

```yaml
# Exemple : augmenter la capacité tous les jours à 8h
Scheduled action name: morning-scale-out
Recurrence: 0 8 * * *
Desired capacity: 5
Min: 3
Max: 10
```

---

## 🔧 Commandes utiles

### Via AWS CLI

```bash
# Lister les Auto Scaling Groups
aws autoscaling describe-auto-scaling-groups --region eu-west-3

# Voir les instances d'un ASG
aws autoscaling describe-auto-scaling-instances --region eu-west-3

# Modifier la capacité manuellement
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name webapp-prod-asg \
  --desired-capacity 4

# Voir l'historique des scaling activities
aws autoscaling describe-scaling-activities \
  --auto-scaling-group-name webapp-prod-asg
```

---

## 📋 Schéma de l'architecture complète

```
                         INTERNET
                             |
                             v
                  [Application Load Balancer]
                    webapp-prod-alb
                           |
                  [Target Group: webapp-prod-tg]
                           |
                  [Auto Scaling Group]
                   Min: 2 | Max: 5
                           |
         +-----------------+------------------+
         |                 |                  |
         v                 v                  v
   [EC2 Instance 1]  [EC2 Instance 2]  [EC2 Instance 3]
      AZ: 3a            AZ: 3b             AZ: 3a
      10.0.1.x          10.0.2.x           10.0.1.y
   
   Scaling déclenché par:
   - CPU Utilization > 50%
   - Alarmes CloudWatch
```

---

## 🆘 Troubleshooting

### Problème : Instances ne se lancent pas

**Symptôme** : Activity History montre "Failed"

**Causes possibles** :
1. AMI invalide ou supprimée
2. Security Group introuvable
3. Subnets incorrects

**Solution** :
```bash
1. Vérifie le Launch Template
2. Vérifie que l'AMI existe (EC2 → AMIs)
3. Vérifie que les Security Groups existent
4. Consulte les logs dans Activity History
```

---

### Problème : Health check échoue

**Symptôme** : Instances marquées "Unhealthy" et remplacées en boucle

**Solution** :
```bash
1. Augmente le "Health check grace period" à 600 secondes
2. Vérifie qu'Apache démarre automatiquement
3. Connecte-toi à une instance et teste :
   curl http://localhost
```

---

### Problème : Scaling ne se déclenche pas

**Causes** :
1. Seuil trop élevé (ex: CPU à 90%)
2. Période d'évaluation trop longue
3. Cooldown period actif

**Solution** :
```bash
# Réduire le seuil de CPU à 50%
# Réduire la période à 1 minute
# Vérifier qu'il n'y a pas de cooldown en cours
```

---

## ✅ Checklist de validation

- [ ] Launch Template créé avec la bonne AMI
- [ ] Auto Scaling Group créé (min: 2, max: 5)
- [ ] 2 instances lancées dans 2 AZ différentes
- [ ] Toutes les instances "Healthy" dans le Target Group
- [ ] Scaling policy configurée (CPU > 50%)
- [ ] Application accessible via le Load Balancer
- [ ] (Optionnel) Test de scaling effectué

---

## 🎯 Récapitulatif

Tu as maintenant :
- ✅ Un Launch Template pour créer des instances identiques
- ✅ Un Auto Scaling Group qui gère automatiquement les instances
- ✅ Des Scaling Policies basées sur le CPU
- ✅ Une architecture totalement scalable et résiliente

---

## 🚀 Prochaine étape

**Direction [07_tests_validation.md](07_tests_validation.md)** pour tester l'infrastructure complète !

---

**💡 Astuce** : L'Auto Scaling peut prendre quelques minutes pour réagir. Sois patient lors des tests !