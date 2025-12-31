# Job 3 : RDS - Base de données relationnelle 🗄️

> Déployer une base de données managée avec sauvegardes automatiques

---

## 🎯 Objectif

Déployer une base de données relationnelle gérée (MySQL ou PostgreSQL) avec des sauvegardes automatiques et des snapshots pour un stockage sécurisé des données.

---

## 📦 Ressources AWS Utilisées

| Service | Rôle |
|---------|------|
| RDS | Base de données managée |
| MySQL / PostgreSQL | Moteur de base de données |
| Security Groups | Pare-feu |
| IAM | Permissions |

---

## 💰 Coûts

| Service | Free Tier |
|---------|-----------|
| RDS db.t3.micro | 750h/mois gratuit |
| Stockage | 20 GB gratuit |
| Backups | 20 GB gratuit |

✅ **Entièrement gratuit pour ce projet**

---

# Étape 1 : Créer une instance RDS

## 🖥️ Dashboard

```
1. RDS → Databases → Create database

2. Database creation method : Standard create

3. Engine options :
   - Engine type : MySQL (ou PostgreSQL)
   - Version : MySQL 8.0.35 (dernière)

4. Templates : Free tier ✓

5. Settings :
   - DB instance identifier : my-database
   - Master username : admin
   - Master password : MyPassword123!@#
   ⚠️ Notez ce mot de passe !

6. Instance configuration :
   - DB instance class : db.t3.micro
   - ☑ Include previous generation classes

7. Storage :
   - Storage type : gp3
   - Allocated storage : 20 GiB
   - ☐ Enable storage autoscaling (décocher)

8. Connectivity :
   - VPC : Default VPC
   - Public access : Yes
   - VPC security group : Create new
   - New security group name : rds-sg

9. Database authentication : Password authentication

10. Additional configuration :
    - Initial database name : testdb
    - ☑ Enable automated backups
    - Backup retention period : 7 days
    - ☑ Enable deletion protection

11. Create database ✓
```

## 💻 CLI

```bash
# Créer le Security Group pour RDS
RDS_SG=$(aws ec2 create-security-group \
  --group-name rds-sg \
  --description "Security group for RDS" \
  --query 'GroupId' \
  --output text \
  --region eu-west-3)

# Autoriser MySQL (port 3306)
aws ec2 authorize-security-group-ingress \
  --group-id $RDS_SG \
  --protocol tcp \
  --port 3306 \
  --cidr 0.0.0.0/0 \
  --region eu-west-3

# Créer l'instance RDS
aws rds create-db-instance \
  --db-instance-identifier my-database \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --engine-version 8.0.35 \
  --master-username admin \
  --master-user-password 'MyPassword123!@#' \
  --allocated-storage 20 \
  --storage-type gp3 \
  --db-name testdb \
  --vpc-security-group-ids $RDS_SG \
  --backup-retention-period 7 \
  --publicly-accessible \
  --deletion-protection \
  --region eu-west-3
```

⏳ **Attendre 5-10 minutes** que l'instance soit disponible.

---

# Étape 2 : Configurer le Security Group

## 🖥️ Dashboard

```
1. EC2 → Security Groups → rds-sg

2. Inbound rules → Edit inbound rules

3. Add rule :
   - Type : MySQL/Aurora
   - Protocol : TCP
   - Port : 3306
   - Source : 0.0.0.0/0 (ou votre IP pour plus de sécurité)

4. Save rules ✓
```

⚠️ **En production** : Restreindre à votre IP ou à un Security Group spécifique !

## 💻 CLI

```bash
# Voir les règles actuelles
aws ec2 describe-security-groups \
  --group-ids $RDS_SG \
  --query 'SecurityGroups[0].IpPermissions' \
  --region eu-west-3

# Ajouter une règle (si pas déjà fait)
aws ec2 authorize-security-group-ingress \
  --group-id $RDS_SG \
  --protocol tcp \
  --port 3306 \
  --cidr $(curl -s ifconfig.me)/32 \
  --region eu-west-3
```

---

# Étape 3 : Récupérer l'Endpoint

## 🖥️ Dashboard

```
1. RDS → Databases → my-database

2. Onglet "Connectivity & security"

3. Copiez l'Endpoint :
   my-database.cxxxxx.eu-west-3.rds.amazonaws.com
```

## 💻 CLI

```bash
# Récupérer l'endpoint
aws rds describe-db-instances \
  --db-instance-identifier my-database \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text \
  --region eu-west-3
```

---

# Étape 4 : Se connecter à la base de données

## Option A : AWS Query Editor (Recommandé)

```
1. RDS → Query Editor

2. Connect to database :
   - Database instance : my-database
   - Database username : admin
   - Password : MyPassword123!@#
   - Database name : testdb

3. Connect ✓

4. Exécuter des requêtes SQL directement !
```

## Option B : MySQL CLI

### Installation

```bash
# Linux (Debian/Ubuntu)
sudo apt install mysql-client

# Mac
brew install mysql-client

# Windows
choco install mysql
```

### Connexion

```bash
mysql -h my-database.cxxxxx.eu-west-3.rds.amazonaws.com \
      -u admin \
      -p \
      testdb

# Entrez le mot de passe quand demandé
```

### Commandes SQL de test

```sql
-- Voir les bases de données
SHOW DATABASES;

-- Utiliser testdb
USE testdb;

-- Créer une table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insérer des données
INSERT INTO users (name, email) VALUES 
    ('Alice', 'alice@example.com'),
    ('Bob', 'bob@example.com'),
    ('Charlie', 'charlie@example.com');

-- Lire les données
SELECT * FROM users;

-- Compter les utilisateurs
SELECT COUNT(*) as total FROM users;
```

## Option C : DBeaver (Interface graphique)

```
1. Téléchargez DBeaver : https://dbeaver.io/

2. New Connection → MySQL

3. Host : my-database.cxxxxx.eu-west-3.rds.amazonaws.com
   Port : 3306
   Database : testdb
   Username : admin
   Password : MyPassword123!@#

4. Test Connection → OK

5. Finish ✓
```

---

# Étape 5 : Configurer les sauvegardes

## 🖥️ Dashboard - Backups automatiques

```
1. RDS → Databases → my-database

2. Modify

3. Backup :
   - Backup retention period : 7 days
   - Backup window : 03:00-04:00 UTC
   - ☑ Copy tags to snapshots

4. Continue → Apply immediately

5. Modify DB instance ✓
```

## 🖥️ Dashboard - Snapshot manuel

```
1. RDS → Databases → my-database

2. Actions → Take snapshot

3. Snapshot name : my-database-backup-2024-01-15

4. Take snapshot ✓

5. RDS → Snapshots → Vérifier le status "Available"
```

## 💻 CLI

```bash
# Créer un snapshot manuel
aws rds create-db-snapshot \
  --db-instance-identifier my-database \
  --db-snapshot-identifier my-database-backup-$(date +%Y-%m-%d) \
  --region eu-west-3

# Lister les snapshots
aws rds describe-db-snapshots \
  --db-instance-identifier my-database \
  --query 'DBSnapshots[*].[DBSnapshotIdentifier,Status,SnapshotCreateTime]' \
  --output table \
  --region eu-west-3

# Restaurer depuis un snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier my-database-restored \
  --db-snapshot-identifier my-database-backup-2024-01-15 \
  --region eu-west-3
```

---

# Étape 6 : Monitoring

## 🖥️ Dashboard

```
1. RDS → Databases → my-database

2. Onglet "Monitoring"

3. Métriques importantes :
   - CPU Utilization
   - Database Connections
   - Free Storage Space
   - Read/Write IOPS
```

## 💻 CLI

```bash
# Voir les métriques CloudWatch
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=my-database \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%SZ) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
  --period 300 \
  --statistics Average \
  --region eu-west-3
```

---

# 🔧 Troubleshooting

## ❌ "Connection timed out"

```
1. Vérifiez que Public access = Yes
2. Vérifiez le Security Group (port 3306 ouvert)
3. Vérifiez que l'instance est "Available"
4. Vérifiez votre IP si source restreinte
```

## ❌ "Access denied for user"

```
1. Vérifiez le username (admin)
2. Vérifiez le mot de passe
3. Vérifiez le nom de la base de données
```

## ❌ "Unknown database"

```
1. La base testdb n'existe peut-être pas
2. Connectez-vous sans spécifier de base :
   mysql -h ENDPOINT -u admin -p
3. Puis : CREATE DATABASE testdb;
```

---

# 🧹 Nettoyage

```bash
# 1. Désactiver la protection contre la suppression
aws rds modify-db-instance \
  --db-instance-identifier my-database \
  --no-deletion-protection \
  --apply-immediately \
  --region eu-west-3

# 2. Attendre que la modification soit appliquée

# 3. Supprimer l'instance (sans snapshot final)
aws rds delete-db-instance \
  --db-instance-identifier my-database \
  --skip-final-snapshot \
  --region eu-west-3

# 4. Supprimer les snapshots manuels
aws rds delete-db-snapshot \
  --db-snapshot-identifier my-database-backup-2024-01-15 \
  --region eu-west-3

# 5. Supprimer le Security Group
aws ec2 delete-security-group \
  --group-id $RDS_SG \
  --region eu-west-3
```

---

## 📋 Informations de connexion

| Paramètre | Valeur |
|-----------|--------|
| Endpoint | my-database.cxxxxx.eu-west-3.rds.amazonaws.com |
| Port | 3306 |
| Username | admin |
| Database | testdb |
| Region | eu-west-3 |

---

## ✅ Checklist Finale

- [ ] Instance RDS créée (status: Available)
- [ ] Security Group configuré (port 3306)
- [ ] Connexion testée (Query Editor ou CLI)
- [ ] Table créée et données insérées
- [ ] Backups automatiques activés (7 jours)
- [ ] Snapshot manuel créé
- [ ] Deletion protection activée

---

[⬅️ Retour : Job2](./Job2_S3_CloudFront.md) | [➡️ Suite : Job4_Lambda_API.md](./Job4_Lambda_API.md)
