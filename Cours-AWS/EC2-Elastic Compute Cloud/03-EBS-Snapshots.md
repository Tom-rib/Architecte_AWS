# EBS Snapshots - Sauvegarder les disques 💾

Copie point-in-time du disque (volume EBS) d'une instance.

---

## 🎯 À quoi ça sert ?

- Backup du disque avant changements
- Cloner un disque
- Migrer vers une autre région
- Archiver des données
- Disaster recovery

---

## 📊 Comparaison

| | Snapshot | AMI | Backup manuel |
|---|---|---|---|
| **Sauvegarde** | Juste disque | OS + apps + disque | Rien |
| **Temps** | 2-5 min | 5-10 min | - |
| **Restore** | Créer volume | Créer instance | Manuel |
| **Coût** | 0.05€/GB/mois | 0.05€/GB/mois | 0 |
| **Cas** | Backup disque | Full instance | Paresse |

---

## 🖼️ DASHBOARD AWS

### Créer un Snapshot

```
1. EC2 > Elastic Block Store > Volumes
2. Sélectionnez le volume
3. Clic droit > Create snapshot
4. Description: Backup before upgrade
5. Create snapshot ✓
6. Attendre 2-5 min (taille du disque)
```

### Voir vos Snapshots

```
EC2 > Elastic Block Store > Snapshots
- État : Completed
- Progress : 100%
- Size : disque sauvegardé
```

### Créer volume depuis Snapshot

```
1. Snapshots > Sélectionnez
2. Clic droit > Create volume from snapshot
3. Availability Zone : eu-west-3a
4. Size : même taille (ou plus grand)
5. Create volume ✓
6. Attacher à instance : Attach volume
```

### Supprimer un Snapshot

```
Snapshots > Sélectionnez
Clic droit > Delete snapshot
✓ Fait
```

---

## 💻 CLI

### Créer un Snapshot

```bash
aws ec2 create-snapshot \
  --volume-id vol-0123456789abcdef0 \
  --description "Backup before upgrade"
```

### Lister les Snapshots

```bash
aws ec2 describe-snapshots --owner-ids self
```

### Créer volume depuis Snapshot

```bash
aws ec2 create-volume \
  --snapshot-id snap-0123456789abcdef0 \
  --availability-zone eu-west-3a
```

### Attacher volume à instance

```bash
aws ec2 attach-volume \
  --volume-id vol-0123456789abcdef0 \
  --instance-id i-0123456789abcdef0 \
  --device /dev/sdf
```

### Supprimer Snapshot

```bash
aws ec2 delete-snapshot --snapshot-id snap-0123456789abcdef0
```

---

## 📌 NOTES

- **Snapshots incrémentiels** = changements depuis dernier snapshot (plus rapide)
- **Stockage en S3** = données cryptées, répliquées
- **Partager snapshots** = risque de sécurité, soyez prudent
- **Durée de vie** = Gardez les importants, supprimez les vieux

---

[⬅️ Retour](./README.md)
