# Restore - Restauration 🔄

Restaurer BD depuis snapshot ou point-in-time.

---

## 🎯 À quoi ça sert ?

- Récupérer données supprimées accidentellement
- Cloner BD pour test
- Reverter modifications

---

## 🖼️ DASHBOARD AWS

### Restaurer depuis snapshot

```
1. RDS > Snapshots > Sélectionnez
2. Actions > Restore DB instance
3. DB instance identifier : my-database-v2
4. Create ✓
5. Attendre 5-10 min
```

### Restaurer point-in-time (PITR)

```
1. RDS > Automated backups
2. Cherchez instance
3. Actions > Restore to point in time
4. Restore time : sélectionnez moment
5. DB instance identifier : my-database-pitr
6. Create ✓
```

---

## 💻 CLI

### Restaurer snapshot

```bash
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier my-database-v2 \
  --db-snapshot-identifier my-database-backup-2024-12-26
```

### Restaurer PITR

```bash
aws rds restore-db-instance-to-point-in-time \
  --source-db-instance-identifier my-database \
  --target-db-instance-identifier my-database-pitr \
  --restore-time 2024-12-26T10:00:00Z
```

---

## 📌 NOTES

- **Snapshot** : toujours disponible
- **PITR** : jusqu'à 35 jours
- **Restore time** : 5-10 min
- **Nouvelle instance** : crée BD complètement nouvelle

---

[⬅️ Retour](./README.md)
