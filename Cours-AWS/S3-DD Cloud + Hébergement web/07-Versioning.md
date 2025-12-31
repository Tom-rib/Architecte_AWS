# Versioning - Historique des Fichiers 📜

Garder historique de toutes les versions d'un fichier.

---

## 🎯 À quoi ça sert ?

- Restaurer anciennes versions
- Audit trail (qui a changé quoi)
- Protection accidentelle suppression
- Compliance réglementaire

---

## 📊 Comparaison

| | Sans versioning | Avec versioning |
|---|---|---|
| **Nouveau fichier** | Remplace l'ancien | Crée version |
| **Suppression** | Fichier parti | Marque comme supprimé |
| **Restauration** | Impossible | Possible ✓ |
| **Coût** | Bas | Plus haut (versions) |
| **Cas** | Temp files | Documents importants |

---

## 🖼️ DASHBOARD AWS

### Activer Versioning

```
1. Bucket > Properties > Versioning
2. Edit :
   ☑ Enable
   - Save ✓
⚠️ À faire AVANT les uploads (ou données existantes pas versionnées)
```

### Voir les versions

```
1. Bucket > Show versions (toggle en haut)
2. Chaque fichier liste toutes les versions
   - Version ID unique
   - Size, Modified date
```

### Restaurer une version

```
1. Fichier > Show versions
2. Sélectionnez version à restaurer
3. Download (puis upload pour remplacer)
OU
1. Ancien fichier > "Make latest" (si disponible)
```

### Supprimer une version

```
1. Version > Delete
⚠️ Suppression permanente
```

---

## 💻 CLI

### Activer Versioning

```bash
aws s3api put-bucket-versioning \
  --bucket mon-bucket \
  --versioning-configuration Status=Enabled
```

### Lister versions

```bash
aws s3api list-object-versions --bucket mon-bucket
```

### Restaurer version

```bash
# Copier une version spécifique par-dessus la courante
aws s3api copy-object \
  --bucket mon-bucket \
  --copy-source mon-bucket/fichier.txt?versionId=ABC123 \
  --key fichier.txt
```

### Supprimer une version

```bash
aws s3api delete-object \
  --bucket mon-bucket \
  --key fichier.txt \
  --version-id ABC123
```

### Désactiver Versioning

```bash
aws s3api put-bucket-versioning \
  --bucket mon-bucket \
  --versioning-configuration Status=Suspended
```

---

## 💡 BONNES PRATIQUES

- **Activer avant d'uploader** : versions précédentes pas récupérables
- **Nettoyer régulièrement** : vieilles versions = coûts
- **Lifecycle + Versioning** : combiner pour archiver anciennes versions
- **Immuabilité** : versions existantes ne peuvent pas être modifiées

---

## 📌 NOTES

- **Version ID** : UUID généré par AWS
- **Coût** : chaque version = stockage supplémentaire
- **Suppression** : crée delete marker (peut être annulé)
- **Restauration** : simple (re-upload la version)

---

[⬅️ Retour](./README.md)
