# 🧪 07. Tests et Validation

> **Objectif** : Tester et valider le bon fonctionnement de toute l'infrastructure.  
> **Durée** : 45 minutes  
> **Niveau** : ⭐⭐ Intermédiaire

---

## 🎯 Ce que tu vas tester

- ✅ Accès à l'application via le Load Balancer
- ✅ Répartition de charge entre instances
- ✅ Haute disponibilité (simulation de panne)
- ✅ Auto Scaling (montée et descente en charge)
- ✅ Health Checks

---

## 🌐 Test 1 : Accès via le Load Balancer

### 1.1. Récupérer l'URL du Load Balancer

1. Console EC2 → **"Load Balancers"**
2. Sélectionne `webapp-prod-alb`
3. Copie le **DNS name** :
   ```
   webapp-prod-alb-123456789.eu-west-3.elb.amazonaws.com
   ```

### 1.2. Tester l'accès web

1. Ouvre ton navigateur
2. Va sur : `http://[DNS-DU-LOAD-BALANCER]`
3. ✅ La page web doit s'afficher avec les informations de l'instance

### 1.3. Vérifier les informations affichées

La page doit montrer :
- ✅ Instance ID
- ✅ Availability Zone
- ✅ IP Privée
- ✅ Statut opérationnel

---

## ⚖️ Test 2 : Répartition de charge

### 2.1. Test manuel

1. Ouvre l'URL du Load Balancer
2. Rafraîchis la page plusieurs fois (F5)
3. ✅ L'**Instance ID doit changer** (alternance entre les instances)

**Exemple attendu** :
```
Rafraîchissement 1 : Instance ID: i-0abc123...
Rafraîchissement 2 : Instance ID: i-0def456...
Rafraîchissement 3 : Instance ID: i-0abc123...
```

### 2.2. Test automatique avec curl

```bash
# Test avec 10 requêtes
for i in {1..10}; do
  curl -s http://[DNS-DU-LOAD-BALANCER] | grep "Instance ID"
  sleep 1
done
```

✅ Tu devrais voir différents Instance IDs

### 2.3. Test de charge avec Apache Bench

**Installation (sur ton PC Linux/Mac) :**

```bash
# Linux
sudo apt install apache2-utils

# Mac
brew install apr-util
```

**Lancer le test :**

```bash
# 1000 requêtes, 10 en parallèle
ab -n 1000 -c 10 http://[DNS-DU-LOAD-BALANCER]/

# Résultats à observer :
# - Requests per second
# - Time per request
# - Failed requests (doit être 0)
```

---

## 🛑 Test 3 : Haute disponibilité (Failover)

### 3.1. Identifier les instances

1. Console EC2 → **"Instances"**
2. Note les IDs des 2 instances de l'Auto Scaling Group

### 3.2. Simuler une panne

1. Sélectionne **une instance**
2. **Instance state** → **Stop instance**
3. Confirme l'arrêt

### 3.3. Vérifier le comportement

**Pendant l'arrêt (1-2 minutes) :**

1. Rafraîchis l'application dans le navigateur
2. ✅ L'application **reste accessible** (une seule instance suffit)
3. Tu ne vois plus que l'Instance ID de l'instance encore active

**Après 2-3 minutes :**

1. Console EC2 → **"Auto Scaling Groups"**
2. Sélectionne `webapp-prod-asg`
3. Onglet **"Activity"**
4. ✅ Tu devrais voir : "Launching a new EC2 instance"
5. L'Auto Scaling **remplace automatiquement** l'instance arrêtée

### 3.4. Vérifier le Target Group

1. Console EC2 → **"Target Groups"**
2. Sélectionne `webapp-prod-tg`
3. Onglet **"Targets"**
4. Vérifie :
   - Instance arrêtée : `Unhealthy` ou `Unused`
   - Nouvelle instance : `Initial` → `Healthy` après 1-2 min

### 3.5. Redémarrer l'instance arrêtée

```
Actions → Instance state → Start instance
```

---

## 📈 Test 4 : Auto Scaling (Scale Out)

### 4.1. Générer une charge CPU élevée

**Méthode 1 : Via stress-ng**

1. Connecte-toi à **toutes les instances** (ouvre plusieurs terminaux)

```bash
ssh -i ta-cle.pem ec2-user@IP-INSTANCE-1
ssh -i ta-cle.pem ec2-user@IP-INSTANCE-2
```

2. Sur chaque instance, installe et lance stress :

```bash
# Installer stress
sudo yum install -y stress-ng

# Lancer le test de charge (5 minutes, 2 cœurs CPU)
stress-ng --cpu 2 --timeout 300s --metrics-brief
```

### 4.2. Surveiller le scaling

1. Console CloudWatch → **"Alarms"** → **"All alarms"**
2. L'alarme CPU devrait passer en état **"In alarm"** ⚠️

3. Console EC2 → **"Auto Scaling Groups"**
4. Sélectionne `webapp-prod-asg`
5. Onglet **"Activity"**
6. ⏱️ Après 2-3 minutes, tu devrais voir :
   ```
   Launching a new EC2 instance: i-0xyz789
   ```

7. Onglet **"Automatic scaling"** → **"Activity history"**
8. Tu verras : "Alarm triggered, scaling out..."

### 4.3. Vérifier les nouvelles instances

1. Console EC2 → **"Instances"**
2. ✅ Tu devrais voir **3 à 5 instances** (selon la charge)
3. Toutes avec le tag `webapp-prod-asg-instance`

### 4.4. Vérifier le Load Balancer

1. Rafraîchis l'application plusieurs fois
2. ✅ Tu devrais voir les nouveaux Instance IDs apparaître

---

## 📉 Test 5 : Auto Scaling (Scale In)

### 5.1. Arrêter la charge

1. Sur chaque instance, arrête stress : `Ctrl+C`
2. Vérifie que le CPU redescend :

```bash
top
# CPU idle devrait être > 90%
```

### 5.2. Attendre le Scale In

⏱️ **Patience !** Le Scale In prend 5-10 minutes :

1. CloudWatch Alarm passe en **"OK"** ✅
2. Auto Scaling décide de retirer des instances
3. Cooldown period (temps de sécurité)
4. Instances terminées progressivement

### 5.3. Vérifier le retour à la normale

1. Console EC2 → **"Auto Scaling Groups"** → `webapp-prod-asg`
2. Onglet **"Activity"**
3. Tu devrais voir : "Terminating EC2 instance"
4. Le nombre d'instances revient à **2** (desired capacity)

---

## 🔍 Test 6 : Health Checks

### 6.1. Simuler un serveur web défaillant

1. Connecte-toi à une instance :

```bash
ssh -i ta-cle.pem ec2-user@IP-INSTANCE
```

2. Arrête Apache :

```bash
sudo systemctl stop httpd
```

### 6.2. Observer la réaction

**Après 30-60 secondes** :

1. Console EC2 → **"Target Groups"** → `webapp-prod-tg`
2. L'instance avec Apache arrêté passe en **"Unhealthy"** ❌
3. Le Load Balancer ne lui envoie plus de trafic

**Après 2-3 minutes** :

1. L'Auto Scaling détecte l'instance "Unhealthy"
2. Il **termine l'instance** et en lance une **nouvelle**
3. Onglet **"Activity"** : tu vois le remplacement

### 6.3. Redémarrer Apache (si tu veux garder l'instance)

```bash
sudo systemctl start httpd
```

L'instance redevient **"Healthy"** après 30-60 secondes.

---

## 📊 Test 7 : Métriques CloudWatch

### 7.1. Consulter les métriques

1. Console CloudWatch → **"Dashboards"** → **"Automatic dashboards"**
2. Sélectionne **"EC2"**
3. Filtre par `webapp-prod-asg`

### 7.2. Métriques importantes

| Métrique | Description | Valeur normale |
|----------|-------------|----------------|
| **CPUUtilization** | Utilisation CPU moyenne | < 50% |
| **NetworkIn** | Trafic entrant | Variable |
| **NetworkOut** | Trafic sortant | Variable |
| **StatusCheckFailed** | Checks en échec | 0 |

### 7.3. Alarmes

1. CloudWatch → **"Alarms"** → **"All alarms"**
2. Vérifie que toutes les alarmes sont en état **"OK"** ✅

---

## 📝 Test 8 : Logs et diagnostic

### 8.1. Logs Apache

Sur une instance :

```bash
# Logs d'accès (requêtes HTTP)
sudo tail -f /var/log/httpd/access_log

# Logs d'erreurs
sudo tail -f /var/log/httpd/error_log
```

### 8.2. Logs système

```bash
# Logs système
sudo journalctl -u httpd -f

# Logs cloud-init (démarrage)
sudo cat /var/log/cloud-init-output.log
```

### 8.3. Métriques système

```bash
# Utilisation CPU/RAM
htop  # ou : top

# Espace disque
df -h

# Processus Apache
ps aux | grep httpd

# Connexions réseau
sudo netstat -tuln | grep :80
```

---

## ✅ Checklist complète de validation

### Infrastructure réseau
- [ ] VPC créé et fonctionnel
- [ ] 2 subnets publics dans 2 AZ
- [ ] Internet Gateway attaché
- [ ] Routes configurées correctement

### Sécurité
- [ ] Security Group ALB (ports 80/443 depuis Internet)
- [ ] Security Group Web (port 80 depuis ALB, SSH depuis mon IP)
- [ ] Pas de ports inutiles ouverts

### Instances et application
- [ ] AMI créée avec Apache et PHP
- [ ] Application web accessible et fonctionnelle
- [ ] Métadonnées EC2 affichées sur la page

### Load Balancer
- [ ] ALB créé et actif
- [ ] Target Group avec health checks configurés
- [ ] Toutes les instances "Healthy"
- [ ] Répartition de charge fonctionne

### Auto Scaling
- [ ] Launch Template créé
- [ ] Auto Scaling Group opérationnel (min: 2, max: 5)
- [ ] Scaling policies configurées (CPU > 50%)
- [ ] Scale Out testé avec succès
- [ ] Scale In testé avec succès

### Haute disponibilité
- [ ] Application reste accessible même avec une instance down
- [ ] Auto Scaling remplace automatiquement les instances défaillantes
- [ ] Health checks fonctionnent correctement

### Monitoring
- [ ] Métriques CloudWatch visibles
- [ ] Alarmes configurées
- [ ] Logs accessibles et exploitables

---

## 🎯 Résultats attendus

Ton infrastructure doit être capable de :

✅ **Disponibilité** : Rester accessible même si une instance tombe  
✅ **Scalabilité** : S'adapter automatiquement à la charge  
✅ **Performance** : Répartir le trafic efficacement  
✅ **Résilience** : Se réparer automatiquement  
✅ **Observabilité** : Fournir des métriques et logs  

---

## 📸 Captures d'écran recommandées

Pour ta présentation finale, prends des captures de :

1. Architecture VPC (schéma ou console)
2. Instances EC2 en cours d'exécution
3. Load Balancer avec targets "Healthy"
4. Auto Scaling Group configuration
5. Graphiques CloudWatch (CPU, réseau)
6. Page web affichant les infos d'instance
7. Activity history montrant un scaling event

---

## 🚀 Prochaine étape

**Direction [08_surveillance.md](08_surveillance_cloudwatch.md)** pour approfondir le monitoring avec CloudWatch !

---

**💡 Astuce** : Documente tous tes tests avec des screenshots, ils seront utiles pour ton rapport final !