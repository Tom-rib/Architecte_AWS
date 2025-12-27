# ⚖️ 05. Configuration du Load Balancer

> **Objectif** : Créer un Application Load Balancer pour répartir le trafic.  
> **Durée** : 1 heure  
> **Niveau** : ⭐⭐⭐ Avancé

---

## 🎯 Ce que tu vas créer

Dans cette étape :
- ✅ Créer un Target Group
- ✅ Créer un Application Load Balancer (ALB)
- ✅ Configurer les Health Checks
- ✅ Tester la répartition de charge

---

## 📚 Rappel : Qu'est-ce qu'un Load Balancer ?

Un **Load Balancer** (répartiteur de charge) distribue le trafic entre plusieurs serveurs :

```
         Utilisateurs
              |
         [Load Balancer]
         /     |     \
    Serveur1 Serveur2 Serveur3
```

**Avantages** :
- ✅ Haute disponibilité (si un serveur tombe, les autres prennent le relais)
- ✅ Meilleure performance (charge répartie)
- ✅ Scalabilité (ajout facile de nouveaux serveurs)

---

## 🎯 Étape 1 : Créer un Target Group

### 1.1. Qu'est-ce qu'un Target Group ?

Un **Target Group** est un groupe d'instances EC2 qui reçoivent le trafic du Load Balancer.

### 1.2. Créer le Target Group

1. Console EC2 → Menu gauche → **"Load Balancing"** → **"Target Groups"**
2. Clique sur **"Create target group"**

**Configuration :**

#### Basic configuration

```yaml
Choose a target type: Instances
Target group name: webapp-prod-tg
Protocol: HTTP
Port: 80
VPC: webapp-prod-vpc
Protocol version: HTTP1
```

#### Health checks

```yaml
Health check protocol: HTTP
Health check path: /
```

#### Advanced health check settings

```yaml
Port: Traffic port
Healthy threshold: 2
Unhealthy threshold: 2
Timeout: 5 seconds
Interval: 30 seconds
Success codes: 200
```

**Explications** :
- **Healthy threshold** : 2 checks réussis = instance considérée saine
- **Unhealthy threshold** : 2 checks échoués = instance retirée
- **Timeout** : temps d'attente d'une réponse
- **Interval** : fréquence des checks (toutes les 30 secondes)
- **Success codes** : codes HTTP acceptés (200 = OK)

3. Clique sur **"Next"**

#### Register targets

1. **Sélectionne** ton instance `webapp-prod-ec2-web-01`
2. Clique sur **"Include as pending below"**
3. Vérifie qu'elle apparaît dans la liste en bas
4. Clique sur **"Create target group"**

✅ Target Group créé !

---

## 🔍 Étape 2 : Vérifier le Target Group

### 2.1. Vérifier l'état des targets

1. Sélectionne ton Target Group `webapp-prod-tg`
2. Onglet **"Targets"**
3. Attends 30 secondes
4. Rafraîchis (icône ↻)
5. Le **Health status** doit passer à `Healthy` ✅

Si l'état reste `Unhealthy` :
- Vérifie que l'instance est bien `Running`
- Vérifie qu'Apache tourne : `sudo systemctl status httpd`
- Vérifie le Security Group (port 80 autorisé)

---

## ⚖️ Étape 3 : Créer l'Application Load Balancer

### 3.1. Démarrer la création

1. Console EC2 → **"Load Balancers"**
2. Clique sur **"Create load balancer"**
3. Choisis **"Application Load Balancer"** → **"Create"**

### 3.2. Configuration de base

```yaml
Load balancer name: webapp-prod-alb
Scheme: Internet-facing
IP address type: IPv4
```

### 3.3. Network mapping

```yaml
VPC: webapp-prod-vpc

Mappings:
  ☑ eu-west-3a : webapp-prod-subnet-public1-eu-west-3a
  ☑ eu-west-3b : webapp-prod-subnet-public2-eu-west-3b
```

⚠️ **Important** : Le Load Balancer doit être dans **au moins 2 AZ** (Availability Zones)

### 3.4. Security groups

```yaml
Security groups: webapp-prod-sg-alb
```

⚠️ **Retire le Security Group par défaut** et garde uniquement `webapp-prod-sg-alb`

### 3.5. Listeners and routing

```yaml
Protocol: HTTP
Port: 80
Default action: Forward to webapp-prod-tg
```

### 3.6. Tags (optionnel)

```json
{
  "Name": "webapp-prod-alb",
  "Project": "webapp-aws",
  "Environment": "production"
}
```

### 3.7. Créer le Load Balancer

1. Clique sur **"Create load balancer"**
2. ✅ Message : "Successfully created load balancer"
3. ⏱️ Attends 3-5 minutes que l'état passe à `Active`

---

## 🔍 Étape 4 : Vérifier le Load Balancer

### 4.1. Récupérer le DNS du Load Balancer

1. Console EC2 → **"Load Balancers"**
2. Sélectionne `webapp-prod-alb`
3. Copie le **DNS name** :
   ```
   webapp-prod-alb-123456789.eu-west-3.elb.amazonaws.com
   ```

### 4.2. Tester l'accès

1. Ouvre ton navigateur
2. Colle le DNS du Load Balancer
3. ✅ Tu devrais voir ta page web !

**Exemple :**
```
http://webapp-prod-alb-123456789.eu-west-3.elb.amazonaws.com
```

### 4.3. Vérifier les Targets

1. Sélectionne le Load Balancer
2. Onglet **"Target groups"**
3. Clique sur `webapp-prod-tg`
4. Onglet **"Targets"**
5. Vérifie : **Health status** = `Healthy` ✅

---

## 🧪 Étape 5 : Tester la haute disponibilité

### 5.1. Ajouter une deuxième instance (optionnel)

Pour vraiment tester le Load Balancer, créons une 2e instance :

1. Console EC2 → **"Instances"**
2. Sélectionne `webapp-prod-ec2-web-01`
3. **Actions** → **Image and templates** → **Launch more like this**

**Modifications** :
```yaml
Name: webapp-prod-ec2-web-02
Subnet: webapp-prod-subnet-public2-eu-west-3b (l'autre AZ)
```

4. **Launch instance**

### 5.2. Ajouter l'instance au Target Group

1. Console EC2 → **"Target Groups"**
2. Sélectionne `webapp-prod-tg`
3. Onglet **"Targets"**
4. Clique sur **"Register targets"**
5. Sélectionne `webapp-prod-ec2-web-02`
6. **Include as pending below**
7. **Register pending targets**

⏱️ Attends 30 secondes que le Health status passe à `Healthy`

### 5.3. Tester la répartition de charge

1. Ouvre ton navigateur
2. Va sur le DNS du Load Balancer
3. Rafraîchis plusieurs fois (F5)
4. ✅ Tu devrais voir l'**Instance ID changer** (alternance entre les 2 instances)

```
Rafraîchissement 1 → Instance: i-0123456 (web-01)
Rafraîchissement 2 → Instance: i-0789abc (web-02)
Rafraîchissement 3 → Instance: i-0123456 (web-01)
...
```

### 5.4. Simuler une panne

**Test de failover** :

1. Console EC2 → **"Instances"**
2. Sélectionne `webapp-prod-ec2-web-01`
3. **Instance state** → **Stop instance**
4. Attends 1 minute
5. Rafraîchis le navigateur plusieurs fois
6. ✅ L'application reste accessible via `web-02` uniquement

**Vérifie le Target Group** :
- `web-01` : `Unhealthy` ou `Unused`
- `web-02` : `Healthy` ✅

**Redémarre l'instance** :
```
Actions → Instance state → Start instance
```

---

## 📊 Étape 6 : Métriques et monitoring

### 6.1. Métriques du Load Balancer

1. Sélectionne ton Load Balancer
2. Onglet **"Monitoring"**
3. Tu peux voir :
   - **Request count** : nombre de requêtes
   - **Target response time** : temps de réponse
   - **Healthy host count** : nombre d'instances saines
   - **Unhealthy host count** : nombre d'instances défaillantes

### 6.2. Logs d'accès (optionnel)

Pour activer les logs :

1. Sélectionne le Load Balancer
2. Onglet **"Attributes"**
3. **Edit**
4. **Access logs** → **Enable**
5. Choisis un bucket S3 (à créer si besoin)

---

## 🔧 Configuration avancée (optionnel)

### Stickiness (sessions persistantes)

Si tu veux qu'un utilisateur reste sur la même instance :

1. Target Group → onglet **"Attributes"**
2. **Edit**
3. **Stickiness** → **Enable**
4. **Stickiness duration** : 86400 secondes (1 jour)

### Connection draining

Pour gérer proprement la fermeture des instances :

```yaml
Deregistration delay: 300 seconds
```

Les requêtes en cours ont 5 minutes pour se terminer avant l'arrêt de l'instance.

---

## 📋 Schéma de l'architecture actuelle

```
                     INTERNET
                         |
                         v
              [Application Load Balancer]
               webapp-prod-alb
              (Port 80 - HTTP)
                         |
               [Target Group: webapp-prod-tg]
                         |
         +---------------+---------------+
         |                               |
         v                               v
  [EC2 Instance 1]              [EC2 Instance 2]
  webapp-prod-ec2-web-01        webapp-prod-ec2-web-02
  AZ: eu-west-3a                AZ: eu-west-3b
  10.0.1.x                      10.0.2.x
  Health: Healthy               Health: Healthy
```

---

## 🆘 Troubleshooting

### Problème : "503 Service Temporarily Unavailable"

**Cause** : Aucune instance saine dans le Target Group

**Solution** :
```bash
1. Vérifie le Target Group → Targets
2. Si "Unhealthy" :
   - Vérifie qu'Apache tourne sur l'instance
   - Vérifie le Security Group (port 80 autorisé depuis le SG du ALB)
   - Vérifie que la page /index.php existe et fonctionne
```

---

### Problème : Health check échoue

**Causes** :
1. Security Group ne permet pas le trafic depuis le Load Balancer
2. Apache ne tourne pas
3. Page de health check introuvable

**Solutions** :
```bash
# Se connecter à l'instance
ssh -i ta-cle.pem ec2-user@IP

# Vérifier Apache
sudo systemctl status httpd

# Tester localement
curl http://localhost

# Vérifier les logs
sudo tail -f /var/log/httpd/access_log
# Tu dois voir les requêtes du health check
```

---

### Problème : Load Balancer ne se crée pas

**Erreur** : "You must specify subnets from at least 2 availability zones"

**Solution** : Assure-toi de sélectionner des subnets dans **2 AZ différentes**

---

## 📝 Commandes AWS CLI (référence)

### Lister les Load Balancers

```bash
aws elbv2 describe-load-balancers --region eu-west-3
```

### Lister les Target Groups

```bash
aws elbv2 describe-target-groups --region eu-west-3
```

### Voir l'état des targets

```bash
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:...
```

---

## ✅ Checklist de validation

- [ ] Target Group créé avec health checks configurés
- [ ] Application Load Balancer créé et actif
- [ ] Load Balancer dans 2 Availability Zones
- [ ] Au moins 1 instance avec statut "Healthy"
- [ ] Application accessible via le DNS du Load Balancer
- [ ] (Optionnel) Teste avec 2 instances et vérifie la répartition

---

## 🎯 Récapitulatif

Tu as maintenant :
- ✅ Un Load Balancer qui répartit le trafic
- ✅ Un Target Group avec health checks
- ✅ Une architecture haute disponibilité

---

## 🚀 Prochaine étape

**Direction [06_auto_scaling.md](06_auto_scaling.md)** pour automatiser le scaling !

---

**💡 Astuce** : Note le DNS du Load Balancer, c'est l'URL publique de ton application !