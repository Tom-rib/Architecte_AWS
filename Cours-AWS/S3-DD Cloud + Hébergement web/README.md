# Job 2 : S3 Masterclass 🪣

Mémo rapide pour stocker, partager et héberger des fichiers sur S3 avec CloudFront.

**Format :** Dashboard AWS (clics) + CLI (commandes)

---

## 📚 TABLE DES MATIÈRES

### Concepts de base
- **[S3 Basics](./01-S3-Basics.md)** - Qu'est-ce que S3 ?
- **[Buckets](./02-Buckets.md)** - Créer et gérer des buckets
- **[Upload](./03-Upload.md)** - Uploader des fichiers
- **[Permissions](./04-Permissions.md)** - Policies et sécurité

### Hébergement et Distribution
- **[Static Website](./05-Static-Website.md)** - Site web statique sur S3
- **[CloudFront](./06-CloudFront.md)** - Distribution CDN globale

### Gestion des Données
- **[Versioning](./07-Versioning.md)** - Contrôle de version des fichiers
- **[Lifecycle](./08-Lifecycle.md)** - Archivage et suppression auto
- **[Replication](./09-Replication.md)** - Copie auto vers autre bucket/région

### Sécurité Avancée
- **[Access Points](./10-Access-Points.md)** - Points d'accès simplifiés
- **[Object Lock](./11-Object-Lock.md)** - Immuabilité WORM
- **[Server Logging](./12-Server-Logging.md)** - Logs des requêtes

### Performance et Intégrations
- **[Transfer Acceleration](./13-Transfer-Acceleration.md)** - Upload rapide CloudFront
- **[Intelligent-Tiering](./14-Intelligent-Tiering.md)** - Archivage auto
- **[CORS](./15-CORS.md)** - Partage cross-origin
- **[Event Notifications](./16-Event-Notifications.md)** - SNS/SQS/Lambda
- **[Metrics & Monitoring](./17-Metrics-Monitoring.md)** - CloudWatch + alertes

### Référence
- **[CLI Commands](./CLI-Commands.md)** - Toutes les commandes AWS

---

## 🎯 FLUX RAPIDE

```
BASES :
1. Créer un Bucket (02-Buckets.md)
2. Uploader des fichiers (03-Upload.md)
3. Configurer les permissions (04-Permissions.md)

OPTIONNEL :
4. Hébergement statique (05-Static-Website.md)
5. CloudFront CDN (06-CloudFront.md)
6. Versioning (07-Versioning.md)
7. Lifecycle policies (08-Lifecycle.md)

AVANCÉ :
8. Access Points (10-Access-Points.md)
9. Replication (09-Replication.md)
10. Event Notifications (16-Event-Notifications.md)
11. Monitoring (17-Metrics-Monitoring.md)
```

---

## 💡 CONCEPTS CLÉS

| Concept | Utilité | Coût |
|---------|---------|------|
| **Bucket** | Conteneur de fichiers | Gratuit |
| **Upload** | Ajouter fichiers | 0.023€/GB |
| **Permissions** | Contrôler accès | Gratuit |
| **Static Website** | Héberger site HTML | Gratuit (5GB) |
| **CloudFront** | CDN global | 0.085€/GB |
| **Versioning** | Historique fichiers | 0.023€/GB/version |
| **Lifecycle** | Archivage auto | 0.004€/GB (Glacier) |
| **Access Points** | Points d'accès | Gratuit |
| **Replication** | Copie auto | Coût transfer |
| **Monitoring** | Métriques | Gratuit (basic) |

---

## 🚀 BESOIN D'AIDE RAPIDE ?

**Débutant ?**
- Créer un bucket ? → [02-Buckets.md](./02-Buckets.md)
- Uploader des fichiers ? → [03-Upload.md](./03-Upload.md)
- Sécuriser un bucket ? → [04-Permissions.md](./04-Permissions.md)

**Intermédiaire ?**
- Héberger un site web ? → [05-Static-Website.md](./05-Static-Website.md)
- Distribuer mondialement ? → [06-CloudFront.md](./06-CloudFront.md)
- Versioning & backup ? → [07-Versioning.md](./07-Versioning.md)

**Avancé ?**
- Points d'accès ? → [10-Access-Points.md](./10-Access-Points.md)
- Réplication multi-région ? → [09-Replication.md](./09-Replication.md)
- Monitoring en temps réel ? → [17-Metrics-Monitoring.md](./17-Metrics-Monitoring.md)
- Events & Lambda ? → [16-Event-Notifications.md](./16-Event-Notifications.md)

- Utiliser CLI ? → [CLI-Commands.md](./CLI-Commands.md)

---

## 📌 NOTES IMPORTANTES

- **Région par défaut :** `eu-west-3` (Paris)
- **Noms de buckets** : UNIQUES au monde (pas déjà utilisés)
- **Uploads gratuits** : entrée gratuite, sortie payante
- **Sécurité par défaut** : buckets PRIVÉS (vous modifiez explicitement)
- **CloudFront** : toujours utiliser pour performance
- **Access Points** : simplifient permissions pour gros buckets
- **Replication** : copie auto asynchrone (pas synchrone)
- **Monitoring** : CloudWatch metrics par défaut, requestmetrics payant

---

## 🎁 BONUS

### Cas d'usage courants

| Cas | Solution |
|-----|----------|
| Sauvegarder documents | Bucket privé |
| Partager fichiers publiquement | Bucket public + lien |
| Héberger site web | Static Website |
| CDN global | CloudFront |
| Backup versionnés | Versioning + Lifecycle |
| Archivage long terme | Glacier |
| Multi-région DR | Replication |
| Monitoring santé | Metrics + CloudWatch |
| Workflow automatisé | Event Notifications |

---

**Créé pour maîtriser S3 completement** 📚

[⬅️ Retour au Job 1](../Job1-EC2/README.md)

