# Maintenance - Mises à jour 🔨

Appliquer patches et mises à jour.

---

## 🎯 À quoi ça sert ?

- Sécurité (patches)
- Performance (nouveautés)
- Bug fixes
- AWS gère pour vous

---

## 🖼️ DASHBOARD AWS

### Voir maintenance window

```
1. RDS > Databases > my-database
2. Maintenance and backups section
3. Maintenance window : jour/heure
```

### Appliquer mise à jour

```
1. RDS > Databases > my-database > Modify
2. Engine version : sélectionnez nouvelle version
3. Apply immediately : Yes (ou maintenir window)
4. Save ✓
5. Redémarrage (quelques min)
```

---

## 💻 CLI

### Appliquer upgrade

```bash
aws rds modify-db-instance \
  --db-instance-identifier my-database \
  --engine-version 8.0.35 \
  --apply-immediately
```

---

## 📌 NOTES

- **Maintenance window** : jour/heure défini
- **Auto** : AWS applique auto dans window
- **Downtime** : quelques secondes à quelques min
- **Multi-AZ** : failover = zéro downtime

---

[⬅️ Retour](./README.md)
