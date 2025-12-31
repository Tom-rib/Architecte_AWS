# Replication - Copie Auto Multi-Région 🔄

Copier automatiquement objets vers un autre bucket (même région ou autre région).

---

## 🎯 À quoi ça sert ?

- Disaster recovery (région de secours)
- Haute disponibilité
- Conformité (données dupliquées)
- Latence réduite (utilisateurs proches)
- Backup automatique

---

## 📊 Comparaison

| | Replication | Backup manuel | Snapshot |
|---|---|---|---|
| **Fréquence** | Real-time | A la demande | Planifié |
| **Cible** | Autre bucket | Extérieur | Local |
| **Cas** | DR multi-région | Important documents | Ponctuel |
| **Coût** | Transfer | 0 | 0 |

---

## 🖼️ DASHBOARD AWS

### Activer Replication

```
1. Bucket source > Management > Replication rules
2. Create replication rule
3. Rule name : replicate-all
4. Status : Enabled
5. Source : All objects (ou filter par prefix)
6. Destination bucket : sélectionnez bucket cible
7. IAM role : créer nouvelle (ou utiliser existante)
8. Replication time control : disabled (ou enabled pour sync)
9. Create rule ✓
10. Destination bucket doit avoir versioning activé
```

### Voir les réplications

```
Replication rules > sélectionnez
- Status
- Last modified
- Objects replicated
```

---

## 💻 CLI

### Créer Replication Rule

```bash
aws s3api put-bucket-replication \
  --bucket source-bucket \
  --replication-configuration file://replication.json

# replication.json :
{
  "Role": "arn:aws:iam::123456789:role/replication-role",
  "Rules": [
    {
      "Status": "Enabled",
      "Priority": 1,
      "Filter": {"Prefix": ""},
      "Destination": {
        "Bucket": "arn:aws:s3:::destination-bucket",
        "ReplicationTime": {
          "Status": "Disabled"
        }
      }
    }
  ]
}
```

### Lister Replication Rules

```bash
aws s3api get-bucket-replication --bucket source-bucket
```

### Supprimer Replication

```bash
aws s3api delete-bucket-replication --bucket source-bucket
```

---

## 📌 NOTES

- **Versioning** : OBLIGATOIRE sur les deux buckets
- **Real-time** : réplication en quelques secondes
- **One-way** : source → destination (pas bidirectionnel)
- **Coût** : transfert data entre régions
- **IAM role** : doit avoir permissions s3:GetObject et s3:PutObject

---

[⬅️ Retour](./README.md)
