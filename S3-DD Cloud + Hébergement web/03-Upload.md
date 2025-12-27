# Upload - Ajouter des Fichiers 📤

Mettre des fichiers dans S3.

---

## 🎯 À quoi ça sert ?

- Stocker des fichiers
- Backup documents
- Créer une bibliothèque de médias
- Préparer pour CloudFront

---

## 🖼️ DASHBOARD AWS

### Uploader des fichiers

```
1. S3 > Buckets > mon-bucket
2. Upload (bouton orange)
3. Zone drag-drop : glissez fichiers
   OU cliquez "Add files" et sélectionnez
4. Cliquez "Upload" ✓
5. Attendre (selon taille)
```

### Voir les fichiers

```
1. Bucket > sélectionnez bucket
2. Fichiers listés avec :
   - Nom (clé)
   - Taille
   - Date modification
   - Storage class
```

### Télécharger un fichier

```
1. Fichier > clic droit
2. Download
3. Fichier sauvegardé localement
```

### Supprimer un fichier

```
1. Fichier > clic droit
2. Delete
3. Confirm
```

### Créer un "dossier" (pseudo-dossier)

```
1. Upload > Type "dossier/" (avec slash)
2. Crée structure pseudo-hiérarchique
```

---

## 💻 CLI

### Uploader un fichier

```bash
aws s3 cp mon-fichier.txt s3://mon-bucket/
# ou avec chemin
aws s3 cp mon-fichier.txt s3://mon-bucket/dossier/
```

### Uploader un dossier entier

```bash
aws s3 cp mon-dossier/ s3://mon-bucket/dossier/ --recursive
```

### Télécharger un fichier

```bash
aws s3 cp s3://mon-bucket/mon-fichier.txt .
```

### Lister fichiers du bucket

```bash
aws s3 ls s3://mon-bucket/
```

### Supprimer un fichier

```bash
aws s3 rm s3://mon-bucket/mon-fichier.txt
```

### Supprimer tous les fichiers

```bash
aws s3 rm s3://mon-bucket/ --recursive
```

### Synchroniser dossier ↔ S3

```bash
# Uploader avec sync (seuls fichiers nouveaux)
aws s3 sync mon-dossier/ s3://mon-bucket/

# Télécharger avec sync
aws s3 sync s3://mon-bucket/ mon-dossier-local/

# Supprimer fichiers locaux supprimés sur S3
aws s3 sync s3://mon-bucket/ mon-dossier/ --delete
```

---

## 💡 BONNES PRATIQUES

- **Nommage** : utilisez structure cohérente (images/, documents/, etc)
- **Taille** : < 5 GB = simple, > 5 GB = multipart upload
- **Sync** : plus rapide que cp pour de nombreux fichiers
- **Versioning** : activez avant upload pour historique

---

## 📌 NOTES

- **Coût upload** : gratuit (c'est le téléchargement qui coûte)
- **Vitesse** : dépend votre connexion
- **Pseudodossiers** : juste de la convention de nommage (clés avec /)
- **Métadonnées** : ajouter custom metadata aux fichiers

---

[⬅️ Retour](./README.md)
