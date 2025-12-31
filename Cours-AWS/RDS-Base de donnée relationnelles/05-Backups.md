# Backups & Snapshots 💾

Sauvegarder votre BD.

---

## 🎯 À quoi ça sert ?

- Backups automatiques (quotidien)
- Snapshots manuels
- Restauration point-in-time
- Disaster recovery

---

## 📊 Comparaison

| | Backup auto | Snapshot | Copie manuelle |
|---|---|---|---|
| **Fréquence** | Quotidien | Manuel | Quand besoin |
| **Coût** | Gratuit (35 GB) | 0.023€/GB | Gratuit upload |
| **Rétention** | 7-35 jours | Permanent | Votre responsabilité |
| **Restore** | Point-in-time | Snapshot date | Manuel |

---

## 🖼️ DASHBOARD AWS

### Activer backups automatiques

```
1. RDS > Databases > my-database
2. Modify
3. Backup retention period : 7 (jours)
4. Backup window : 02:00-03:00 (UTC)
5. Save ✓
```

### Créer snapshot manuel

```
1. RDS > Databases > my-database
2. Actions > Take snapshot
3. Snapshot ID : my-database-backup-2024-12-26
4. Take snapshot ✓
5. Attendre "Status" = "Available"
```

### Voir snapshots

```
RDS > Snapshots
- Voir tous les snapshots
- Size, Created date
```

### Restaurer depuis snapshot

```
1. RDS > Snapshots > Sélectionnez
2. Actions > Restore DB instance
3. DB instance identifier : my-database-restored
4. Create ✓
5. Attendre 5-10 min
```

---

## 💻 CLI

### Créer snapshot

```bash
aws rds create-db-snapshot \
  --db-instance-identifier my-database \
  --db-snapshot-identifier my-database-backup-2024-12-26
```

### Lister snapshots

```bash
aws rds describe-db-snapshots
```

### Restaurer snapshot

```bash
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier my-database-restored \
  --db-snapshot-identifier my-database-backup-2024-12-26
```

---

## 📌 NOTES

- **Backup gratuit** : 35 GB
- **Coût** : au-delà gratuit = 0.023€/GB/mois
- **Rétention** : max 35 jours
- **PITR** : Point-In-Time Restore (dernière semaine)

---

[⬅️ Retour](./README.md)
