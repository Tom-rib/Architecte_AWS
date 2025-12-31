# Job 3 : RDS Masterclass 🗄️

Mémo rapide pour créer et gérer des bases de données relationnelles sur AWS.

**Format :** Dashboard AWS (clics) + CLI (commandes)

---

## 📚 TABLE DES MATIÈRES

### Concepts de base
- **[RDS Basics](./01-RDS-Basics.md)** - Qu'est-ce que RDS ?
- **[Types de BD](./01-RDS-Basics.md#types)** - MySQL, PostgreSQL, MariaDB, Oracle, SQL Server
- **[Instance Types](./01-RDS-Basics.md#types-instances)** - db.t3.micro, db.t3.small, etc

### Déploiement
- **[Créer Instance RDS](./02-Create-Instance.md)** - Lancer une BD
- **[Se Connecter](./03-Connect-Database.md)** - Accéder à la BD (MySQL CLI, pgAdmin, etc)
- **[Security Groups](./04-Security-Groups.md)** - Port 3306/5432

### Gestion et Maintenance
- **[Backups & Snapshots](./05-Backups.md)** - Sauvegardes automatiques
- **[Parameter Groups](./06-Parameters.md)** - Configurations BD
- **[Multi-AZ](./07-Multi-AZ.md)** - Haute disponibilité
- **[Maintenance](./09-Maintenance.md)** - Mises à jour, patches
- **[Restore](./10-Restore.md)** - Restaurer depuis snapshot

### Sécurité et Performance
- **[Encryption](./11-Encryption.md)** - Chiffrement données
- **[IAM Authentication](./12-IAM-Authentication.md)** - Authentification IAM tokens
- **[Monitoring](./08-Monitoring.md)** - CloudWatch metrics et alertes

### Référence
- **[CLI Commands](./CLI-Commands.md)** - Toutes les commandes AWS
- **[Troubleshooting](./13-RDS-Troubleshooting.md)** - Problèmes courants

---

## 🎯 FLUX RAPIDE

```
1. Créer Instance RDS (02-Create-Instance.md)
2. Configurer Security Group (04-Security-Groups.md)
3. Se connecter (03-Connect-Database.md)
4. Activer backups auto (05-Backups.md)
5. (Optionnel) Activer Multi-AZ (07-Multi-AZ.md)
6. (Optionnel) Monitoring (08-Monitoring.md)
```

---

## 💡 CONCEPTS CLÉS

| Concept | Utilité | Coût |
|---------|---------|------|
| **Instance RDS** | Base de données managée | db.t3.micro = gratuit |
| **Backups** | Sauvegardes auto | 35GB gratuit |
| **Snapshots** | Copies manuelles | 0.023€/GB stocké |
| **Multi-AZ** | Haute disponibilité | Double coût (2 régions) |
| **Encryption** | Chiffrement données | Gratuit |
| **Monitoring** | Métriques CloudWatch | Gratuit (basic) |
| **Parameter Group** | Configuration | Gratuit |

---

## 🚀 BESOIN D'AIDE RAPIDE ?

**Débutant ?**
- Qu'est-ce que RDS ? → [01-RDS-Basics.md](./01-RDS-Basics.md)
- Créer une BD ? → [02-Create-Instance.md](./02-Create-Instance.md)
- Se connecter ? → [03-Connect-Database.md](./03-Connect-Database.md)

**Intermédiaire ?**
- Sauvegarder ? → [05-Backups.md](./05-Backups.md)
- Sécuriser ? → [04-Security-Groups.md](./04-Security-Groups.md)
- Haute disponibilité ? → [07-Multi-AZ.md](./07-Multi-AZ.md)

**Avancé ?**
- Encryption ? → [11-Encryption.md](./11-Encryption.md)
- IAM Auth ? → [12-IAM-Authentication.md](./12-IAM-Authentication.md)
- Monitoring ? → [08-Monitoring.md](./08-Monitoring.md)

**Problèmes ?**
- Connexion DB ? → [13-RDS-Troubleshooting.md](./13-RDS-Troubleshooting.md)

**CLI ?** → [CLI-Commands.md](./CLI-Commands.md)

---

## 📌 NOTES IMPORTANTES

- **Port MySQL** : 3306 (par défaut)
- **Port PostgreSQL** : 5432 (par défaut)
- **Free tier** : db.t3.micro + 20 GB storage + 35 GB backups
- **Backup gratuit** : 35 GB (au-delà = payant)
- **Maintenance window** : fenêtre de maintenance automatique
- **Région** : eu-west-3 (Paris)

---

## 🎁 BONUS

### Cas d'usage courants

| Cas | Solution |
|-----|----------|
| Petite app | db.t3.micro (gratuit) |
| App modérée | db.t3.small + Multi-AZ |
| Production | db.m5.large + Multi-AZ + Encryption |
| Backup long terme | Snapshots + S3 export |
| High availability | Multi-AZ + Read replicas |

---

**Créé pour maîtriser RDS rapidement** 📚

[⬅️ Retour au Job 1](../Job1-EC2/README.md) | [⬅️ Retour au Job 2](../Job2-S3/README.md)
