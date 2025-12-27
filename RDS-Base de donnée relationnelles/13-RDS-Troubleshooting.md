# Troubleshooting - Problèmes Courants 🔧

Dépannage RDS.

---

## ❌ Erreur : "Unable to connect"

### Causes possibles
- Security Group n'autorise pas port
- Instance pas encore disponible
- Network issue
- IP mauvaise

### Solutions
```
1. Vérifier Security Group :
   RDS > Databases > VPC security groups
   Port 3306 (MySQL) ou 5432 (PostgreSQL) ?

2. Vérifier statut :
   RDS > Databases > Status = Available ?

3. Vérifier endpoint :
   RDS console > copier endpoint exact

4. Tester connectivité :
   telnet endpoint 3306
```

---

## ❌ Erreur : "Access denied for user"

### Causes
- Username faux
- Password faux
- User n'existe pas

### Solutions
```
1. Vérifier credentials (username, password)
2. Créer user (si besoin)
   CREATE USER 'newuser'@'%' IDENTIFIED BY 'password';
3. Donner permissions
   GRANT ALL PRIVILEGES ON *.* TO 'newuser'@'%';
```

---

## ❌ Erreur : "Disk space full"

### Solutions
```
1. Vérifier espace :
   CloudWatch > FreeStorageSpace
2. Augmenter storage :
   RDS > Databases > Modify > Allocated storage
3. Nettoyer données
   DELETE old logs/data
```

---

## ❌ Erreur : "Too many connections"

### Solutions
```
1. Vérifier connexions :
   SHOW PROCESSLIST;
2. Augmenter max_connections :
   Parameter Group > max_connections
3. Fermer connections inutiles
```

---

## 📌 NOTES

- **Status Available** : instance prête
- **Status Creating** : attendre
- **Status Failed** : contacter AWS support
- **Security Group** : cause #1 des problèmes

---

[⬅️ Retour](./README.md)
