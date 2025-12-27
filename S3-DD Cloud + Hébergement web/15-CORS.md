# CORS - Cross-Origin Resource Sharing 🌐

Permettre requêtes depuis domaines différents.

---

## 🎯 À quoi ça sert ?

- Site web appelant S3 (autre domaine)
- API depuis JavaScript côté client
- Partage ressources cross-domain
- Web applications modernes

---

## 📊 Problème vs Solution

```
Problème :
https://monsite.com → https://mon-bucket.s3.amazonaws.com
❌ CORS error (domaines différents)

Solution :
Activer CORS sur bucket S3
✅ Autorise requêtes cross-origin
```

---

## 🖼️ DASHBOARD AWS

### Ajouter CORS

```
1. Bucket > Permissions > CORS
2. Edit > Ajouter configuration JSON

{
  "CORSRules": [
    {
      "AllowedHeaders": ["*"],
      "AllowedMethods": ["GET", "PUT", "POST"],
      "AllowedOrigins": ["https://monsite.com"],
      "ExposeHeaders": ["ETag"],
      "MaxAgeSeconds": 3000
    }
  ]
}

3. Save ✓
```

---

## 💻 CLI

### Ajouter CORS

```bash
aws s3api put-bucket-cors \
  --bucket mon-bucket \
  --cors-configuration file://cors.json
```

**cors.json :**
```json
{
  "CORSRules": [
    {
      "AllowedOrigins": ["*"],
      "AllowedMethods": ["GET", "PUT"],
      "AllowedHeaders": ["*"],
      "MaxAgeSeconds": 3000
    }
  ]
}
```

### Voir CORS

```bash
aws s3api get-bucket-cors --bucket mon-bucket
```

### Supprimer CORS

```bash
aws s3api delete-bucket-cors --bucket mon-bucket
```

---

## 📋 Headers CORS

| Header | Signification |
|--------|---|
| AllowedOrigins | Domaines autorisés (* = tous) |
| AllowedMethods | GET, PUT, POST, DELETE, HEAD |
| AllowedHeaders | Headers HTTP autorisés |
| ExposeHeaders | Headers exposés au client |
| MaxAgeSeconds | Cache de la politique |

---

## 📌 NOTES

- **AllowedOrigins** : "*" = risque de sécurité (utiliser domaine spécifique)
- **Preflight** : OPTIONS request avant GET/POST (AWS gère auto)
- **Credentials** : pour cookies/auth, préciser AllowCredentials

---

[⬅️ Retour](./README.md)
