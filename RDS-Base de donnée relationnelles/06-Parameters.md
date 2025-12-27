# Parameter Groups - Configuration 🔧

Configurer le moteur BD (MySQL, PostgreSQL, etc).

---

## 🎯 À quoi ça sert ?

- max_connections, timeout, etc
- Performance tuning
- Comportement BD

---

## 🖼️ DASHBOARD AWS

### Voir Parameter Group

```
1. RDS > Parameter Groups
2. Voir groupes
3. Cliquez pour voir paramètres
```

### Créer custom Parameter Group

```
1. RDS > Parameter Groups > Create parameter group
2. Parameter group family : mysql8.0
3. Group name : my-params
4. Create ✓
```

### Modifier paramètre

```
1. Parameter Groups > Sélectionnez groupe
2. Edit parameters
3. Cherchez paramètre (ex: max_connections)
4. Entrez valeur
5. Save ✓
```

### Appliquer à instance

```
1. RDS > Databases > my-database > Modify
2. DB parameter group : my-params
3. Save ✓
```

---

## 💻 CLI

### Créer Parameter Group

```bash
aws rds create-db-parameter-group \
  --db-parameter-group-name my-params \
  --db-parameter-group-family mysql8.0 \
  --description "Custom params"
```

### Modifier paramètre

```bash
aws rds modify-db-parameter-group \
  --db-parameter-group-name my-params \
  --parameters "ParameterName=max_connections,ParameterValue=1000,ApplyMethod=pending-reboot"
```

---

## 📌 NOTES

- **Paramètres** : spécifiques par engine
- **Reboot** : certains changements nécessitent reboot
- **Default** : ne peut pas être modifié (créer custom)

---

[⬅️ Retour](./README.md)
