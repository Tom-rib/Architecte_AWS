# Permissions - Sécurité et Accès 🔐

Contrôler qui peut accéder à vos fichiers.

---

## 🎯 À quoi ça sert ?

- Rester privé par défaut (sécurité)
- Permettre accès public si besoin
- Permettre accès à autres utilisateurs AWS
- Appliquer règles de sécurité

---

## 📊 Comparaison : Accès

| | Privé | Semi-public | Public |
|---|---|---|---|
| **Cas** | Données sensibles | Partage sélectif | Site web |
| **Accès** | Vous seul | URL signée | N'importe qui |
| **Durée** | Permanent | 1h - 7 jours | Permanent |
| **Coût** | Normal | Normal | Normal |

---

## 🖼️ DASHBOARD AWS

### Bucket Policy (rendre public)

```
1. Bucket > Permissions > Bucket policy > Edit
2. Collez :

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::mon-bucket/*"
    }
  ]
}

3. Save changes ✓
```

### Rester Privé (bloqué par défaut)

```
Bucket > Permissions > Block Public Access
☑ Toutes les cases cochées = PRIVÉ ✓
```

### ACLs (ancien, à éviter)

```
⚠️ Recommandation : utiliser Bucket Policy au lieu de ACLs
Bucket > Permissions > ACL : à laisser "ACLs disabled"
```

### Générer URL signé (accès temporaire)

```
1. Fichier > Share > Copy URL
2. Ou : Bucket > Generate presigned URL
3. Set expiration : 1h, 1 jour, 7 jours
4. Copy presigned URL ✓
5. Lien valide pendant durée définie
```

---

## 💻 CLI

### Ajouter Bucket Policy (public)

```bash
aws s3api put-bucket-policy \
  --bucket mon-bucket \
  --policy file://policy.json

# Où policy.json contient la politique ci-dessus
```

### Voir la Bucket Policy

```bash
aws s3api get-bucket-policy --bucket mon-bucket
```

### Supprimer Bucket Policy

```bash
aws s3api delete-bucket-policy --bucket mon-bucket
```

### Générer presigned URL (CLI)

```bash
# Lien valide 1 heure
aws s3 presign s3://mon-bucket/mon-fichier.txt \
  --expires-in 3600

# Lien valide 7 jours
aws s3 presign s3://mon-bucket/mon-fichier.txt \
  --expires-in 604800
```

### Rendre objet public

```bash
aws s3api put-object-acl \
  --bucket mon-bucket \
  --key mon-fichier.txt \
  --acl public-read
```

---

## 🔗 URL S3 vs presigned

```
URL public (bucket policy) :
https://mon-bucket.s3.eu-west-3.amazonaws.com/mon-fichier.txt
→ Accessible toujours (si policy public)

Presigned URL (temporaire) :
https://mon-bucket.s3.eu-west-3.amazonaws.com/mon-fichier.txt?
X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=...&X-Amz-Signature=...
→ Accessible pendant durée définie (ex: 1h)
```

---

## 📌 NOTES

- **Sécurité par défaut** : tous les buckets PRIVÉS
- **Bucket Policy** : s'applique au bucket entier
- **IAM Policy** : contrôle accès utilisateurs AWS
- **Presigned URL** : partage temporaire sans modifier policies
- **Public** : signifie "accessible par n'importe qui sur Internet"

---

[⬅️ Retour](./README.md)
