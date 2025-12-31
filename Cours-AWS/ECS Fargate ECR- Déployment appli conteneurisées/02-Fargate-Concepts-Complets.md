# 02 - Fargate Concepts Complets 🚀

Guide complet pour comprendre AWS Fargate - l'exécution serverless de conteneurs.

---

## 🎯 QU'EST-CE QUE FARGATE ?

**Fargate** = Moteur de calcul serverless pour conteneurs.

```
Fargate = "Exécuter des conteneurs sans gérer de serveurs"
```

**En simple :**
- Vous donnez une image Docker
- Fargate l'exécute
- Vous ne voyez jamais de serveur EC2
- Vous payez uniquement le temps d'exécution

---

## 🆚 FARGATE VS EC2

| Aspect | ECS + Fargate | ECS + EC2 |
|--------|---------------|-----------|
| **Gestion serveurs** | ❌ Aucune | ✅ Vous gérez |
| **Patching OS** | AWS | Vous |
| **Scaling infra** | Automatique | Manuel ou ASG |
| **Coût** | Par task (CPU+RAM/sec) | Par instance EC2 |
| **Prévisibilité coût** | Variable | Plus prévisible |
| **GPU** | ❌ Non supporté | ✅ Supporté |
| **Persistent storage** | EFS uniquement | EBS + EFS |
| **Placement control** | Limité | Total |
| **Complexité** | ⭐ Simple | ⭐⭐⭐ Complexe |

### Quand choisir Fargate ?

✅ **Fargate** si :
- Vous débutez avec les conteneurs
- Workloads variables/imprévisibles
- Vous ne voulez pas gérer d'infrastructure
- Applications stateless
- Microservices

✅ **EC2** si :
- Workloads prévisibles et constants
- Besoin de GPU
- Besoin de stockage EBS
- Contrôle total sur le placement
- Optimisation des coûts à grande échelle

---

## 💰 MODÈLE DE PRIX FARGATE

### Facturation

```
Coût = (vCPU/heure × heures) + (GB RAM/heure × heures)
```

**Prix eu-west-3 (Paris) :**

| Ressource | Prix/heure |
|-----------|------------|
| vCPU | ~0.04048 € |
| GB RAM | ~0.004445 € |

### Exemple de calcul

**Task avec 0.25 vCPU + 0.5 GB RAM pendant 24h :**

```
vCPU  : 0.25 × 0.04048 × 24 = 0.24 €
RAM   : 0.5 × 0.004445 × 24 = 0.05 €
Total : ~0.29 €/jour
```

### Free Tier

- **750 heures** Fargate par mois
- Pendant les **12 premiers mois**
- Équivalent : 1 task (0.25 vCPU + 0.5 GB) 24/7

---

## 🏗️ CONFIGURATIONS CPU/MEMORY

### Combinaisons valides

| CPU (vCPU) | Memory (GB) Options |
|------------|---------------------|
| 0.25 | 0.5, 1, 2 |
| 0.5 | 1, 2, 3, 4 |
| 1 | 2, 3, 4, 5, 6, 7, 8 |
| 2 | 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 |
| 4 | 8 à 30 |
| 8 | 16 à 60 |
| 16 | 32 à 120 |

### Recommandations par type d'app

| Type d'application | CPU | Memory |
|--------------------|-----|--------|
| API légère (Node.js) | 0.25 | 0.5 GB |
| API standard | 0.5 | 1 GB |
| Application web | 1 | 2 GB |
| Processing lourd | 2 | 4 GB |
| ML/Data processing | 4+ | 8+ GB |

---

## 🌐 NETWORKING FARGATE

### Mode réseau obligatoire : awsvpc

Chaque task Fargate :
- A sa propre **ENI** (Elastic Network Interface)
- A sa propre **IP privée**
- Peut avoir une **IP publique** (optionnel)

```
┌─────────────────────────────────────────┐
│                  VPC                     │
│  ┌─────────────────────────────────┐    │
│  │         Subnet                   │    │
│  │  ┌───────────┐  ┌───────────┐   │    │
│  │  │  Task 1   │  │  Task 2   │   │    │
│  │  │ ENI: eth0 │  │ ENI: eth0 │   │    │
│  │  │ IP: .10   │  │ IP: .11   │   │    │
│  │  └───────────┘  └───────────┘   │    │
│  └─────────────────────────────────┘    │
└─────────────────────────────────────────┘
```

### Configuration IP publique

**Public Subnet + IP publique :**
```json
{
  "networkConfiguration": {
    "awsvpcConfiguration": {
      "subnets": ["subnet-xxx"],
      "securityGroups": ["sg-xxx"],
      "assignPublicIp": "ENABLED"
    }
  }
}
```

**Private Subnet (recommandé prod) :**
```json
{
  "networkConfiguration": {
    "awsvpcConfiguration": {
      "subnets": ["subnet-private-xxx"],
      "securityGroups": ["sg-xxx"],
      "assignPublicIp": "DISABLED"
    }
  }
}
```

> ⚠️ Private subnet nécessite NAT Gateway pour accès internet (télécharger images ECR, etc.)

---

## 🔐 SÉCURITÉ FARGATE

### Security Groups

Chaque task a son propre Security Group :

```
┌─────────────────────────────────────┐
│         Security Group              │
├─────────────────────────────────────┤
│ INBOUND                             │
│ • Port 3000 from ALB SG             │
│ • Port 3000 from 10.0.0.0/16        │
├─────────────────────────────────────┤
│ OUTBOUND                            │
│ • All traffic (pour ECR, logs, etc) │
└─────────────────────────────────────┘
```

### IAM Roles

| Role | Utilisé par | Permissions |
|------|-------------|-------------|
| **Task Execution Role** | ECS Agent | Pull ECR, Write logs |
| **Task Role** | Votre app | Accès S3, DynamoDB, etc. |

### Isolation

- Chaque task = isolation au niveau **VM**
- Pas de partage de kernel entre tasks
- Équivalent sécurité d'une instance EC2 dédiée

---

## 💾 STOCKAGE FARGATE

### Options disponibles

| Type | Persistant | Partagé | Max Size |
|------|------------|---------|----------|
| **Ephemeral** | ❌ Non | ❌ Non | 200 GB |
| **EFS** | ✅ Oui | ✅ Oui | Illimité |
| **Bind mounts** | ❌ Non | Entre conteneurs | - |

### Stockage éphémère (par défaut)

```json
{
  "ephemeralStorage": {
    "sizeInGiB": 21
  }
}
```

- Par défaut : 20 GB
- Maximum : 200 GB
- **Perdu quand la task s'arrête**

### EFS (Elastic File System)

Pour stockage persistant :

```json
{
  "volumes": [
    {
      "name": "my-efs",
      "efsVolumeConfiguration": {
        "fileSystemId": "fs-xxx",
        "rootDirectory": "/",
        "transitEncryption": "ENABLED"
      }
    }
  ],
  "containerDefinitions": [
    {
      "mountPoints": [
        {
          "sourceVolume": "my-efs",
          "containerPath": "/data"
        }
      ]
    }
  ]
}
```

---

## 📊 PLATFORM VERSIONS

### Versions Fargate

| Version | Statut | Kernel |
|---------|--------|--------|
| **1.4.0** | Current | Linux 4.14 |
| **1.3.0** | Deprecated | Linux 4.14 |
| **LATEST** | Recommandé | Pointe vers 1.4.0 |

### Nouveautés 1.4.0

- Stockage éphémère jusqu'à 200 GB
- Support EFS
- Métriques container-level
- CAP_SYS_PTRACE pour debugging

**Toujours utiliser `LATEST` ou `1.4.0`**

---

## 🔄 SCALING FARGATE

### Auto Scaling

Fargate scale automatiquement en ajoutant/supprimant des tasks :

```
┌─────────────────────────────────────────────────┐
│                AUTO SCALING                      │
│                                                  │
│  Min: 1 task    Desired: 2 tasks    Max: 10 tasks│
│                                                  │
│  Trigger: CPU > 70% → Add task                  │
│  Trigger: CPU < 30% → Remove task               │
└─────────────────────────────────────────────────┘
```

### Types de scaling

| Type | Trigger | Exemple |
|------|---------|---------|
| **Target Tracking** | Métrique cible | CPU à 70% |
| **Step Scaling** | Seuils | Si CPU > 80% → +2 tasks |
| **Scheduled** | Horaire | 9h → 10 tasks, 18h → 2 tasks |

---

## ⏱️ TEMPS DE DÉMARRAGE

### Facteurs qui influencent

| Facteur | Impact | Optimisation |
|---------|--------|--------------|
| **Taille image** | 🔴 Élevé | Images légères (Alpine) |
| **Pull depuis ECR** | 🟡 Moyen | Même région, VPC endpoint |
| **ENI provisioning** | 🟡 Moyen | Subnets avec IPs disponibles |
| **App startup** | Variable | Optimiser votre code |

### Temps typiques

| Étape | Durée |
|-------|-------|
| ENI provisioning | 10-30 sec |
| Image pull (500 MB) | 15-45 sec |
| Container start | 1-5 sec |
| **Total** | **30 sec - 2 min** |

### Optimisations

1. **Images légères** : Utiliser Alpine, multi-stage builds
2. **VPC Endpoint ECR** : Évite passage par internet
3. **Réutiliser images** : Tag `:latest` évite re-pull
4. **Warm pools** : Pas disponible Fargate (EC2 uniquement)

---

## 🩺 HEALTH CHECKS

### Container Health Check

Dans le Dockerfile :
```dockerfile
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

Dans Task Definition :
```json
{
  "healthCheck": {
    "command": ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"],
    "interval": 30,
    "timeout": 5,
    "retries": 3,
    "startPeriod": 60
  }
}
```

### ALB Health Check

Configuré sur le Target Group :
- Path : `/health`
- Interval : 30 sec
- Healthy threshold : 2
- Unhealthy threshold : 3

---

## ✅ CHECKLIST FARGATE

```
□ Choisir CPU/Memory appropriés
□ Configurer VPC et subnets
□ Security Group avec ports corrects
□ IAM Task Execution Role
□ Logging CloudWatch configuré
□ Health checks définis
□ Stratégie de scaling planifiée
□ Stockage (éphémère ou EFS) décidé
```

---

## 🔗 LIENS

- **ECS** → [01-ECS-Concepts-Complets.md](./01-ECS-Concepts-Complets.md)
- **ECR** → [03-ECR-Concepts-Complets.md](./03-ECR-Concepts-Complets.md)
- **CLI Commands** → [CLI-Commands.md](./CLI-Commands.md)

---

[⬅️ Retour au README](./README.md)
