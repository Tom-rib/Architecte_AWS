# IAM Authentication - Accès Sécurisé 🔑

Utiliser tokens IAM au lieu de passwords.

---

## 🎯 À quoi ça sert ?

- Pas de passwords stockés
- Tokens temporaires (15 min)
- Audit trail dans CloudTrail
- Accès granulaire IAM

---

## 🖼️ DASHBOARD AWS

### Activer IAM authentication

```
1. RDS > Databases > my-database > Modify
2. Database authentication : IAM database authentication
3. Enable ✓
4. Save ✓
```

### Créer IAM user pour RDS

```
1. IAM > Users > Create user
2. Attach policy : AmazonRDSIAMDatabaseAccess
3. Create ✓
```

---

## 💻 CLI

### Générer token d'authentification

```bash
aws rds generate-db-auth-token \
  --hostname my-database.c123456.eu-west-3.rds.amazonaws.com \
  --port 3306 \
  --region eu-west-3 \
  --username iamuser
```

### Se connecter avec token

```bash
TOKEN=$(aws rds generate-db-auth-token \
  --hostname my-database.c123456.eu-west-3.rds.amazonaws.com \
  --port 3306 \
  --region eu-west-3 \
  --username iamuser)

mysql -h my-database.c123456.eu-west-3.rds.amazonaws.com \
       -u iamuser \
       --password="$TOKEN" \
       --enable-cleartext-plugin
```

---

## 📌 NOTES

- **Token** : valide 15 min
- **SSL obligatoire** : IAM auth = toujours SSL
- **Audit** : logs CloudTrail
- **Performance** : impact minimal

---

[⬅️ Retour](./README.md)
