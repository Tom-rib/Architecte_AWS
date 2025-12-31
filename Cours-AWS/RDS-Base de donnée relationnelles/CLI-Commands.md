# CLI Commands - Référence complète 💻

Toutes les commandes AWS CLI pour RDS.

---

## 📌 Configuration

```bash
aws configure
# AWS Access Key ID: YOUR_KEY
# AWS Secret Access Key: YOUR_SECRET
# Default region: eu-west-3
```

---

## 🗄️ INSTANCES RDS

### Créer Instance

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

### Voir détails instance

```bash
aws rds describe-db-instances \
  --db-instance-identifier my-database
```

### Récupérer endpoint

```bash
aws rds describe-db-instances \
  --db-instance-identifier my-database \
  --query 'DBInstances[0].Endpoint.Address' \
  --output text
```

### Modifier instance

```bash
aws rds modify-db-instance \
  --db-instance-identifier my-database \
  --allocated-storage 30 \
  --apply-immediately
```

### Redémarrer instance

```bash
aws rds reboot-db-instance \
  --db-instance-identifier my-database
```

### Supprimer instance

```bash
aws rds delete-db-instance \
  --db-instance-identifier my-database \
  --skip-final-snapshot
```

---

## 💾 BACKUPS & SNAPSHOTS

### Créer snapshot

```bash
aws rds create-db-snapshot \
  --db-instance-identifier my-database \
  --db-snapshot-identifier my-backup-2024-12-26
```

### Lister snapshots

```bash
aws rds describe-db-snapshots
```

### Restaurer depuis snapshot

```bash
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier my-database-restored \
  --db-snapshot-identifier my-backup-2024-12-26
```

### Restaurer point-in-time

```bash
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier my-database \
  --target-db-instance-identifier my-database-pitr \
  --restore-time 2024-12-26T10:00:00Z
```

### Voir automated backups

```bash
aws rds describe-db-instances \
  --db-instance-identifier my-database \
  --query 'DBInstances[0].[BackupRetentionPeriod,LatestRestorableTime]'
```

---

## 🔒 SECURITY

### Ajouter security group

```bash
aws rds modify-db-instance \
  --db-instance-identifier my-database \
  --vpc-security-group-ids sg-0123456789abcdef0 \
  --apply-immediately
```

### Voir security groups

```bash
aws rds describe-db-instances \
  --db-instance-identifier my-database \
  --query 'DBInstances[0].VpcSecurityGroups'
```

---

## ⚙️ PARAMETERS

### Créer parameter group

```bash
aws rds create-db-parameter-group \
  --db-parameter-group-name my-params \
  --db-parameter-group-family mysql8.0 \
  --description "Custom parameters"
```

### Lister parameter groups

```bash
aws rds describe-db-parameter-groups
```

### Voir paramètres

```bash
aws rds describe-db-parameters \
  --db-parameter-group-name my-params
```

### Modifier paramètre

```bash
aws rds modify-db-parameter-group \
  --db-parameter-group-name my-params \
  --parameters "ParameterName=max_connections,ParameterValue=1000,ApplyMethod=pending-reboot"
```

---

## 🔄 MULTI-AZ

### Activer Multi-AZ

```bash
aws rds modify-db-instance \
  --db-instance-identifier my-database \
  --multi-az \
  --apply-immediately
```

### Tester failover

```bash
aws rds reboot-db-instance \
  --db-instance-identifier my-database \
  --force-failover
```

---

## 📊 MONITORING

### Voir métriques CPU

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=my-database \
  --start-time 2024-12-24T00:00:00Z \
  --end-time 2024-12-26T00:00:00Z \
  --period 3600 \
  --statistics Average
```

### Voir métriques mémoire

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name FreeableMemory \
  --dimensions Name=DBInstanceIdentifier,Value=my-database \
  --start-time 2024-12-24T00:00:00Z \
  --end-time 2024-12-26T00:00:00Z \
  --period 3600 \
  --statistics Average
```

---

## 🔐 ENCRYPTION

### Créer instance chiffrée

```bash
aws rds create-db-instance \
  --db-instance-identifier my-database \
  --storage-encrypted \
  --kms-key-id arn:aws:kms:eu-west-3:123456789:key/12345678 \
  ...
```

---

## 🔑 IAM AUTHENTICATION

### Générer token

```bash
aws rds generate-db-auth-token \
  --hostname my-database.c123456.eu-west-3.rds.amazonaws.com \
  --port 3306 \
  --region eu-west-3 \
  --username iamuser
```

---

## 📡 CONNECTIVITY

### Tester connexion (Linux/Mac)

```bash
# MySQL
mysql -h my-database.c123456.eu-west-3.rds.amazonaws.com \
       -u admin \
       -p

# PostgreSQL
psql -h my-database.c123456.eu-west-3.rds.amazonaws.com \
     -U admin \
     -d testdb
```

---

[⬅️ Retour](./README.md)
