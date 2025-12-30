# 03 - ECR Concepts Complets 📦

Guide complet pour comprendre Amazon Elastic Container Registry (ECR).

---

## 🎯 QU'EST-CE QUE ECR ?

**ECR** = Elastic Container Registry = Registry Docker privé géré par AWS.

```
ECR = "Docker Hub privé dans AWS"
```

**En simple :**
- Vous stockez vos images Docker
- Privé et sécurisé
- Intégré avec ECS, EKS, Lambda
- Pas besoin de gérer un registry

---

## 🆚 ECR VS AUTRES REGISTRIES

| Aspect | ECR | Docker Hub | Self-hosted |
|--------|-----|------------|-------------|
| **Gestion** | AWS | Docker Inc | Vous |
| **Privé** | ✅ Par défaut | Payant | ✅ |
| **Intégration AWS** | ✅ Native | ❌ | ❌ |
| **IAM** | ✅ | ❌ | ❌ |
| **Coût** | Stockage + Transfer | Free/Payant | Infrastructure |
| **Scan vulnérabilités** | ✅ Inclus | Payant | À configurer |
| **Disponibilité** | 99.9% SLA | Variable | Votre responsabilité |

---

## 🏗️ ARCHITECTURE ECR

```
┌─────────────────────────────────────────────────────────────┐
│                         ECR                                  │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                 REPOSITORY: ma-app                   │    │
│  │  ┌───────────────────────────────────────────────┐  │    │
│  │  │ IMAGES                                         │  │    │
│  │  │                                                │  │    │
│  │  │  ┌─────────┐  ┌─────────┐  ┌─────────┐       │  │    │
│  │  │  │ :v1.0.0 │  │ :v1.1.0 │  │ :latest │       │  │    │
│  │  │  │ 150 MB  │  │ 152 MB  │  │ = v1.1.0│       │  │    │
│  │  │  └─────────┘  └─────────┘  └─────────┘       │  │    │
│  │  │                                                │  │    │
│  │  │  Layers (partagés entre images)               │  │    │
│  │  │  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐         │  │    │
│  │  │  │ L1 │ │ L2 │ │ L3 │ │ L4 │ │ L5 │         │  │    │
│  │  │  └────┘ └────┘ └────┘ └────┘ └────┘         │  │    │
│  │  └───────────────────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              REPOSITORY: api-backend                 │    │
│  │  ...                                                 │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## 📝 VOCABULAIRE ECR

| Terme | Définition |
|-------|------------|
| **Registry** | Compte AWS = 1 registry privé |
| **Repository** | Collection d'images (1 par app) |
| **Image** | Version taguée d'une app |
| **Tag** | Identifiant d'une image (v1.0, latest) |
| **Digest** | Hash SHA256 unique de l'image |
| **Layer** | Couche de l'image (partageable) |
| **Manifest** | Métadonnées de l'image |

---

## 🔗 URI D'UNE IMAGE ECR

```
<account-id>.dkr.ecr.<region>.amazonaws.com/<repository>:<tag>
```

**Exemple :**
```
123456789012.dkr.ecr.eu-west-3.amazonaws.com/ma-app:v1.0.0
```

**Composants :**
| Partie | Valeur | Description |
|--------|--------|-------------|
| Account ID | 123456789012 | Votre compte AWS |
| Region | eu-west-3 | Région AWS |
| Repository | ma-app | Nom du repo |
| Tag | v1.0.0 | Version |

---

## 🔐 AUTHENTIFICATION ECR

### Comment ça marche ?

1. AWS CLI génère un token (valide 12h)
2. Docker utilise ce token pour push/pull

### Commande d'authentification

```bash
# Générer token et login Docker
aws ecr get-login-password --region eu-west-3 | \
  docker login --username AWS --password-stdin \
  123456789012.dkr.ecr.eu-west-3.amazonaws.com
```

**Sortie attendue :**
```
Login Succeeded
```

### Token details

| Propriété | Valeur |
|-----------|--------|
| Durée | 12 heures |
| Username | Toujours `AWS` |
| Scope | Tous les repos du compte |

---

## 🏷️ STRATÉGIES DE TAGGING

### Bonnes pratiques

| Tag | Utilisation | Exemple |
|-----|-------------|---------|
| **Semantic version** | Production | `v1.2.3` |
| **Git SHA** | Traçabilité | `abc123def` |
| **latest** | Dernière version | `latest` |
| **Environment** | Par env | `prod`, `staging` |
| **Date** | Builds quotidiens | `2024-01-15` |

### Recommandation

```bash
# Tag avec version ET commit
docker tag ma-app:latest 123456789012.dkr.ecr.eu-west-3.amazonaws.com/ma-app:v1.2.3
docker tag ma-app:latest 123456789012.dkr.ecr.eu-west-3.amazonaws.com/ma-app:abc123
docker tag ma-app:latest 123456789012.dkr.ecr.eu-west-3.amazonaws.com/ma-app:latest

# Push tous les tags
docker push 123456789012.dkr.ecr.eu-west-3.amazonaws.com/ma-app --all-tags
```

---

## 🔒 TAG IMMUTABILITY

### Sans immutabilité (défaut)

```
Push ma-app:v1.0.0 → Image A
Push ma-app:v1.0.0 → Image B (écrase A!)
```

### Avec immutabilité

```
Push ma-app:v1.0.0 → Image A
Push ma-app:v1.0.0 → ERREUR! Tag existe déjà
```

### Activer l'immutabilité

**Dashboard :**
Repository > Settings > Image tag mutability > IMMUTABLE

**CLI :**
```bash
aws ecr put-image-tag-mutability \
  --repository-name ma-app \
  --image-tag-mutability IMMUTABLE
```

**Recommandation :** Activer pour production

---

## 🧹 LIFECYCLE POLICIES

### Problème

Sans nettoyage, les images s'accumulent :
- Coût de stockage augmente
- Difficile de trouver les bonnes versions

### Solution : Lifecycle Policies

Règles automatiques pour supprimer les vieilles images.

### Exemples de règles

**Garder seulement les 10 dernières images :**
```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 10 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

**Supprimer images non-taguées après 1 jour :**
```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Delete untagged images",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

**Garder `latest` et `prod`, supprimer le reste après 30 jours :**
```json
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep latest and prod forever",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["latest", "prod"],
        "countType": "imageCountMoreThan",
        "countNumber": 9999
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Delete old images",
      "selection": {
        "tagStatus": "any",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
```

---

## 🔍 IMAGE SCANNING

### Types de scan

| Type | Déclenchement | Coût |
|------|---------------|------|
| **Basic** | Push ou manuel | Gratuit |
| **Enhanced** | Continu | Payant |

### Basic Scanning

Détecte les vulnérabilités CVE dans les packages OS.

**Activer scan on push :**
```bash
aws ecr put-image-scanning-configuration \
  --repository-name ma-app \
  --image-scanning-configuration scanOnPush=true
```

### Voir les résultats

**CLI :**
```bash
aws ecr describe-image-scan-findings \
  --repository-name ma-app \
  --image-id imageTag=latest
```

**Résultat :**
```json
{
  "imageScanFindings": {
    "findings": [
      {
        "severity": "HIGH",
        "name": "CVE-2023-xxxx",
        "description": "...",
        "uri": "https://..."
      }
    ],
    "findingSeverityCounts": {
      "HIGH": 2,
      "MEDIUM": 5,
      "LOW": 10
    }
  }
}
```

---

## 🔐 PERMISSIONS IAM

### Pour push (CI/CD, développeurs)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "arn:aws:ecr:eu-west-3:123456789012:repository/ma-app"
    }
  ]
}
```

### Pour pull only (ECS Task Execution Role)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ],
      "Resource": "arn:aws:ecr:eu-west-3:123456789012:repository/*"
    }
  ]
}
```

**Policy AWS gérée :** `AmazonEC2ContainerRegistryReadOnly`

---

## 💰 COÛTS ECR

### Composants tarifés

| Composant | Prix (eu-west-3) |
|-----------|------------------|
| **Stockage** | 0.10 €/GB/mois |
| **Transfer OUT** | 0.09 €/GB (vers internet) |
| **Transfer IN** | GRATUIT |
| **Transfer intra-région** | GRATUIT |

### Free Tier

- **500 MB** stockage par mois
- **Toujours gratuit** (pas limité à 12 mois)

### Optimiser les coûts

1. **Lifecycle policies** : Supprimer vieilles images
2. **Multi-stage builds** : Images plus petites
3. **Layers partagés** : Base images communes
4. **Même région** : Éviter transfer cross-region

---

## 🚀 WORKFLOW TYPIQUE

```
┌─────────────────────────────────────────────────────────────┐
│                    DÉVELOPPEUR LOCAL                         │
│                                                              │
│  1. Écrire code                                              │
│  2. docker build -t ma-app .                                 │
│  3. docker tag ma-app ECR_URI:tag                           │
│  4. aws ecr get-login-password | docker login               │
│  5. docker push ECR_URI:tag                                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                         ECR                                  │
│                                                              │
│  • Image stockée                                             │
│  • Scan automatique                                          │
│  • Prête à être déployée                                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     ECS / FARGATE                            │
│                                                              │
│  • Pull image depuis ECR                                    │
│  • Démarrer conteneur                                       │
│  • Servir l'application                                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 🛡️ BONNES PRATIQUES

### Sécurité

- ✅ Activer scan on push
- ✅ Utiliser tag immutability en prod
- ✅ IAM policies restrictives
- ✅ Pas de secrets dans les images
- ✅ VPC Endpoint pour trafic privé

### Organisation

- ✅ 1 repository par application
- ✅ Naming convention : `{team}-{app}-{component}`
- ✅ Tags sémantiques (v1.2.3)
- ✅ Lifecycle policies configurées

### Performance

- ✅ Images légères (Alpine, distroless)
- ✅ Multi-stage builds
- ✅ Même région que ECS
- ✅ VPC Endpoint pour éviter NAT

---

## ✅ CHECKLIST ECR

```
□ Repository créé avec bon nom
□ Scan on push activé
□ Tag immutability (prod)
□ Lifecycle policy configurée
□ IAM permissions configurées
□ VPC Endpoint (si private subnets)
□ Stratégie de tagging définie
```

---

## 🔗 LIENS

- **ECS** → [01-ECS-Concepts-Complets.md](./01-ECS-Concepts-Complets.md)
- **Fargate** → [02-Fargate-Concepts-Complets.md](./02-Fargate-Concepts-Complets.md)
- **Push vers ECR** → [06-Push-ECR.md](./06-Push-ECR.md)
- **CLI Commands** → [CLI-Commands.md](./CLI-Commands.md)

---

[⬅️ Retour au README](./README.md)
