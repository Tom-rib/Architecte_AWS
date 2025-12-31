# Lifecycle - Archivage Auto ♻️

Supprimer ou archiver fichiers automatiquement selon l'âge.

---

## 🎯 À quoi ça sert ?

- Archiver données anciennes (moins cher)
- Supprimer fichiers temporaires (économies)
- Compliance (durées de rétention)
- Automatiser gestion stockage

---

## 📊 Comparaison : Stockage

| | S3 Standard | S3 Glacier | Suppression |
|---|---|---|---|
| **Coût** | 0.023€ / GB | 0.004€ / GB | 0 |
| **Accès** | Instant | 1-5 min | N/A |
| **Cas** | Données chaudes | Archivage long terme | Temp files |
| **Durée** | Jours/semaines | Mois/années | Heures |

---

## 🖼️ DASHBOARD AWS

### Créer Lifecycle Policy

```
1. Bucket > Management > Lifecycle policies
2. Create lifecycle configuration
3. Add rule :
   - Name : archive-old-files
   - Apply to : All objects OR Filter by prefix
4. Transitions :
   ☑ Transition to Standard-IA : 30 days
   ☑ Transition to Glacier : 90 days
   ☑ Expiration : 365 days (supprimer)
5. Create ✓
```

### Voir les policies

```
Bucket > Management > Lifecycle policies
- Règles existantes
- Récapitulatif actions
```

---

## 💻 CLI

### Créer Lifecycle Policy

```bash
aws s3api put-bucket-lifecycle-configuration \
  --bucket mon-bucket \
  --lifecycle-configuration file://lifecycle.json
```

**Exemple lifecycle.json :**

```json
{
  "Rules": [
    {
      "Id": "archive-old-files",
      "Status": "Enabled",
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        }
      ],
      "Expiration": {
        "Days": 365
      }
    }
  ]
}
```

### Lister Lifecycle Policies

```bash
aws s3api get-bucket-lifecycle-configuration --bucket mon-bucket
```

### Supprimer Lifecycle Policy

```bash
aws s3api delete-bucket-lifecycle --bucket mon-bucket
```

---

## 📌 NOTES

- **Transition** : date optimale = quand données rarement accédées
- **Expiration** : suppression permanente (pas de récupération)
- **Glacier** : récupération lente (1-5 min) mais très bon marché
- **Filter** : appliquer à fichiers spécifiques (prefix, tag, etc)
- **Coût** : transition gratuite, mais changement de classe storage

---

[⬅️ Retour](./README.md)
