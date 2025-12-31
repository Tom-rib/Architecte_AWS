# Static Website - Héberger un Site 🌐

Servir un site web HTML/CSS/JS directement depuis S3.

---

## 🎯 À quoi ça sert ?

- Héberger site statique (HTML/CSS/JS)
- Pas de serveur à gérer
- Pas de base de données requise
- Très bon marché

---

## 📊 Comparaison

| | S3 Static | EC2 | Gatsby Cloud |
|---|---|---|---|
| **Coût** | ~0.5€/mois | ~15€/mois | Gratuit |
| **Setup** | 5 min | 30 min | 10 min |
| **Scalabilité** | Auto | Manuel | Auto |
| **Contrôle** | Limité | Complet | Moyen |

---

## 🖼️ DASHBOARD AWS

### Étape 1 : Bucket public

```
1. Bucket > Permissions > Bucket Policy
2. Ajouter policy publique (voir 04-Permissions.md)
```

### Étape 2 : Index document

```
1. Bucket > Properties > Static website hosting
2. Edit :
   ☑ Enable
   - Index document : index.html (OBLIGATOIRE)
   - Error document : error.html (optionnel)
   - Save ✓
3. URL du site : http://mon-bucket.s3-website-eu-west-3.amazonaws.com/
```

### Étape 3 : Uploader fichiers

```
1. Bucket > Upload
2. Fichiers :
   ✓ index.html (DOIT exister)
   ✓ styles.css
   ✓ app.js
   ✓ images/ (dossier)
3. Upload ✓
```

### Tester le site

```
Ouvrez : http://mon-bucket.s3-website-eu-west-3.amazonaws.com/
Vous voyez : votre index.html ✓
```

---

## 💻 CLI

### Activer Static Website

```bash
aws s3api put-bucket-website \
  --bucket mon-bucket \
  --website-configuration '{
    "IndexDocument": {"Suffix": "index.html"},
    "ErrorDocument": {"Key": "error.html"}
  }'
```

### Voir la config

```bash
aws s3api get-bucket-website --bucket mon-bucket
```

### Uploader fichiers

```bash
aws s3 sync mon-site-local/ s3://mon-bucket/ --recursive
```

### Supprimer Static Website

```bash
aws s3api delete-bucket-website --bucket mon-bucket
```

---

## 📄 Exemple index.html

```html
<!DOCTYPE html>
<html>
<head>
    <title>Mon Site</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <h1>Bienvenue ! 🚀</h1>
    <p>Hébergé sur AWS S3</p>
    <script src="app.js"></script>
</body>
</html>
```

---

## 📌 NOTES

- **Index document** : OBLIGATOIRE (index.html)
- **URL S3 website** : http://bucket.s3-website-region.amazonaws.com
- **Pas HTTPS** : S3 website = HTTP uniquement
- **CloudFront** : utilisez pour HTTPS + CDN (voir 06-CloudFront.md)
- **SPA routing** : error.html = index.html pour single-page apps

---

[⬅️ Retour](./README.md)
