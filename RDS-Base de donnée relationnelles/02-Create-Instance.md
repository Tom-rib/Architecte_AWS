# Créer une Instance RDS 🚀

Lancer votre première base de données.

---

## 🎯 À quoi ça sert ?

Créer une BD MySQL/PostgreSQL en 5 min.

---

## 🖼️ DASHBOARD AWS

### Créer Instance RDS

```
1. RDS > Databases > Create database
2. Standard create (ou Easy create = plus basique)
```

### Étape 1 : Engine

```
- Engine type : MySQL
  (ou PostgreSQL si préférez)
- Version : 8.0.latest (automatique)
```

### Étape 2 : Template

```
- Free tier
  (sélectionne db.t3.micro gratuit)
```

### Étape 3 : Settings

```
- DB instance identifier : my-database
- Master username : admin
- Master password : YourPassword123!
- Confirm password : YourPassword123!
```

### Étape 4 : Instance

```
- Instance class : db.t3.micro (gratuit) ✓
- Allocated storage : 20 GB (gratuit)
- Storage type : gp3
```

### Étape 5 : Connectivity

```
- VPC : default
- Public accessible : Yes
  (pour tester depuis PC)
- Create new security group : Yes
```

### Étape 6 : Database options

```
- Initial database name : testdb
- Backup retention : 7 days (auto)
- Encryption : Disable (pour l'instant)
- Enhanced monitoring : Disable
```

### Créer

```
Cliquez "Create database" ✓
Attendre 5-10 min
```

### Récupérer endpoint

```
1. RDS > Databases > my-database
2. Notez :
   - Endpoint : my-database.c123456.eu-west-3.rds.amazonaws.com
   - Port : 3306
```

---

## 💻 CLI

### Créer Instance RDS

```bash
aws rds create-db-instance \
  --db-instance-identifier my-database \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --master-username admin \
  --master-user-password YourPassword123! \
  --allocated-storage 20 \
  --storage-type gp3 \
  --publicly-accessible \
  --region eu-west-3
```

### Lister instances

```bash
aws rds describe-db-instances
```

### Récupérer endpoint

```bash
aws rds describe-db-instances \
  --db-instance-identifier my-database \
  --query 'DBInstances[0].Endpoint'
```

---

## 📌 NOTES

- **Création** : 5-10 min (normal)
- **Endpoint** : regarder "Status" = "Available" avant d'utiliser
- **Port** : 3306 pour MySQL, 5432 pour PostgreSQL
- **Gratuit** : db.t3.micro + 20 GB + 35 GB backups

---

[⬅️ Retour](./README.md)
