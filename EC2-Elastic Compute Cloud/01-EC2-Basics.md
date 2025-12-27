# EC2 - Basics 🖥️

Serveur virtuel dans le cloud AWS. C'est une machine Linux/Windows que vous pouvez contrôler complètement.

---

## 🎯 À quoi ça sert ?

- Héberger applications web
- Tester des configurations
- Exécuter du code
- Servir du contenu
- Anything à la demande

---

## 🔍 Comparaison : Serveur physique vs EC2

| | Serveur physique | EC2 |
|---|---|---|
| **Installation** | Semaines | 5 min |
| **Coût initial** | €€€ | Pay-as-you-go |
| **Puissance** | Fixe | Scalable |
| **Maintenance** | Vous | AWS |
| **Localisation** | 1 lieu | 30+ régions |
| **Backup** | Manuel | Snapshots auto |

---

## 📊 Composants EC2

```
Instance EC2
├── Compute (CPU/RAM) → Instance type (t2.micro, m5.large, etc)
├── Storage (Disque) → EBS Volume (gp3, io1, etc)
├── Network (Réseau) → VPC, Subnet, Security Group
└── IP → Elastic IP (fixe) ou Public IP (change)
```

---

## 💰 Instance Types (pour débutants)

| Type | CPU | RAM | Cas d'usage | Coût/mois |
|---|---|---|---|---|
| **t2.micro** | 1 vCPU | 1 GB | Test, hobby | GRATUIT |
| **t2.small** | 1 vCPU | 2 GB | Petite app | ~10€ |
| **t2.medium** | 2 vCPU | 4 GB | App modérée | ~40€ |
| **m5.large** | 2 vCPU | 8 GB | Production | ~80€ |

---

## 🌍 Régions et Zones

```
Région (ex: eu-west-3 = Paris)
├── Zone A (eu-west-3a)
├── Zone B (eu-west-3b)
└── Zone C (eu-west-3c)
```

**Pourquoi plusieurs zones ?** Haute disponibilité = si une zone tombe, les autres restent opérationnelles.

---

## 🖼️ DASHBOARD AWS

### Créer une instance basique

```
1. EC2 > Instances > Launch instance
2. AMI : Debian 12 (ou Ubuntu 24.04)
3. Instance type : t2.micro
4. Key pair : aws_arch (créer si besoin)
5. Security Group : créer nouveau
   ✓ Port 22 (SSH) - Votre IP
   ✓ Port 80 (HTTP) - 0.0.0.0/0
   ✓ Port 443 (HTTPS) - 0.0.0.0/0
6. Storage : 20 GB
7. Launch ✓
```

### Voir vos instances

```
EC2 > Instances
- État : Running, Stopped, Terminated
- IP publique : pour SSH
- Instance type : t2.micro, etc
```

---

## 💻 CLI

### Lister les instances

```bash
aws ec2 describe-instances --region eu-west-3
```

### Créer une instance

```bash
aws ec2 run-instances \
  --image-id ami-0a1b2c3d4e5f6g7h8 \
  --instance-type t2.micro \
  --key-name aws_arch \
  --security-group-ids sg-0123456789abcdef0 \
  --region eu-west-3
```

### Arrêter une instance

```bash
aws ec2 stop-instances --instance-ids i-0123456789abcdef0
```

### Démarrer une instance

```bash
aws ec2 start-instances --instance-ids i-0123456789abcdef0
```

### Supprimer une instance

```bash
aws ec2 terminate-instances --instance-ids i-0123456789abcdef0
```

---

## 🔐 Security Groups

Firewall pour votre instance. Contrôle qui peut accéder à quoi.

| Port | Service | Source | Pourquoi |
|---|---|---|---|
| 22 | SSH | Votre IP | Administrer l'instance |
| 80 | HTTP | 0.0.0.0/0 | Site public |
| 443 | HTTPS | 0.0.0.0/0 | Site sécurisé |
| 3306 | MySQL | 10.0.0.0/8 | DB interne |

---

## 📝 NOTES

- **Always use Key Pair** pour SSH (pas de password)
- **Always restrict SSH** à votre IP (pas 0.0.0.0/0)
- **Always tag instances** (Name, Environment, Owner)
- **Arrêt vs Suppression** : Arrêt = garder, Suppression = adieu

---

[⬅️ Retour](./README.md)
