# Se Connecter à la BD 🔗

Accéder à votre BD depuis votre PC.

---

## 🎯 À quoi ça sert ?

Créer tables, insérer données, requêtes SQL.

---

## 🖼️ DASHBOARD AWS

### Récupérer infos

```
1. RDS > Databases > my-database
2. Notez :
   - Endpoint : my-database.c123.eu-west-3.rds.amazonaws.com
   - Port : 3306
   - Username : admin
   - Password : YourPassword123!
```

---

## 💻 CLI - MySQL (Windows/Mac/Linux)

### Installer MySQL CLI (si besoin)

```
Windows : 
  https://dev.mysql.com/downloads/mysql/

Mac :
  brew install mysql-client

Linux :
  sudo apt install mysql-client
```

### Se connecter

```bash
mysql -h my-database.c123.eu-west-3.rds.amazonaws.com \
       -u admin \
       -p

# Puis entrez password
```

### Quelques commandes

```sql
-- Voir les BD
SHOW DATABASES;

-- Créer une BD
CREATE DATABASE myapp;

-- Utiliser une BD
USE myapp;

-- Créer table
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100)
);

-- Insérer données
INSERT INTO users (name, email) VALUES ('Tom', 'tom@example.com');

-- Voir données
SELECT * FROM users;

-- Quitter
EXIT;
```

---

## 💻 PostgreSQL (CLI)

### Installer psql (si besoin)

```
Windows : https://www.postgresql.org/download/windows/
Mac : brew install postgresql
Linux : sudo apt install postgresql-client
```

### Se connecter

```bash
psql -h my-database.c123.eu-west-3.rds.amazonaws.com \
     -U admin \
     -d testdb

# Puis entrez password
```

---

## 🖥️ GUI - pgAdmin (PostgreSQL)

```
1. Téléchargez pgAdmin : https://www.pgadmin.org/
2. Add Server
3. Host : endpoint RDS
4. Username : admin
5. Password : votre password
6. Connect ✓
```

---

## 🖥️ GUI - MySQL Workbench

```
1. Téléchargez MySQL Workbench
2. Nouvelle connexion
3. Host : endpoint RDS
4. Username : admin
5. Password : votre password
6. Test Connection ✓
```

---

## 📌 NOTES

- **Endpoint** : regardez RDS console
- **Port** : 3306 (MySQL), 5432 (PostgreSQL)
- **Security Group** : doit autoriser port depuis votre IP
- **Timeout** : si connexion refuse, vérifier security group

---

[⬅️ Retour](./README.md)
