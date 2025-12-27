# Load Balancer - Répartir le trafic ⚖️

Distribue les requêtes entre plusieurs instances.

---

## 🎯 À quoi ça sert ?

- Répartir trafic entre 2+ instances
- Éviter surcharge d'une instance
- Haute disponibilité (si une tombe, autres continuent)
- HTTPS + certificats SSL
- Health checks automatiques

---

## 📊 Types

| | Application LB | Network LB | Classic LB |
|---|---|---|---|
| **Couche** | L7 (App) | L4 (Transport) | Ancien |
| **Débit** | Moyen | Très haut | Faible |
| **Latence** | Normal | Ultra-low | Normal |
| **Cas** | Sites web (recommandé) | Jeux, streaming | Legacy |

**Pour ce job : Application LB**

---

## 🖼️ DASHBOARD AWS

### Créer un Load Balancer

```
1. EC2 > Load Balancers > Create load balancer
2. Type : Application Load Balancer
3. Name : debian-alb
```

### Étape 1 : Network

```
- Scheme : Internet-facing (public)
- IP address type : IPv4
- Subnets :
  ✓ eu-west-3a
  ✓ eu-west-3b
  ✓ eu-west-3c
```

### Étape 2 : Security

```
- Security group :
  ✓ Port 80 (HTTP)
  ✓ Port 443 (HTTPS)
```

### Étape 3 : Listener (port d'écoute)

```
Ajouter listener :
- Port : 80
- Protocol : HTTP
- Forward to : target group (créer nouveau)
  Name : debian-targets
  Type : Instances
  Protocol : HTTP
  Port : 80
  Health check :
    Path : /index.php
    Interval : 30 sec
    Timeout : 5 sec
    Success codes : 200
```

### Créer

```
Cliquez "Create load balancer" ✓
Attendre 2-3 min
```

### Voir les infos

```
Load Balancers > Sélectionnez
- DNS name : debian-alb-123456.eu-west-3.elb.amazonaws.com
- Status : Active
```

### Attacher ASG

```
1. Auto Scaling Groups > debian-asg
2. Onglet "Load balancing"
3. Attach load balancer > Target groups
4. Sélectionnez : debian-targets
5. Attach ✓
```

---

## 💻 CLI

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

### Lister Targets

```bash
aws elbv2 describe-target-health \
  --target-group-arn arn:aws:elasticloadbalancing:...
```

---

## 📌 NOTES

- **DNS name** : unique, AWS génère automatiquement
- **Target Group** : groupement d'instances (peut contenir ASG ou instances spécifiques)
- **Health check** : LB supprime instances "Unhealthy"
- **Stickiness** : force requêtes d'un client sur même instance (optionnel)

---

[⬅️ Retour](./README.md)
