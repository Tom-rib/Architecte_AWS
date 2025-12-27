# CloudFront - CDN Global 🌍

Distribuer votre contenu depuis 200+ serveurs mondiaux.

---

## 🎯 À quoi ça sert ?

- Vitesse (serveurs proches)
- Réduire latence
- Réduire coûts (cache)
- HTTPS pour S3
- Protection DDoS

---

## 📊 Comparaison

| | S3 Direct | CloudFront |
|---|---|---|
| **URL** | http://bucket.s3... | https://d123.cloudfront.net |
| **Vitesse** | Lent (1 lieu) | Rapide (200+ serveurs) |
| **HTTPS** | Non | Oui ✓ |
| **Cache** | Non | Oui ✓ |
| **Coût** | Moins cher | Peu plus cher |
| **Recommandé** | Jamais | Toujours ! |

---

## 🖼️ DASHBOARD AWS

### Créer distribution CloudFront

```
1. CloudFront > Create distribution
2. Origin domain : sélectionnez bucket S3
   ⚠️ Choisir : bucket.s3.region.amazonaws.com
   (PAS bucket.s3-website-region...)
3. Viewer protocol policy : Redirect HTTP to HTTPS
4. Default root object : index.html
5. Create distribution ✓
6. Attendre 5-10 min
```

### Voir les distributions

```
CloudFront > Distributions
- Status : Deployed ✓
- Domain name : d123abc.cloudfront.net
- Origin : bucket S3
```

### Invalider cache

```
Distribution > Invalidations > Create invalidation
- Paths : /* (tous les fichiers)
- Create ✓
- Attendre 2-5 min
```

### Tester

```
Ouvrez : https://d123abc.cloudfront.net/
Vous voyez : votre site + HTTPS ✓
```

---

## 💻 CLI

### Créer distribution

```bash
aws cloudfront create-distribution \
  --distribution-config file://config.json
```

### Lister distributions

```bash
aws cloudfront list-distributions
```

### Créer invalidation

```bash
aws cloudfront create-invalidation \
  --distribution-id E123ABC \
  --paths "/*"
```

### Voir invalidations

```bash
aws cloudfront list-invalidations \
  --distribution-id E123ABC
```

---

## ⚠️ Pièges courants

```
❌ MAUVAIS Origin : bucket.s3-website-region.amazonaws.com
✅ BON Origin : bucket.s3.region.amazonaws.com
```

Si erreur "AccessDenied" :
1. Vérifiez Bucket Policy (voir 04-Permissions.md)
2. Attendre 5 min (mise en cache)
3. Créez une Invalidation

---

## 📌 NOTES

- **Déploiement** : 5-10 min sur 200+ serveurs
- **Cache** : 24h par défaut (paramétrable)
- **Invalidation** : force cloudfront à récupérer nouvelle version
- **Cost** : ~0.085€ / GB (vs ~2-4€ pour S3 direct)

---

[⬅️ Retour](./README.md)
