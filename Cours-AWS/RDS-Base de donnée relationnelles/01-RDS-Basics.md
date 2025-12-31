# RDS - Basics 🗄️

Relational Database Service = bases de données managées par AWS.

---

## 🎯 À quoi ça sert ?

- Héberger bases de données (MySQL, PostgreSQL, etc)
- AWS gère maintenance, backups, patches
- Accès depuis EC2, Lambda, etc
- Scalabilité automatique

---

## 📊 Comparaison : Base de données locale vs RDS

| | Base locale | EC2 MySQL | RDS |
|---|---|---|---|
| **Installation** | 1h | 30 min | 5 min |
| **Maintenance** | Vous | Vous | AWS |
| **Backups** | Manuel | Manuel | Auto ✓ |
| **Patch/Update** | Manuel | Manuel | Auto ✓ |
| **Scaling** | Hardware | Arrêt | Zero downtime |
| **Disponibilité** | Bas | Moyen | Haute ✓ |
| **Coût** | Hardware | EC2 + storage | Payant |

---

## 🗄️ Types de bases de données RDS

| | MySQL | PostgreSQL | MariaDB | Oracle | SQL Server |
|---|---|---|---|---|---|
| **Open source** | Oui | Oui | Oui | Non | Non |
| **Gratuit** | Oui | Oui | Oui | Non | Non |
| **Performance** | Bon | Très bon | Bon | Excellent | Excellent |
| **Cas d'usage** | Web apps | Data, JSON | MySQL alt | Enterprise | Enterprise |

**Pour ce job : MySQL ou PostgreSQL (gratuit)**

---

## 💾 Instance Types (pour débutants)

| Type | vCPU | RAM | Coût/mois | Cas |
|---|---|---|---|---|
| **db.t3.micro** | 2 vCPU | 1 GB | GRATUIT | Dev/test |
| **db.t3.small** | 2 vCPU | 2 GB | ~15€ | Petite app |
| **db.t3.medium** | 2 vCPU | 4 GB | ~30€ | App modérée |
| **db.m5.large** | 2 vCPU | 8 GB | ~200€ | Production |

---

## 🔐 Composants RDS

```
Instance RDS (serveur DB)
├── Database Engine (MySQL, PostgreSQL, etc)
├── Parameter Group (configuration)
├── Security Group (firewall port 3306/5432)
├── Subnet Group (VPC/réseau)
├── Automated Backups (quotidien)
├── Snapshots (manuels)
└── Multi-AZ (optionnel, haute disponibilité)
```

---

## 🖼️ DASHBOARD AWS

### Accéder à RDS

```
1. AWS Console > RDS
2. Databases > View all databases
3. Créer nouveau ou voir instances
```

---

## 💻 CLI

### Lister les instances RDS

```bash
aws rds describe-db-instances
```

### Créer instance RDS (voir 02-Create-Instance.md)

```bash
aws rds create-db-instance \
  --db-instance-identifier my-database \
  --db-instance-class db.t3.micro \
  --engine mysql
```

---

## 💡 CONCEPTS

- **DB Instance** : serveur database unique
- **Engine** : MySQL, PostgreSQL, etc
- **Parameter Group** : configuration du moteur
- **Security Group** : firewall (ports)
- **Backup** : copie auto quotidienne (35 GB gratuit)
- **Snapshot** : copie manuelle (coûte du stockage)
- **Multi-AZ** : 2 BD (une active, une standby)

---

## 📌 NOTES

- **Free tier** : 750 h/mois db.t3.micro + 20 GB storage
- **Backups gratuit** : 35 GB
- **Connexion** : endpoint RDS (ex: mydb.c123456.eu-west-3.rds.amazonaws.com)
- **Port MySQL** : 3306
- **Port PostgreSQL** : 5432

---

[⬅️ Retour](./README.md)
